#!/bin/bash

function createTable() {
    read -p "Enter table name: " tbName
    if [[ -f $tbName || -f $(echo "$tbName" | tr '[:upper:]' '[:lower:]') ]]; then
        echo "Invalid input! There is an existing table named $tbName !"
        createTable

    elif [[ $tbName =~ ^[0-9]+$ ]]; then
        echo "Invalid input! name of table can't be only numbers!"
        createTable

    elif [[ $tbName =~ ^[0-9] ]]; then
        echo "Invalid input! name of table can't start with numbers!"
        createTable

    elif [[ $tbName == *" "* ]]; then
        echo "Invalid input! name of table can't contain spaces.!"
        createTable
    elif [[ $tbName == *[!a-zA-Z0-9_]* ]]; then
        echo "Invalid input! name of table can't contain a spacial charctars.!"
        createTable
    elif [ ! -n "$tbName" ]; then
        echo "Invalid input! name of table can't be empty.!"
        createTable
    else
        if [ -f $tbName.meta ]; then
            rm $tbName.meta
        fi
        touch $tbName.meta
        createColumns $tbName
    fi
}

function createColumns() {
    read -p "How many columns dose the table contain ?  " cmNum
    if [[ ! $cmNum =~ ^[0-9]+$ ]] || [[ ! -n "$cmNum" ]] || [[ $cmNum -lt 2 ]]; then
        echo " Invalid input! you input must be numbers only and not null and greter than 2 "
        createColumns
    fi
    for ((i = 1; i <= $cmNum; i++)); do
        read -p "Enter $i column name: " cmName
        if [[ ! -n $cmName ]] || [[ ! $cmName =~ ^[a-zA-Z] ]] || [[ $cmName == *" "* ]] || [[ $cmName == *[!a-zA-Z0-9_]* ]]; then
            echo " Invalid input! Column name must start with a letter it can't start with numbers only and can't contain a spacial charctars or spaces.!"
            i=$i-1

        elif grep -i -w "$cmName" $1.meta >/dev/null; then
            echo "This column is alredy exist "
            i=$i-1

        else
            echo -n $cmName >>$1.meta
            while true; do
                echo "
Enter the column data type
1-:Integer
2-:varchar
3-:exit
"
                read choise
                case $choise in
                1)
                    echo -e -n ":Integer\n" >>$1.meta
                    break
                    ;;
                2)
                    echo -e -n ":varchar\n" >>$1.meta
                    break
                    ;;

                3)
                    rm $1.meta
                    exit
                    ;;
                *) echo "Invalid choice. Please try again." ;;
                esac
            done
        fi
    done
    while true; do
        read -p " Enter the name of column that you want to assign as primary key ?  " pk
        if grep -i -w "$pk" $1.meta >/dev/null; then
            sed -i'' "/$pk/s/$/:pk/" $1.meta
            break
        else
            echo "Invalid input, please enter an exit column name "
        fi
    done
    touch $1
    echo "Table '$1' created successfully."
}

