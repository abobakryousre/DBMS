#!/bin/bash

source ./include/printTableFormatted.sh

db_name=$1
echo you are using databasae: $db_name

tmp=$(mktemp) # create temprary file to carry the queries.
trap "rm -f $tmp" EXIT



function checkCreateTableStructure()
{
    typeset -a myarr
    local columns

    IFS=',' read -ra myarr <<< "$@"
    for column in "${myarr[@]}"
    do	    
        checkColumnStucture "$column"
        if [[ $? == 1 ]]
        then
            return 1
        fi
	    
    done

}



function checkColumnStucture()
{
    # will check the right structure for column, and it shold be,
    # first not equal ( pk str int )
    # second not equl (pk
    # argument: column contant
    # return: will return 1 if not the structure not right
    typeset -a columnContant
    local let flag=1
    local specialKeyWord=( "pk" "int" "str" )
    local myDataTypes=( "int" "str" )
    IFS=' ' read -ra columnContant <<< "$@"

    columnsRow="${columnContant[0]}"
    datatype="${columnContant[1]}"
    pk="${columnContant[2]}"
    
    
    if [[ ! "${specialKeyWord[@]}" =~ "${columnContant[0]}"  ]]
    then
        checkColumnName "${columnContant[0]}"
        if [[ $? == 0 ]]
        then
        
            if [[  "${myDataTypes[@]}" =~ "$datatype" ]]
            then
                if [[ ! "${columnContant[2]}" == '' ]]
                then
                    if [[ "$pk" == "pk" ]]
                    then

                        dataTypesRow="${columnContant[2]}:${columnContant[1]}"
                        saveNames $dataTypesRow $columnsRow
                        let flag=0
                        return 0
                    
                    fi
                
                else
                    dataTypesRow="${columnContant[1]}"
                    saveNames $dataTypesRow $columnsRow
                    let flag=0
                    return 0
                fi

            
            fi
          
        fi   
    
    fi 

    return $flag
}


function saveNames()
{

    # will save the column, and data types names until use it in createTable function
    # argumnets: data types, column names

    local dataTypesRow=$1
    local columnsRow=$2

    if [[ $datatypesline == '' ]]
    then
        datatypesline="$dataTypesRow"
    else
        datatypesline="$datatypesline:$dataTypesRow"
    fi

    if [[ $columnsLine == '' ]]
    then
        columnsLine="$columnsRow"
    else
        columnsLine="$columnsLine:$columnsRow"
    fi

}

function createTable()
{
    # will create new table in side the data base useing the names saved befor

    local $tableName
    local path=$HOME/DBMS/$db_name/$tableName
    echo $datatypesline > $path
    echo $columnsLine >> $path
}


function restructureInput()
{
    # will restructure the input to process the table's creation steps
    # arguments: the user input after pass all the checks
    # return:  structure string 

    typeset -a myarr
    local columns
    local allcolumns=''

    readarray -d , -t myarr <<< "$@"

    for columns in "${myarr[@]}"
    do
	    allcolumns="$allcolumns "$columns""
    done

    echo $allcolumns

}


function checkColumnName()
{
    # check column name if it match or not
    # argument: column name
    # return: 1 if not acceptable
    if [[ ! $1 =~ ^[a-zA-Z]([a-z0-9_A-Z]{0,10}|[a-z0-9_A-Z]{0,10}\$)$ ]]
    then
        return 1
    fi
}


function getInput()
{
    #get the input from the use and save it in tmp file, to deal with it in easy way.
    #read -ep  ">" input
    read -ep "($db_name)>" input
    echo $input > $tmp
}

function getCommand()
{
    # SQL command usally start with two key word,
    # this function will take the first to word from the tmp file, and convert it to lower case,
    # then return the command.
    command=$(cut -f 1,2 -d' '  $tmp)
    command=${command,,} # to convert all the charactares to lower case
    echo $command
}

function generateSelectComand()
{
    # modifay the input string to match select statemt structure, and convert it to lower case

    _select=$(cut -f 1 -d ' ' $tmp)
    _select=${_select,,}

    selectOption=$(cut -f 2 -d ' ' $tmp)
    selectOption=${selectOption,,}

    from=$(cut -f 3 -d ' ' $tmp)
    from=${from,,}

    tableName=$(cut -f 4 -d ' ' $tmp)
    tableName=${tableName,,}

    where=$(cut -f 5 -d ' ' $tmp)
    where=${where,,}

    arguments=$(cut -f 5- -d ' ' $tmp)
    arguments=${arguments,,}
}

