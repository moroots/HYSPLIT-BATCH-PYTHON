@echo off
rem BATCH file to SET profile run 

rem *************************************************************
rem  this section reads in all the arguments (unlimited!)        
rem  and assigns them as paramter_1, parameter_2, etc, ...       
rem *************************************************************
SETLOCAL ENABLEDELAYEDEXPANSION
SET previous=0
:Loop
IF "%1"=="" GOTO Continue
SET /A parameter_number=%previous% + 1
SET parameter_!parameter_number!=%1
SET previous=!parameter_number!
SHIFT
GOTO Loop
:Continue
rem *************************************************************

rem replaceable parameters: 

rem parameter #1: directory for met files
rem parameter #2: name of met file
rem parameter #3: latitude
rem parameter #4: longitude
rem parameter #5: output time offset (hrs)
rem parameter #6: output time interval (hrs)
rem parameter #7: hours after start time to stop output (hrs)
rem parameter #8: wind dir instead of components = 1
rem parameter #9: run name

SET metdir=%parameter_1%
SET metfile=%parameter_2%
SET latitude=%parameter_3%
SET longitude=%parameter_4%
SET offset=%parameter_5%
SET interval=%parameter_6%
SET stop_hrs=%parameter_7%
SET wind_dir=%parameter_8%
SET run_name=%parameter_9%

echo          metdir = %metdir%
echo         metfile = %metfile%
echo        latitude = %latitude%
echo       longitude = %longitude%
echo          offset = %offset%
echo        interval = %interval%
echo        stop_hrs = %stop_hrs%
echo        wind_dir = %wind_dir%
echo        run_name = %run_name%

IF EXIST profile.txt DEL profile.txt
IF EXIST MESSAGE DEL MESSAGE
IF EXIST WARNING DEL WARNING

SET executable=..\exec\profile

rem C:\hysplit4\working_vmixing_tutorial>..\exec\profile
rem  Usage: profile [-options]
rem    -d[Input metdata directory name with ending /]
rem   -f[input metdata file name]
rem   -y[Latitude]
rem   -x[Longitude]
rem   -o[Output time offset (hrs)]
rem   -t[Output time interval (hrs)]
rem   -n[Hours after start time to stop output (hrs))]
rem   -w[Wind direction instead of components=1]
rem   -p[process ID number for output text file]
rem   -e[extra digit in output values (0)-no,1-yes]

rem  NOTE: leave no space between option and value

%executable% -d%metdir% -f%metfile% -y%latitude% -x%longitude% -o%offset% -t%interval% -n%stop_hrs% -w%wind_dir%

IF EXIST profile.%run_name%.txt DEL profile.%run_name%.txt
IF EXIST profile.txt rename profile.txt profile.%run_name%.txt

IF EXIST WARNING.profile.%run_name%.txt DEL WARNING.profile.%run_name%.txt
IF EXIST WARNING rename WARNING WARNING.profile.%run_name%.txt

IF EXIST MESSAGE.profile.%run_name%.txt DEL MESSAGE.profile.%run_name%.txt
IF EXIST MESSAGE rename MESSAGE MESSAGE.profile.%run_name%.txt

SET RESULTS_BASE_DIR=..\results
rem if base results directory does not exist, create it:
IF NOT EXIST %RESULTS_BASE_DIR% mkdir %RESULTS_BASE_DIR%

SET RESULTS_DIR=!RESULTS_BASE_DIR!\profile\
IF NOT EXIST !RESULTS_DIR! mkdir !RESULTS_DIR!

rem move output files to results directory
IF EXIST profile.%run_name%.txt  MOVE profile.%run_name%.txt %RESULTS_DIR%
IF EXIST WARNING.profile.%run_name%.txt  MOVE WARNING.profile.%run_name%.txt %RESULTS_DIR%
IF EXIST MESSAGE.profile.%run_name%.txt  MOVE MESSAGE.profile.%run_name%.txt %RESULTS_DIR%

