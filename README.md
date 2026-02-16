                                 Student Attendance Tracker – Project Factory

                                          
                                                        Project Overview

This project is an  automatic Student Attendance Tracker project workspace.  It builds the required folders and files, allows you to update attendance thresholds, and checks if Python 3 is installed on your system
     
The script functionability and executability .

Creates the required directory structure
Generates all necessary project files
Allows dynamic configuration using command-line input
Handles system interrupts safely using signal traps
Performs environment validation before completion
 
 
                                    When script executed   

Create the following file structure .
  
attendance_tracker_<input>/
├── attendance_checker.py
├── Helpers/
│   ├── assets.csv
│   └── config.json
└── reports/
    └── reports.log

 NB: you have to replace <input>/  with project name like ex: v1 or v2


            How to run the script
 
Make the script executable by (chmod u+x script file name)

Run the script with project name .(./setup_project.sh <project name>)


     2. Dynamic configuration

During the execution user is prompted to update attendance thresholds:
   
        - Warning threshold (default: 75%)
        - Failure threshold (default: 50%)

 Clicking enter will keep default thresholds .

N.B: Based on the user input the script uses `sed` to edit and update values inside config.json file as the file controls how the system behaves.

3.Signal Handling (Process Management)


The archive feature activates if you interrupt the script while it is running

To trigger it : 
 Start the script as usual 
Start the script normally (ctrl +c)

N.B: When the script is interrupted the current state of the project directory is archived as attendance_tracker_<project_name>_archive.tar.gz  and the archive contains exactly what had been created at the moment you stopped the script

The incomplete project directory is deleted to keep the workspace clean .

 
4.Environment Validation


Before finishing setup , the script verifies 

Whether `python3` is installed (python3 --version) .
A confirmation or warning message is printed accordingly .

