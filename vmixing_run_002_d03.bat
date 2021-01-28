@echo off
rem   BATCH file to RUN vmixing

SETLOCAL ENABLEDELAYEDEXPANSION

rem   parameters for vmixing_run_001 and vmixing_set_001:

rem   parameter #1: latitude
rem   parameter #2: longitude
rem   parameter #3: start height
rem   parameter #4: directory for met file
rem   parameter #5: name of met file
rem   parameter #6: run name
rem   parameter #7: stability method (KBLS)
rem   parameter #8: PBL mixing scheme (KBLT)
rem   parameter #9: Optional ouptut variables
rem   parameter #10: start yr
rem   parameter #11: start mo
rem   parameter #12: start da
rem   parameter #13: start hr
rem   parameter #14: number of hours to run
rem   parameter #15: KMIXD - mixed layer obtained from 0:input; 1: temperature; 2: TKE; 3: modified Richardson Number
rem   parameter #16: KMIX0 - minimum mixing depth (meters)

rem   the user will need to specify what directory the specified met data files are in
rem   this is the directory that was used during the testing of this script

SET METDATA_DIRECTORY=I:\ARCHIVE\MET_DATA\WRF_OWLETS2\

rem   here is the first run... 

rem CALL vmixing_set_001 39.242 -76.363 0.0 %METDATA_DIRECTORY% wrfout_d01_20180701.ARL vmixing_20180701_d01_KMIXD_0_KMIX0_0 1 2 2 00 00 00 00 9999 0 0

rem   a "pause" command is inserted here so that the user can stop the script (with a CNTL-C) 
rem   if there are abvious errors in carrying out the first run
rem   otherwise, any key can be pressed and the script will continue
rem   this is particularly important if you are doing a lot of different runs in a
rem   script and want to make sure it is working before it tries the subsequent runs.
pause
rem CALL vmixing_set_001 39.242 -76.363 0.0 %METDATA_DIRECTORY% wrfout_d01_20180701.ARL vmixing_20180701_d01_KMIXD_1_KMIX0_0 1 2 2 00 00 00 00 9999 1 0
rem CALL vmixing_set_001 39.242 -76.363 0.0 %METDATA_DIRECTORY% wrfout_d01_20180701.ARL vmixing_20180701_d01_KMIXD_2_KMIX0_0 1 2 2 00 00 00 00 9999 2 0
rem CALL vmixing_set_001 39.242 -76.363 0.0 %METDATA_DIRECTORY% wrfout_d01_20180701.ARL vmixing_20180701_d01_KMIXD_3_KMIX0_0 1 2 2 00 00 00 00 9999 3 0

rem CALL vmixing_set_001 39.242 -76.363 0.0 %METDATA_DIRECTORY% wrfout_d03_20180701.ARL vmixing_20180701_d03_KMIXD_0_KMIX0_0 1 2 2 00 00 00 00 9999 0 0

CALL vmixing_set_001 39.242 -76.363 0.0 %METDATA_DIRECTORY% wrfout_d03_20180701.ARL vmixing_20180701_d03_KMIXD_1_KMIX0_0 1 2 2 00 00 00 00 9999 1 0
CALL vmixing_set_001 39.242 -76.363 0.0 %METDATA_DIRECTORY% wrfout_d03_20180701.ARL vmixing_20180701_d03_KMIXD_2_KMIX0_0 1 2 2 00 00 00 00 9999 2 0
CALL vmixing_set_001 39.242 -76.363 0.0 %METDATA_DIRECTORY% wrfout_d03_20180701.ARL vmixing_20180701_d03_KMIXD_3_KMIX0_0 1 2 2 00 00 00 00 9999 3 0