function insertIntoTable() {
    read -p "Enter the table name: " tableName
    if [[ -f $tableName ]]; then
        echo "Columns in the table:"
        awk -F: '{print $1}' "$tableName.meta"

        numColumns=$(awk -F: '{print $1}' "$tableName.meta" | wc -w)
        columnNames=$(awk -F: '{print $1}' "$tableName.meta")

        while true; do
            declare -A columnValues

            for ((i = 1; i <= $numColumns; i++)); do

                read -p "Enter value for column $(echo $columnNames | cut -d' ' -f$i): " inputValue
                dataType=$(awk -v i=$i -F: '{if (NR==i) {print $2}}' "$tableName.meta")
                case $dataType in
                "Integer")
                    if ! [[ $inputValue =~ ^[0-9]+$ ]]; then
                        echo "Invalid input! This column must be an integer."
                        break
                    else
                        columnValues[$i]=$inputValue

                    fi
                    ;;
                "varchar")
                    if [[ ! $inputValue =~ ^[a-zA-Z_] ]]; then
                        echo "Invalid input this column Must start with letter or '_' "
                        break
                    else
                        columnValues[$i]=$inputValue

                    fi
                    ;;
                esac
            done

            if (($i - 1 == $numColumns)); then
                pKeyCloumn=$(grep -n "pk" "$tableName.meta" | cut -d: -f1)
                if grep -i -w "${columnValues[$pKeyCloumn]}" $tableName >/dev/null; then
                    echo " can't insert the data because you tried to repeat the value into the primary key"
                    break
                else
                    for ((i = 1; i <= ${#columnValues[@]}; i++)); do
                        if (($i == ${#columnValues[@]})); then
                            echo -e -n "${columnValues[$i]}\n" >>$tableName
                        else
                            echo -n "${columnValues[$i]}:" >>$tableName
                        fi
                    done
                    echo "Data inserted into table '$tableName' successfully."
                    break
                fi
            fi
        done

    else
        echo "Table '$tableName' not found."
    fi
}

function listTables() {
    tables=$(ls | grep -v 'meta')
    if [ -n "$tables" ]; then
        echo -e "\n-----------------------------------------"
        echo "List of existing tables:"
        echo -e "-----------------------------------------"
        echo -e "| No.     | Table Name                    |"
        echo -e "-----------------------------------------"
        echo -e "$tables" | nl -w7 -s" | " | sed 's/^/| /;s/$/                         |/'
        echo -e "-----------------------------------------"
    else
        echo -e "\n-----------------------------------------"
        echo "No tables found in the current database."
        echo "-----------------------------------------"
    fi
}

function selectFromTable() {
    read -p "Enter the table name: " tableName
    if [[ -f $tableName ]]; then
        if [ ! -s "$tableName" ]; then
            echo "Table '$tableName' is empty. No data to select."
            return
        fi

        echo "Columns in the table:"
        awk -F: '{print $1}' "$tableName.meta"

        echo -e "\n-----------------------------------------"
        echo "Select Options:"
        echo "1. Retrieve all rows"
        echo "2. Retrieve a specific row by primary key"
        echo "3. Return to the previous menu"
        echo "-----------------------------------------"

        echo -n "$PS3"
        read selectOption

        case $selectOption in
        1)
            awk -F: '{print $0}' "$tableName"
            ;;
        2)
            pKeyColumn=$(grep -n "pk" "$tableName.meta" | cut -d: -f1)
            read -p "Enter the primary key value: " primaryKeyValue

            if grep -i -w "$primaryKeyValue" "$tableName" >/dev/null; then
                awk -v pKeyColumn="$pKeyColumn" -v primaryKeyValue="$primaryKeyValue" -F: '{if ($pKeyColumn == primaryKeyValue) print $0}' "$tableName"
            else
                echo "Row with primary key '$primaryKeyValue' not found in table '$tableName'."
            fi
            ;;
        3)
            return
            ;;
        *)
            echo "Invalid choice. Please select a number corresponding to the options."
            ;;
        esac
    else
        echo "Table '$tableName' not found."
    fi
}
function dropTable() {
    tables=$(ls | grep -v 'meta' 2>/dev/null)
    numTables=$(echo "$tables" | wc -l)

    if [ "$numTables" -eq 0 ]; then
        echo -e "\n-----------------------------------------"
        echo "No tables found in the current database."
        echo "-----------------------------------------"
        return
    fi

    echo -e "\n-----------------------------------------"
    echo "List of existing tables:"
    echo -e "-----------------------------------------"
    echo -e "| No.     | Table Name                    |"
    echo -e "-----------------------------------------"
    echo -e "$tables" | nl -w7 -s" | " | sed 's/^/| /;s/$/                         |/'
    echo -e "-----------------------------------------"

    read -p "Enter the number of the table you want to drop: " selected_number

    if [[ "$selected_number" =~ ^[0-9]+$ ]] && [ "$selected_number" -gt 0 ] && [ "$selected_number" -le "$numTables" ]; then
        tableName=$(echo "$tables" | sed -n "${selected_number}p")

        read -p "Are you sure you want to drop table '$tableName'? (yes/no): " confirmation
        if [ "$confirmation" = "yes" ]; then
            rm "$tableName" "$tableName.meta" 2>/dev/null
            echo -e "\n-----------------------------------------"
            echo "Table '$tableName' dropped successfully."
            echo "-----------------------------------------"
        else
            echo -e "\n-----------------------------------------"
            echo "Table '$tableName' was not dropped."
            echo "-----------------------------------------"
        fi
    else
        echo -e "\n-----------------------------------------"
        echo "Invalid selection. Please enter a valid table number."
        echo "-----------------------------------------"
    fi
}

function deleteFromTable() {
    read -p "Enter the table name: " tableName
    if [[ -f $tableName ]]; then
        if [ ! -s "$tableName" ]; then
            echo "Table '$tableName' is empty. No data to delete."
            return
        fi

        echo "Columns in the table:"
        awk -F: '{print $1}' "$tableName.meta"

        echo -e "\n-----------------------------------------"
        echo "Delete Options:"
        echo "1. Delete all rows"
        echo "2. Delete a specific row by primary key"
        echo "3. Return to the previous menu"
        echo "-----------------------------------------"

        echo -n "$PS3"
        read deleteOption

        case $deleteOption in
        1)
            >"$tableName"
            echo "All rows deleted from table '$ntableName'."
            ;;
        2)
            pKeyColumn=$(grep -n "pk" "$tableName.meta" | cut -d: -f1)
            read -p "Enter the primary key value: " primaryKeyValue

            if grep -i -w "$primaryKeyValue" "$tableName" >/dev/null; then
                awk -v pKeyColumn="$pKeyColumn" -v primaryKeyValue="$primaryKeyValue" -F: '{if ($pKeyColumn != primaryKeyValue) print $0}' "$tableName" >"$tableName.tmp"
                mv "$tableName.tmp" "$tableName"
                echo "Row with primary key '$primaryKeyValue' deleted from table '$tableName'."
            else
                echo "Row with primary key '$primaryKeyValue' not found in table '$tableName'."
            fi
            ;;
        3)
            return
            ;;
        *)
            echo "Invalid choice. Please select a number corresponding to the options."
            ;;
        esac
    else
        echo "Table '$tableName' not found."
    fi
}

