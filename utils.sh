#!/bin/bash
function printMenu() {
    echo -e "\n-----------------------------------------"
    echo "| Select the number of your choice:       |"
    echo "| 1. Create Database                      |"
    echo "| 2. Show Databases                       |"
    echo "| 3. Use Database                         |"
    echo "| 4. Drop Database                        |"
    echo "| 5. Exit                                 |"
    echo "-----------------------------------------"
}

function exitShell() {
    echo -e "\n-----------------------------------------"
    echo "Exiting the D Shell. Goodbye!"
    echo "-----------------------------------------\n"
    exit
}

