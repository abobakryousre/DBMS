#!/bin/bash


#########################################################################################
                    #this will run one time at the beginning of using this script     
                                  # Creating DBMS directory                                                                  
                                    if [[ ! -d $HOME/DBMS ]]
                                    then
                                        mkdir $HOME/DBMS
                                    fi

#########################################################################################


tmp=$(mktemp) # create temprary file to have the queries.
trap "rm -f $tmp" EXIT

echo "Welcom $USER......" 
echo "you can type exit any time you would like to close the program"

function getInput()
{
    #get the input from the use and save it in tmp file, to deal with it in easy way.
    read -ep ">" input
    echo $input > $tmp
}


function getCommand()
{
    # SQL command usally start with two key word,
    # this function will take the first two word from the tmp file, and convert it to lower case,
    # then return the command.
    
    command=$(cut -f 1,2 -d' '  $tmp)
    command=${command,,} # to convert all the charactares to lower case
    echo $command
}


function getDatabaseName()
{
    # will take the input of the user, and then return the table name in lower case
    databaseName=$(cut -f 3 -d ' ' $tmp)
    databaseName=${databaseName,,}
    echo $databaseName
}


function creatDataBase()
{   
    #cd "/home/ghada/DBMS"   #creat data base
    path="$HOME/DBMS/$databaseName"            #data base name
    if [[ "$databaseName" =~ ^[a-zA-Z]([a-z0-9_A-Z]{0,20}|[a-z0-9_A-Z]{0,20}\$)$  ]]
    then
    if [ -d "$path" ]; then 
      echo "database with name $databaseName exist in DBMS"
      else

        mkdir "$path"
        echo "DataBase with name $databaseName created"
    fi 
    else echo name of database  $databaseName is invalid try enter another name
    fi
}


function showDatabase()
{ 
    if [ "$(ls -A $HOME/DBMS )" ] #list database good
    then
    ls $HOME/DBMS

    else
    echo "DataBase is empty"
    fi
}


function openDatabase()
{  
    
    local  path="$HOME/DBMS/$databaseName"
    if [ -d "$path" ]
    then 
        clear
        bash ./table-managment.sh $databaseName
    else 
        echo "database $databaseName not found "
    fi
}

function deleteDtabase()
{
    #echo "enter name of Data Base you want delet " #delet database good
    path="$HOME/DBMS/$databaseName"
    
    if [ "$(ls -A $HOME/DBMS )" ]
    then
      if [ -d "$path" ]
    then
    rm -r "$path"
    echo "database $databaseName succesfully deleted"
    else 
     echo database $databaseName not exist
     fi
    else 
        echo "database storge is empty"
    fi
}

function help()
{
    clear
    PS3=">>"
    # print the right syntax, and any helpfull information to the user
    select choice in "create database" "show database" "use database" "delete database" "exit"
    do
        case $choice in
        "create database")
            echo "this command to create a new database ."
            echo "example:"
            echo "create database 'database-name'"
            ;;
        "show database")
            echo "this command to list all databases."
            echo "example:"
            echo "show databases "
            ;;
        "use database")
            echo "this command will open database."
            echo "example:"
            echo "use databases" 'database-name'
            ;;
        "delete database")
            echo "this command to delete a database."
            echo "example:"
            echo "delete database 'database-name'"
            ;;
        
        "exit")
            clear
            break
            ;;
        *)
         echo "invalid option"
         ;;
        esac
    done
    

}

function excuteQuery()
{
    case $command in
    "create database")
    creatDataBase $databaseName
    ;;

    "show databases")
        showDatabase 
        ;;

    "use database")
        openDatabase $databaseName
    ;;
    "delete database")
         deleteDtabase $databaseName
    ;;
    "exit")
        let flag=0
        ;;
    "--help")
        help 
        ;;
    *)
        echo Invaled Syntax 
        echo "type --help for help"
        ;;
    esac
}


let flag=1

while [ $flag == 1 ]
do
    getInput
    command=$(getCommand)
    databaseName=$(getDatabaseName)
    excuteQuery $command
done