function getTableName()
{
    # will take the input of the user, and then return the table name in lower case
    tableName=$(cut -f 3 -d ' ' $tmp)
    tableName=${tableName,,}
    echo $tableName
}

function getArguments()
{
    # will take the rest of the user input, and convert it to lower case,
    # then return the argument  
    arguments=$(cut -f 4- -d' '  $tmp)
    arguments=${arguments,,}  # to convert all the charactares to lower
    echo $arguments
}

function isTableExist()
{
    # check if the table is exist or not
    # arrgument: table name
    # return: will return 1 if not exist, or 0 if exist
    #tableName=$1
    path=$HOME/DBMS/$db_name/$tableName
    if [ -f $path ]  # if exist will will return 0, then go to excute the body
    then
        return 0
    else
        return 1
    fi
}


function checkTableContentBeforCreate()
{
    # check table name, columns name, data types.... and print statment if there is problem
    # arguments: table name, arguments
    # return: return 0, if there is no problem. 
    
    local let flag=0

    isTableExist $tableName
    if test $? -eq 0 
    then
        echo this table is already exist
        let flag=1
    else

        if [ "$arguments" = "" ]  # no argumnet passed
        then
            echo Invaled Syntax
            let flag=1
        else

            TableNameCheck $tableName
            if test $? -eq 1  
            then
                echo Invaled Table Name 
                let flag=1
            else
            
                primaryKeyNumbers $arguments
                if test $? -eq 1
                then
                    echo Multiple primary key defined
                    let flag=1
                fi
            fi
                
        fi 
    fi 

    return $flag

}

function help()
{
    clear
    PS3=">>"
    # print the right syntax, and any helpfull information to the user
    select choice in "create table" "show tables" "delete table" "insert new record" "update table" "print table" "select" "delete from" "exit"
    do
        case $choice in
        "create table")
            echo "this command to create a new table in your data base."
            echo "the available data types are STR INT."
            echo "you can assign only one primary key by using the 'pk' key word at the of your column declaration"
            echo "separate your columns by  ',' "
            echo "example:"
            echo "CREATE TABLE 'table-name' 'first column-name' 'data-type' 'pk' , 'first column-name' 'data-type' , ....."
            ;;
        "show tables")
            echo "this command to list all the tables in your data base."
            echo "example:"
            echo "SHOW TABLES"
            ;;
        "delete table")
            echo "this command to delete a table from your data base."
            echo "example:"
            echo "DELETE TABLE 'tabel-name'"
            ;;
        "insert new record")
            echo "this command to insert a new record in your table"
            echo "make sure enter the values as the columns are exsit in the table,
            and enter the right data type for each column."

            echo "example:"
            echo "INSERT INTO 'table-name' 'first-value' 'second-value' ...."
            ;;
        "update table")
            echo "this command to update some value in your table."
            echo "example:"
            echo "UPDATE TABLE 'table name' SET 'column name' = 'value'(this will change all the column with the given value) "
            echo "UPDATE TABLE 'table name' SET 'column name' = 'valed' WHERE 'column naem' = 'value'"
            ;;
        "print table")
            echo "this command to print out all the record inside a table."
            echo "example:"
            echo "PRINT TABLE 'table-name'"
            ;;
        "select")
            echo "this command to display records from table given"
            echo "example:"
            echo "SELECT ALLF FROM 'table name'"
            echo "SELECT ALL FROM 'table name' WHERE 'column name' = 'value'"
            echo "SELECT 'column name' FROM 'table name'"
            echo "SELECT 'column name' FROM  'table name'"
            ;;
        "delete from")
            echo "this command to delete records from table given"
            echo "example:"
            echo "DELETE FROM 'table name'(this will delete all records)"
            echo "DELETE FROM 'table name' WHERE 'column name' = 'value'"
            ;;
        "exit")
            clear
            break
            ;;
        *)
            echo "Enter value in range 1 -> 9"
        esac
    done
    

}

