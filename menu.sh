#!/bin/bash

PS3="Select the number of your choice: "
function baseMenu() {
    select option in "Create Database" "Show Databases" "Use Database" "Drop Database" "Exit"; do
        case $REPLY in
        1)
            createDatabase
            printMenu
            ;;
        2)
            listDatabases
            printMenu
            ;;
        3)
            connectDatabase
            printMenu
            ;;
        4)
            dropDatabase
            printMenu
            ;;
        5) exitShell ;;
        *) echo -e "\nInvalid choice. Please select a number corresponding to the options.\n" ;;
        esac
    done
}