function updateTable() {
    echo "Choose update method:"
    echo "1. Update a single value"
    echo "2. Update column"
    echo "3. Return to previous menu"

    read -p "Enter your choice: " choice

    case $choice in
    1)
        update_single_value
        ;;
    2)
        update_column
        ;;
    3)
        echo "Returning to the previous menu..."
        ;;
    *)
        echo "Invalid choice. Please select a valid option."
        choose_update_method
        ;;
    esac
}

function update_single_value() {
    read -p "Enter the name of the table you want to update: " tableName
    if [[ -f $tableName ]]; then
        if [ ! -s "$tableName" ]; then
            echo "Table '$tableName' is empty. Nothing to update."
            return
        fi

        echo "Columns in the table:"
        awk -F: '{print $1}' "$tableName.meta"

        read -p "Enter the primary key value of the row you want to update: " primaryKeyValue

        # Check if the primary key exists in the table
        pKeyColumn=$(grep -n "pk" "$tableName.meta" | cut -d: -f1)
        if ! grep -i -w "$primaryKeyValue" "$tableName" >/dev/null; then
            echo "Row with primary key '$primaryKeyValue' not found in table '$tableName'."
            return
        fi

        read -p "Enter the column name you want to update: " columnName

        # Check if the column exists in the table
        if ! grep -w "$columnName" "$tableName.meta" >/dev/null; then
            echo "Column '$columnName' not found in table '$tableName'."
            return
        fi

        # Find the column number
        colNumber=$(awk -F: -v col="$columnName" '$1 == col {print NR}' "$tableName.meta")

        read -p "Enter the new value for column '$columnName': " newValue

        # Validate the new value to prevent special characters
        if [[ $newValue =~ [^a-zA-Z0-9_] ]]; then
            echo "Invalid input! The new value cannot contain special characters."
            return
        fi

        # Validate new value based on data type
        dataType=$(awk -F: -v colNum="$colNumber" 'NR == colNum {print $2}' "$tableName.meta")
        case $dataType in
        "Integer")
            if ! [[ $newValue =~ ^[0-9]+$ ]]; then
                echo "Invalid input! This column must be an integer."
                return
            fi
            ;;
        "varchar")
            # No need for additional validation for varchar
            ;;
        *)
            echo "Unknown data type '$dataType' for column '$columnName'."
            return
            ;;
        esac

        # Check if new primary key value conflicts with existing ones
        if grep -i -w "$newValue" "$tableName" | grep -v -w "$primaryKeyValue" >/dev/null; then
            echo "Error: New primary key value '$newValue' conflicts with existing values."
            return
        fi

        # Update the row
        awk -v primaryKey="$primaryKeyValue" -v colNum="$colNumber" -v pKeyCol="$pKeyColumn" -v newVal="$newValue" -F: 'BEGIN{OFS=":"} {if ($pKeyCol == primaryKey) $colNum = newVal; print}' "$tableName" >"$tableName.tmp"

        if mv "$tableName.tmp" "$tableName"; then
            echo "Row with primary key '$primaryKeyValue' updated successfully in table '$tableName'."
        else
            echo "Error updating row in table '$tableName'."
        fi
    else
        echo "Table '$tableName' not found."
    fi
}