function ShowTable()
{
	# Action: this function will list all the table inside any database
	# Argument: need the database name
	path=$HOME/DBMS/$db_name
	
	if [ "$(ls -A $path)" ] 
	then
		ls $path
	else
		echo "This database has no table...!"
	fi
}

function PrintTable()
{
    # wil print all the recored in side the table, or print message if empty
    # arrgument: table name
    local $tableName=$1

    path=$HOME/DBMS/$db_name/$tableName
    isTableExist $tableName
    if test $? -eq 0
    then
        printTable ':' "$(sed '1d' $path)"
    else
        echo Invaled Table Name
    fi
}


function TableNameCheck()
{
    # will check the name, and check  if has any spiceal charactars.
    # arrguments: table name
    # return: will return 1, if there is a problem with the name

    if [[ ! $tableName =~ ^[a-zA-Z]([a-z0-9_A-Z]{0,20}|[a-z0-9_A-Z]{0,20}\$)$ ]]
    then
        return 1
    fi
}


function DeleteTable()
{
    # will delete table if exist
    # arrguments: table name

    path=$HOME/DBMS/$db_name
    cd $path
    isTableExist $tableName
    if test $? -eq 0
    then
        rm $tableName
    else
        echo Invaled Table Name
    fi
}


function MatchDataTypes()
{
    # will compare the data type in the tabe with the input one
    # arrgument: table name, input arrguments 
    # return:  return 1 if there is a problem with data types

    path=$HOME/DBMS/$db_name/$tableName
    sed -n '1p' $path > $tmp # will have the data types
    typeset -i counter=1

    for arg in $arguments
    do
        datatype=$(cut -f $counter -d : $tmp)
        if [ "$datatype" = "int" ]
        then

            if [[ $arg =~ ^[+-]?[0-9]+$ ]]
            then
                counter=$counter+1
            else
                return 1
            fi

        elif [ "$datatype" = "str" ]
        then

            if [[  $arg =~ ^[a-zA-Z]+ ]]
            then
                counter=$counter+1
            else
                return 1
            fi
        
        elif [ "$datatype" = "pk" ]
        then
            ## Pk Check
            # get all the values in the table for this column
            values=$(cut -f $counter -d : $path)

            #compare the values inside the table with the user argguments
            for value in $values
            do
                if [ "$value" == "$arg" ]
                then
                    return 1
                fi
            done
            ## data type check

            # now we need to check the data type of this primary key
            # first we need to get the data type (next feild)
            datatype=$(cut -f $((counter+1)) -d : $tmp)
            # check if match or no

            if [ "$datatype" = "int" ]
            then

                if [[ ! $arg =~ ^[+-]?[0-9]+$ ]]
                then
                    return 1
                else
                    counter=$counter+2 # +2 becase the data type line has pk filed more than the columns
                fi

            elif [ "$datatype" = "str" ]
            then

                if [[ ! $arg =~ ^[a-zA-Z]+ ]]
                then
                    return 1
                else
                    counter=$counter+2 # +2 becase the data type line has pk filed more than the columns
                fi

            fi
        fi

    done
}



function MatchColumnNumbers()
{
    # will compaer the number of column in some table to the number of input arguments
    # arguments: tablename, arrguments
      

    local path=$HOME/DBMS/$db_name/$tableName
    
    sed -n '2p' $path > $tmp # get the second row, == columns name
    tableFields=$(awk -F: '{print NF; exit}' $tmp) # get number of fields, == columns number
    echo $arguments > $tmp # will save the arguments in tmp file to be able to use awk 4

    argumentsFields=$(awk '{print NF; exit}' $tmp)
    if [ "$tableFields" = "$argumentsFields" ]
    then
        return 0
    else
        return 1
    fi
}

function InsertRecord()
{
    # will insert the new record in the table give
    # arrguments: table name, and argguments
   
    local path=$HOME/DBMS/$db_name/$tableName

    local record=''

    for arg in $arguments
    do
        if [ "$record" == '' ] # if this the first element we dont need ':'
        then
            record=$arg

        else
            record="$record:$arg"
        fi

    done

    echo $record >> $path

}


function getColumNumber()
{
	# will find column number inside the table given
    # argumernt: table name, column name
    # return: will return column's number

	local tableName=$1
	local colName=$2
    local path=$HOME/DBMS/$db_name/$tableName
	local number=$(awk -F: -v value=$colName '{for(i=1; i<=NF; i++) if($i == value) print i}' $path)
	
	echo $number
	
}

