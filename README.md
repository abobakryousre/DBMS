# Database Engine

this is a bash script simulate Database Engine with the basic functionality


## Table of content
- [**Install**](#Install)
- [Usage](#Usage)
- [How It Is Work](#Usage)
- [Built With](#BuiltWith)
- [Motivation](#Motivation)


## Getting Started
### Install
1. Move all the scripts in the same directory
2. Give all scripts excutable option
3. Run main.sh 



### Usage
using the general  [SQL](#SQL) command.Example
* create database 'name'
* show databases
* select all from 'table-name'
* --help
###
### available datatypes are 
* str int, and only primary key constran

#
## How It Is Work

### On  DataBase level:

GetdatabaseCommand()

    • SQL command usally start with two key word,
    • this function will take the first to word from the tmp file, and convert it to lower case, then return the command. SQL command usally start with two key word,
    • this function will take the first to word from the tmp file, and convert it to lower case,
    • then return the command



GetdatabaseName()

    • will take the input of the user, and then return the table name in lower case



creatdatabase()

    • syntax:
    • CREATE DATABASE database_name 

    • What :
    • Create Database at DBMS 
    •  when we wrote this command it will make sure for all checks then will create a directory with name of database in a DBMS

    • How :
        *  check that syntax is right
        * check that database name doesn't start with special characters or number or doesn't have space 
        *  check if database name doesn't used before


Listdatabase()

    • syntax :
    -SHOW DATABASES 

    • What :
    • display all databases that created at DBMS 
    • after made all checks then will display names of all directories at DBMS
    • How:
        * check right syntax
        *  check if DBMS is empty or not 
        * then display all databases was created

opendatabase()

    • syntax:
    • USE DATABASE Database_name 

    • What :
    • open Database from DBMS
    • after all checks , then open a directory  that name was wrote to use it

    • How:
        * check right syntax 
        *  check if Database is found at DBMS 
        *  then open database to use 

deletedatabase()

    • syntax: 
    • DELETE DATABASE Database_ name 

    • What :
    • Delete database 
    • after all checks , then will delete a directory that name was written at command from DBMS
    • How :
        * check right syntax
        * check if DBMS is empty
        *  check if Database name is found 

Help 

    • Syntax:
        -- HELP 
    • What :
    • help user with simple command 
    • display commands should use when we deal with database at DBMS





### On table level :

getInput()

    • what:
    will take the input from the user and structure it to match sql queries
    • How:
        *  check the first key word if it select will restructure the input to match the select queries
        *  if not select will restructure the input to match the left sql structure

createTable()

    • what:
    • will create a file inside database directory with mentioned columns structure
    • How:
        * the first line in the file (table), to save the data type and the primaky key if exist
        * second line will represent the columns names, and we save these names in variables(function saveNames()) untill check for the columns structure
        * check the right structure for creating table (
            each column will be sepreated by ",".
            the first word will be for the column names, and check if the name is acceptable.
            the second must be data type, check if this data type is the available.
            the third is optional, and must be pk.
        )
        * check if the table name is acceptable
        * check the number of primary keys

ShowTable()

    • Syntax:
    • Show tables 

    • What:
    • will display all tables at spacefic database in DBMS
    • it's mean will display all files from a specific directory in DBMS

    • How:
        * check if Database has tables or not 
        * Then print the all the tables if exist





PrintTable()

    • Syntax:
     Print table table_name
    Note:
    • Command separated by space 
 
    • What :
    • will display data inside table file

    • How :
        * check that syntax is right
        * check if table  is exist 
        * print name of column and data inside it 

DeleteTable()

    • Syntax
    • Delete table table_name

    • what
    • Will delete table and all content from spacific Database

    • How 
        * check if table name is exist 

InsertRecord()

    • Syntax:
    • Insert into table_name value_1  value_2. Value_3 ...

    • What :
    • insert record values that equal number of column

    • How :
        * check if table name exist 
        * check if values are inserted as same manner as column inserted in table with same data types 
        * each value Start from command end to values should separated by space 
        * each column must have value , so values should equel number of column or input will be invalid 

        * Top of Form
        * Bottom of Form

deleteRecordWithCondition()

    •  syntax:
    • Delete from table_name  where column_name = value
    • What :
    • Delete spacific record from spacific table depends on value that assigned in where
    • How:
        * check if table name is exist 
        * check if each argument separated by space 
        * check if column name is exist 
        * check if value of column name is found and equal value that assigned to column name 
        * then delete this record from table 
        * then return table with new record 


selectAllRecord()

    • Syntax:
    SELECT ALLF FROM 'table name'
    • What:
    retrieve all the record from selected table and print it in the screen
    • How:
        * check table selceted is exist
        * then print every thing inside it


selectAllRecordWithCondition()

    • Syntax:
    • SELECT ALL FROM 'table name' WHERE 'column name' = 'value'
    • What:
    • retrieve all the record from selected table with matched condition and print it in the screen
    • How:
            * check table, column selceted are exist
            * check the qurey structure 
            * check the condition is valed 
            * get the record's number
            * print this record


SelectColumn()

    • Syntax:
        SELECT 'column name' FROM 'table name'

    • What:
    SELECT 'column name' FROM  'table name'
    retrieve all the record from specific column
    • How:
        * check table, column selceted are exist
        * cut this column and save it in temporary file 
        * print this column


selectColumnWithCondition()

    • Syntax:
    • SELECT 'column name' FROM 'table name' WHERE 'column name' = 'value'
    • what:
    retrieve one intersection between column and record
    • How:
        * check table, column selceted are exist
        * check the qurey structure 
        * check the condition is valed 
        * then cut the mentioned column and save it in temporary file
        * get the record's number
        * print this record


updateTable()

    • Syntax:
    • UPDATE TABLE 'table name' SET 'column name' = 'valued'
    • what:
    update all the record by given value
    • How:
        * check isTableName exist
        * check isColumnName exist
        * check the right syntax
        * check isColumnPK
        * update all the record

updateTableWithCondition()

    • Syntax:
    • UPDATE TABLE 'table name' SET 'column name' = 'valed' WHERE 'column naem' = 'value'
    • what:
    update al record matched with the condition given by given value
    • How:
        * check isTableName exist
        * check isColumnName exist
        * check the right syntax
        * check is this value exist
        * get the updatedColumn
        * loop in all record, update it
        * delete the old record
        * insert the new one


## Built With
general bash command, and library for displaying formatted tables

## Motivation
Mastering bash command, and challenge myself to simulate one of the most well knows [DBMS](#DBMS)