function update_column() {
    read -p "Enter the name of the table you want to update: " tableName

    if [[ -f $tableName ]]; then
        if [ ! -s "$tableName" ]; then
            echo "Table '$tableName' is empty. Nothing to update."
            return
        fi

        echo "Columns in the table:"
        awk -F: '{print $1}' "$tableName.meta"

        read -p "Enter the column name that you want to update: " columnName
        pKeyCloumn=$(grep -n "pk" "$tableName.meta" | cut -d: -f2)
        if [[ "$pKeyCloumn" == "$columnName" ]]; then

            echo " This column is the primary key you can't update all data in it because it's not allowed to repeat the same values into the primary key column"

        else
            tableColumns=$(awk -F: '{print $1}' "$tableName.meta")

            if grep -i -w "$columnName" <<<"$tableColumns" >/dev/null; then
                read -p "Enter the new value that you want to insert: " inputValue
                dataType=$(awk -v i=$columnName -F: '{if ($1==i) {print $2}}' "$tableName.meta")
                numRaws=$(awk -F: '{print NR}' "$tableName" | wc -w)

                case $dataType in
                "Integer")
                    if ! [[ $inputValue =~ ^[0-9]+$ ]]; then
                        echo "Invalid input! This column must be an integer."

                    else

                        CloumnSq=$(grep -n "$columnName" "$tableName.meta" | cut -d: -f1)
                        columnsalues=$(awk -v i=$CloumnSq -F: '{print $i}' "$tableName")

                        for i in $columnsalues; do

                            sed -i "s/$i/$inputValue/" $tableName

                        done

                    fi
                    ;;
                "varchar")
                    if [[ ! $inputValue =~ ^[a-zA-Z_] ]]; then
                        echo "Invalid input this column Must start with letter or '_' "

                    else

                        CloumnSq=$(grep -n "$columnName" "$tableName.meta" | cut -d: -f1)
                        columnsalues=$(awk -v i=$CloumnSq -F: '{print $i}' "$tableName")

                        for i in $columnsalues; do
                            sed -i "s/$i/$inputValue/" $tableName

                        done
                    fi

                    ;;
                esac

            else
                echo -e "\n-----------------------------------------"
                echo "Column '$columnName' not found."
                echo "-----------------------------------------"
            fi
        fi
    else
        echo -e "\n-----------------------------------------"
        echo "Table '$tableName' not found."
        echo "-----------------------------------------"
    fi
}