function cutCol()
{
	# will get the spicefice column in table
	# arguments: table name, columnNumber
	# return: return the column
	
	local num=$2
	local path=$HOME/DBMS/$db_name/$tableName
	cut -f $num -d : $path > $tmp
	sed -i '1,2d' $tmp 
	

}


function getRecordNumber()
{
	# will get record number
	# argument table has the one column, value
	# return: record number
	local tmpTable=$1
	local value=$2
	recordNumber=$(awk -v value=$value '{if($0 == value) print NR}' $tmpTable)
	echo $recordNumber
	
}



function isColumnExist()
{
	# will check if the column exsit in the table or not 
	# arguments: table name, column name
	# return: 1 if not exist, 0 if exist
	local tableName=$1
	local columnName=$2
	local path=$HOME/DBMS/$db_name/$tableName
	sed -n '2p' $path > $tmp # get column names
	local flag=$(awk -F: -v col=$columnName '{for(i=0; i<=NF; i++) if($i == col) print 0}' $tmp)
	
	if [ "$flag" == 0 ]
	then
		return 0
	else
		return 1
	fi 


}


function isValueExist()
{
	# will check is the value exsit inside the table or not
	# arguments: colum name, value
	local columnName=$1
	local value=$2

	local flag=$(awk -v value=$value '{if($0 == value) print 0}' $tmp)
	
	if [[ "$flag" =~ ^[0]+ ]]
	then
		return 0
	else
		return 1
	fi 

}

function isTableEmpty()
{
	# will check if the table is empty or not
	# arguments: table name
	
	local flag=$(awk '{if(NR > 2) print 0}' $tableName)
	
	if [ "$flag" == 0 ]
	then
		return 0
	else
		return 1
	fi
}

function deleteRecordWithCondition()
{
	# will delete record form table
	# argumnets: table name, record number

    local path=$HOME/DBMS/$db_name/$tableName


    isTableExist $tableName
    if test $? -eq 1
    then
        echo "Invaled Table Name"
      return 0
    fi

    echo $arguments > $tmp
    local whereCommand=$(cut -f 1 -d ' ' $tmp)
	local columnName=$(cut -f 2 -d ' ' $tmp)
    local operator=$(cut -f 3 -d ' ' $tmp)
	local value=$(cut -f 4 -d ' ' $tmp)
    
	#check where syntax 
    if [[ "$whereCommand" == "where" ]]
    then

        if [[ "$operator" == "=" ]]
        then
            isColumnExist $tableName $columnName
            if [[ $? == 0 ]]
            then
                
                columnNumber=$(getColumNumber $tableName $columnName) # take column name and return its number to cut
                cutCol $tableName $columnNumber  # cut the column and send it to $tmp file
                isValueExist $columnNumber $value # this function work on $tmp file 
                if [[ $? == 0 ]]
                then
                    
                    #isValueExist $columnNumber $value 
                    while ( $(isValueExist $columnNumber $value) ) 
                    do
                        let recordNumber=$(getRecordNumber $tmp $value) #take value in the column cuted and get it's recordnumber 
                        let recordNumber=$recordNumber+2 # we increment 2 because the first two record for data type and column name
                        sed "$recordNumber d" $path > $tmp && mv $tmp $path

                        cutCol $tableName $columnNumber # we need to send the column again to tmp file to make isValueExit check for rest values
                    done
                else
                    echo "this value is not exist."
                fi
                
            else
                echo "this column is not exist."
            fi
        else
            echo Invaled operator
        fi
	else
        echo Invaled Syntax
    fi
}

function deleteAllRecord()
{

    # update all the record by given value
    # arguments: table name
    local tableName=$1
    local path=$HOME/DBMS/$db_name/$tableName

    isTableExist $tableName
    if test $? -eq 1
    then
        echo "Invaled Table Name"
      return 0
    else
        sed -n "1,2 p" $path > $tmp && mv $tmp $path

    fi

}

