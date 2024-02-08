#  Database Management System (D Shell)

## Introduction
D Shell is a simple shell script-based database management system (DBMS) that uses cute cat ASCII art as its mascot. It allows users to create, manage, and manipulate databases and tables using a command-line interface.

## Features
- Create, list, use, and drop databases
- Create, list, drop, insert into, select from, delete from, and update tables
- Define table columns with data types
- Assign primary keys to tables
- Input validation for user inputs
- Cute cat ASCII art for aesthetic appeal

## Files

1. *catFace.sh*: Contains the function to display a cute cat ASCII art.
2. *banner.sh*: Contains the function to display the welcome banner.
3. *menu.sh*: Defines the base menu for the user to interact with the system.
4. *database.sh*: Handles database-related operations such as creation and deletion.
5. *tables.sh*: Manages table-related operations such as creation, deletion, and manipulation.
6. *actions.sh*: Implements functions for various actions like creating, listing, and updating tables.
7. *utils.sh*: Contains utility functions used across the system.
8. *main.sh*: The main script file that executes the D Shell program.

## How to Use
1. Clone the repository to your local machine.
2. Ensure that you have bash installed.
3. Navigate to the directory containing the scripts.
4. Run `chmod +x *` to give excute permission to the files.
5. Run the main.sh script using the command `./main.sh`
6. Follow the on-screen instructions to interact with the D Shell program.
