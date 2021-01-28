@echo off
rem BATCH file to RUN profile

SETLOCAL ENABLEDELAYEDEXPANSION

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

rem SET metdir=I:\ARCHIVE\MET_DATA\WRF_OWLETS2\
SET metdir=D:\HYSPLIT_Stuff\MetData\WRF\d01\
SET metfile=wrfout_d01_20180701.ARL
SET latitude=39.242
SET longitude=-76.363
SET offset=0
SET interval=1
SET duration=9999
SET wdir=1
SET run_name=!metfile!

call profile_set_001 %metdir% %metfile% %latitude% %longitude% %offset% %interval% %duration% %wdir% %run_name%