function selectAllRecordWithCondition()
{
    # will print out selected record
    # arguments: tabel name
    local path=$HOME/DBMS/$db_name/$tableName

    echo $arguments > $tmp
    local whereCommand=$(cut -f 1 -d ' ' $tmp)
	local columnName=$(cut -f 2 -d ' ' $tmp)
    local operator=$(cut -f 3 -d ' ' $tmp)
	local value=$(cut -f 4 -d ' ' $tmp)
    
    isTableExist $tableName
    if test $? -eq 1
    then
        echo "Invaled Table Name"
      return 0
    fi

	#check where syntax 
    if [[ "$whereCommand" == "where" ]]
    then

        isColumnExist $tableName $columnName
        if [[ $? == 0 ]]
        then
            if [[ "$operator" != "=" ]]
            then
                echo Invaled Syntax

            else
                columnNumber=$(getColumNumber $tableName $columnName) # take column name and return its number to cut
                cutCol $tableName $columnNumber  # cut the column and send it to $tmp file
                isValueExist $columnNumber $value
                if [[ $? == 0 ]]
                then
                    let recordNumber=$(getRecordNumber $tmp $value) #take value in the column cuted and get it's recordnumber 
                    let recordNumber=$recordNumber+2 # we increment 2 because the first two record for data type and column name
                    
                    sed -n "2p" $path > $tmp #  print columns's name
                    sed -n "$recordNumber p" $path >> $tmp # print the record which containt the value passed
                    printTable ':' "$(cat $tmp)"  
                else
                    echo "this value is not exist."
                fi

            fi

        else
            echo "this column is not exist."
       fi
	else
        echo Invaled Syntax
    fi



}

function selectAllRecord ()
{
    # will print all table contant 
    # argument: table name
    local tableName=$1
    PrintTable $tableName
}

function selectColumnWithCondition
{
    # retrieve one intersection between column and reccord
    # arguments: table name, arguments

    local selectedColumnNmae=$1
    local path=$HOME/DBMS/$db_name/$tableName

    echo $arguments > $tmp
    local whereCommand=$(cut -f 1 -d ' ' $tmp)
	local columnName=$(cut -f 2 -d ' ' $tmp) #cutting column name
    local operator=$(cut -f 3 -d ' ' $tmp)
	local value=$(cut -f 4 -d ' ' $tmp)
    
    isTableExist $tableName
    if test $? -eq 1
    then
        echo "Invaled Table Name"
      return 0
    fi

	#check where syntax 
    if [[ "$whereCommand" == "where" ]]
    then

        isColumnExist $tableName $columnName
        if [[ $? == 0 ]]
        then
            if [[ "$operator" != "=" ]]
            then
                echo Invaled Syntax

            else
                columnNumber=$(getColumNumber $tableName $columnName) # take column name and return its number to cut
                cutCol $tableName $columnNumber  # cut the column and send it to $tmp file
                isValueExist $columnNumber $value
                if [[ $? == 0 ]]
                then
                    let recordNumber=$(getRecordNumber $tmp $value) #take value in the column cuted and get it's recordnumber 
                    columnNumber=$(getColumNumber $tableName $selectedColumnNmae) 
                    cutCol $tableName $columnNumber 
                    printTable ':' "$(sed -n "$recordNumber p" $tmp)"  # print the record which containt the value passed
                else
                    echo "this value is not exist."
                fi

            fi

        else
            echo "this column is not exist."
       fi
	else
        echo Invaled Syntax
    fi

}

function selectColumn()
{
    # retrieve all the record from specific column
    # arguments: table name, column name
    local tableName=$1
    local columnName=$2
    local path=$HOME/DBMS/$db_name/$tableName

    
    isTableExist $tableName
    if test $? -eq 1
    then
        echo "Invaled Table Name"
      return 0
    fi



    isColumnExist $tableName $columnName
    if [[ $? == 0 ]]
    then
        columnNumber=$(getColumNumber $tableName $columnName) # take column name and return its number to cut
        cutCol $tableName $columnNumber  # cut the column and send it to $tmp file
        printTable ':' "$(cat $tmp)" 
    else
        echo "this column is not exist."
    fi



}

function primaryKeyNumbers()
{
    # will check number of primary key before create new table
    # arguments: the create statment
    # return: will return 1, if number of primary key more than one

    
    local let pkCounter=0

    for arg in $arguments
    do
        if [ "$arg" == "pk" ]
        then
            let pkCounter=$pkCounter+1
        fi
    done


    if [ $pkCounter -gt 1 ]
    then
        return 1
    else
        return 0
    fi

}

