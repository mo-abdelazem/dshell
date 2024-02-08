#!/bin/bash

function createDatabase() {
    read -p "Enter the database name: " dbName

    if [[ -d $dbName || -d $(echo "$dbName" | tr '[:upper:]' '[:lower:]') ]]; then
        echo "Invalid input! There is an existing database named $dbName !"
        createDatabase

    elif [[ $dbName =~ ^[0-9]+$ ]]; then
        echo "Invalid input! name of database can't be only numbers!"
        createDatabase

    elif [[ $dbName =~ ^[0-9] ]]; then
        echo "Invalid input! name of database can't start with numbers!"
        createDatabase

    elif [[ $dbName == *" "* ]]; then
        echo "Invalid input! name of database can't contain spaces.!"
        createDatabase
    elif [[ $dbName == *[!a-zA-Z0-9_]* ]]; then
        echo "Invalid input! name of database can't contain a spacial charctars.!"
        createDatabase
    elif [ ! -n "$dbName" ]; then
        echo "Invalid input! name of database can't be empty.!"
        createDatabase

    else
        mkdir $dbName

        echo -e "\n-----------------------------------------"
        echo "Database '$dbName' created successfully."
        echo "-----------------------------------------"
    fi
}

function listDatabases() {
    databases=$(ls -d */ 2>/dev/null | tr -d /)
    if [ -n "$databases" ]; then
        echo -e "\n-----------------------------------------"
        echo "List of existing databases:"
        echo -e "-----------------------------------------"
        echo -e "| No.     | Database Name                 |"
        echo -e "-----------------------------------------"
        echo -e "$databases" | nl -w8 -s"  | "
        echo -e "-----------------------------------------"
    else
        echo -e "\n-----------------------------------------"
        echo "No databases found."
        echo "Returning to the main menu..."
        echo "-----------------------------------------"
        return
    fi
}

function connectDatabase() {
    databases=$(ls -d */ 2>/dev/null | tr -d /)
    if [ -z $databases ]; then
        echo -e "\n-----------------------------------------"
        echo "No databases found."
        echo "-----------------------------------------"
        baseMenu
    else
        listDatabases
        read -p "Enter the number of the database you want to connect to: " selected_number
        database_name=$(ls -d */ 2>/dev/null | tr -d / | sed -n "${selected_number}p")
        if [ -n "$database_name" ]; then
            cd "$database_name" 2>/dev/null
            echo -e "\n-----------------------------------------"
            echo "Connected to database '$database_name'."
            echo "-----------------------------------------"
            chooseAction
        else
            echo -e "\n-----------------------------------------"
            echo "Invalid selection. Please enter the number corresponding to the database you want to use."
            echo "-----------------------------------------"
            connectDatabase
        fi
    fi
}

function disconnectDatabase() {
    cd ..
    echo -e "\n-----------------------------------------"
    echo "Disconnected from the current database."
    echo "-----------------------------------------\n"
}

function dropDatabase() {
    databases=$(ls -d */ 2>/dev/null | tr -d /)

    if [ -n "$databases" ]; then
        echo -e "\n-----------------------------------------"
        echo "List of existing databases:"
        echo -e "-----------------------------------------"
        echo -e "| No. | Database Name                     |"
        echo -e "-----------------------------------------"
        echo -e "$databases" | nl -w8 -s"  | "
        echo -e "-----------------------------------------\n"

        read -p "Enter the number of the database you want to drop: " selected_number
        database_name=$(ls -d */ 2>/dev/null | tr -d / | sed -n "${selected_number}p")

        if [ -n "$database_name" ]; then
            rm -r "$database_name" 2>/dev/null
            echo -e "\n-----------------------------------------"
            echo "Database '$database_name' dropped successfully."
            echo "-----------------------------------------\n"
        else
            echo -e "\n-----------------------------------------"
            echo "Invalid selection. Please enter the number corresponding to the database you want to drop."
            echo "-----------------------------------------\n"
        fi
    else
        echo -e "\n-----------------------------------------"
        echo "No databases found."
        echo "-----------------------------------------\n"
    fi
}
