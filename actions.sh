#!/bin/bash

function chooseAction() {
    while true; do
        echo -e "\n-----------------------------------------"
        echo "Choose an action:"
        echo "| 1. Create Table                           |"
        echo "| 2. List Tables                            |"
        echo "| 3. Drop Table                             |"
        echo "| 4. Insert into Table                      |"
        echo "| 5. Select from Table                      |"
        echo "| 6. Delete from Table                      |"
        echo "| 7. Update Table                           |"
        echo "| 8. Return to Previous Menu                |"
        echo "| 9. Exit Shell                             |"
        echo "-----------------------------------------"

        echo -n "Enter your choice: "
        read choice

        case $choice in
        1) createTable ;;
        2) listTables ;;
        3) dropTable ;;
        4) insertIntoTable ;;
        5) selectFromTable ;;
        6) deleteFromTable ;;
        7) updateTable ;;
        8)
            disconnectDatabase
            printMenu
            return
            ;;
        9) exitShell ;;
        *)
            echo -e "\n-----------------------------------------"
            echo "Invalid choice. Please select a number corresponding to the options."
            echo "-----------------------------------------\n"
            ;;
        esac
    done
}