function insertInto()
{
    # will check the record and then insert it into  a given table
    # argument: table name, record


        isTableExist $tableName
        if test $? -eq 0 
        then
            MatchDataTypes $tableName $arguments
            if test $? -eq 0
            then
                MatchColumnNumbers $tableName $arguments
                if test $? -eq 0
                then
                    InsertRecord $tableName $arguments
                else
                    echo "Invaled Input , please check the columns's data type, numebrs, and try again."
                fi
            else
                echo "Invaled Input , please check the columns's data type, numebrs, and try again."

            fi

        else
            echo "Invaled Table Name"
        fi

}


function updateRecord()
{
	# will create a new record with change in some value in it
	# argument: old record, updated column number, new value
	# return: an updated record
	local oldRecord=$(mktemp)
	trap "rm -f $oldRecord" EXIT
	
	echo $1 > $oldRecord
	local colNumber=$2
	local newValue=$3
	local newRecord=$(awk -v value=$newValue -v col=$colNumber -F: 'BEGIN{OFS=" ";}{$col=value; print}' $oldRecord)
		
	echo $newRecord
}

function isColumnPk()
{
    # check if the column is primary key
    # argument: column number
    #return:  0 if column primary key

    local tableName=$1
    local columnNumber=$2
    local path=$HOME/DBMS/$db_name/$tableName
    local pk=$(awk -v col=$columnNumber -F: '{print $col; exit}' $path ) # the first line is the data type and pk
    if [[ "$pk" == "pk"  ]]
    then
        return 0
    else
        return 1
    fi
}

function updateTable()
{
    # will update the all column with the same value, if there is no where condition
    # arguments: table name, arguments
    local tableName=$1
    local path=$HOME/DBMS/$db_name/$tableName

    
    echo $arguments > $tmp 
    local setCommand=$(cut -f 1 -d ' ' $tmp)
    local updatedColumnName=$(cut -f 2  -d ' ' $tmp)
    local firstOperator=$(cut -f 3 -d ' ' $tmp)
    local updatedValue=$(cut -f 4 -d ' ' $tmp)

    local columnNumber=$(getColumNumber $tableName  $updatedColumnName)


    isTableExist $tableName
    if [[ $? == 1 ]]
    then
        echo Invaed Table Name
        return 1
    fi

    isColumnExist $tableName $updatedColumnName
    if [ $? == 0 ]
    then
        if [[ "$setCommand" == "set" ]]
        then
            if [[ "$firstOperator" == "=" ]]
            then
                isColumnPk $tableName $columnNumber

                if [[ $? != 0 ]]
                then

                    awk -v valu=$updatedValue -v col=$columnNumber -F: 'BEGIN{OFS=":"} {if(NR>2) $col=valu; print $0}' $path > $tmp && mv $tmp $path

                else
                    echo  invaled input due to primary key constrain
                fi
            else
                echo Invaled Operator
            fi
        else
            echo Invaled Syntax
        fi
    else
        echo  Invaled Column Name
    fi

}

function updateTableWithCondition()
{
    # update al record matched with the condition given by given value
    # arguments: table name, arguments

    local oldRecord
    local newRecord
    local recordNumber
    local oldColumnNumber
    local newColumnNumber
    local path=$HOME/DBMS/$db_name/$tableName

    isTableExist $tableName
    if [[ $? == 1 ]]
    then
        echo Invaed Table Name
        return 1
    fi
    
    echo $arguments > $tmp 
    local setCommand=$(cut -f 1 -d ' ' $tmp)
    local updatedColumnName=$(cut -f 2  -d ' ' $tmp)
    local firstOperator=$(cut -f 3 -d ' ' $tmp)
    local updatedValue=$(cut -f 4 -d ' ' $tmp)
    local whereCommand=$(cut -f 5 -d ' ' $tmp)
    local oldColumnName=$(cut -f 6 -d ' ' $tmp)
    local secondOperator=$(cut -f 7 -d ' ' $tmp)
    local oldValue=$(cut -f 8 -d ' ' $tmp)

    if [ "$setCommand" = "set" ]
    then
        isColumnExist $tableName $updatedColumnName
        if [[ $? == 0 ]]
        then
            isColumnExist $tableName $oldColumnName
            if [[ $? == 0 ]]
            then
                if [[ "$whereCommand" == "where" ]]
                then
                    if [ "$firstOperator" == "=" ] &&  [ "$secondOperator" == "=" ] 
                    then

                        oldColumnNumber=$(getColumNumber $tableName  $oldColumnName ) # take column name and return its number to cut
                        cutCol $tableName $oldColumnNumber  # cut the column and send it to $tmp file
                        isValueExist $oldColumnNumber $oldValue
                        if [[ $? == 0 ]]
                        then
                            local numberOfvalues=$(cut -f $oldColumnNumber -d : $path | grep $oldValue | wc -l )
                            for ((i=0; i<$numberOfvalues; i++))
                            do
                                let recordNumber=$(getRecordNumber $tmp $oldValue) #take value in the column cuted and get it's recordnumber 
                                let recordNumber=$recordNumber+2 # we increment 2 because the first two record for data type and column name
                                oldRecord=$(sed -n "$recordNumber p" $path)
                                

                                # get new column number
                                newColumnNumber=$(getColumNumber $tableName  $updatedColumnName )
                                newRecord=$(updateRecord $oldRecord $newColumnNumber $updatedValue)

                                sed "$recordNumber d" $path > $tmp && mv $tmp $path # delete old record

                                arguments=$(echo $newRecord)
                                insertInto $tableName $arguments
                                cutCol $tableName $oldColumnNumber
                            done

                        else
                            echo "this value is not exist."
                        fi
                    else
                        echo Invaled operator
                    fi
                    
                else
                    echo Invaled Syntax
                fi
            else
                echo Ivaled Column Name 
            fi
        else
            echo Invaled Column Name
        fi
        

    else
        echo "Invaled Syntax"
    fi


    

}


function ExcuteQuery()
{
    # wil take a command and excute it, if it exit 
    # arrgument: command

    case $command in
    "show tables")
        ShowTable $db_name
        ;;
    "create table")
    
        local columnsLine=''
        local datatypesline=''

        checkCreateTableStructure $(echo $arguments)
        if [[ $? -eq 0 ]]
        then
            arguments=$(echo $(restructureInput $arguments )) 
            checkTableContentBeforCreate $tableName $arguments
            if test $? -eq 0 
            then 
                createTable $tableName 
            fi

        else
            echo Invaled Syntax
        fi

        ;;
    "print table")
         # the user shall write SELECT * FROM table-name
        PrintTable $tableName
        ;;
    "delete table")
        DeleteTable $tableName
        ;;
    "insert into")
        insertInto $tableName $arguments
        ;;
    "update table")

        local whereCommand=$(cut -f 8 -d ' ' $tmp)
        if [[ "$whereCommand" == '' ]]
        then
            updateTable $tableName $arguments
        else
            updateTableWithCondition $tableName $arguments
        fi 
        ;;
    "delete from")
        if [[ "$arguments" == '' ]]
        then
            deleteAllRecord $tableName
        else
            deleteRecordWithCondition $tableName
        fi 
        ;;
    "--help")
        help
        ;;
    "exit")
        let flag=0
        ;;
    *)
        echo Invaled Syntax 
        echo "Type --help for help"
        ;; 

    esac


}

function ExcuteSelectStatment()
{
    # select all from 
    # select 'col' from 
    local columnName=$selectOption

    case $selectOption in
    "all")
        
        if [[ "$from" == "from" ]]
        then
            
            if [[ "$where" != "" ]]
           then
                 
                selectAllRecordWithCondition
                
            else
                selectAllRecord $tableName 
            fi
           
        else
            echo Invaled Syntax
        fi
        ;;
    *)
        if [[ "$from" == "from" ]]
        then
            if [[ "$where" != "" ]]
            then
                selectColumnWithCondition $columnName
            else
                
                selectColumn $tableName  $columnName
            fi
        else
            echo Invaled Syntax
        fi
        ;;
        
    esac
}

let flag=1

while [ $flag = 1 ]  
do
    
    getInput

    dmlFlag=$(cut -f 1 -d ' ' $tmp)
    dmlFlag=${dmlFlag,,}

    if [[ "$dmlFlag" == "select" ]]
    then
        
        generateSelectComand
        ExcuteSelectStatment

    else
        command=$(getCommand)
        tableName=$(getTableName)
        arguments=$(getArguments)
        ExcuteQuery $command
    fi

done