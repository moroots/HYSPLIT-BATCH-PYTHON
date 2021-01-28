@ECHO OFF

rem ***************************
rem REPLACEABLE PARAMETERS     
rem ***************************

rem STRUCTURE OF RUN, SET BAT FILES
rem  parameters  #1-5: start year, month, day, hour, minute (UTC)
rem  parameter     #6: latitude
rem  parameter     #7: longitude
rem  parameter     #8: starting height
rem  parameter     #9: KMSL (0=AGL, 1=MSL, 2=fraction of PBL)
rem  parameter    #10: run duration (hrs)
rem  parameter    #11: direction (FORWARD or BACKWARD)
rem  parameter    #12: run name
rem  parameter    #13: met data directory
rem  parameter    #14: met data file #1
rem  parameter    #15: met data file #2
rem  parameter    #16: output delta (minutes)
rem  parameter    #17: Environment (1=NOAA, …)
rem  parameter    #18: Results Sub-Directory (e.g., subdirectory of ..\results\)

rem ************** WRF d01 ***********************
SET metdir=D:\HYSPLIT_Stuff\MetData\WRF\d01\
SET metfile_01=wrfout_d01_20180701.ARL
SET metfile_02=wrfout_d01_20180630.ARL

call SET_TRAJ_DOS_001 18 07 01 11 00 39.242 -76.363 50.0 0 12 BACKWARD HMI_20180701_1100_100m_d02 %metdir% %metfile_01% %metfile_02% 10 1 HMI_20180701_1100
call SET_TRAJ_DOS_001 18 07 01 11 00 39.242 -76.363 100.0 0 12 BACKWARD HMI_20180701_1100_100m_d01 %metdir% %metfile_01% %metfile_02% 10 1 HMI_20180701_1100
call SET_TRAJ_DOS_001 18 07 01 11 00 39.242 -76.363 100.0 0 12 BACKWARD HMI_20180701_1100_100m_d01 %metdir% %metfile_01% %metfile_02% 10 1 HMI_20180701_1100
call SET_TRAJ_DOS_001 18 07 01 11 00 39.242 -76.363 100.0 0 12 BACKWARD HMI_20180701_1100_500m_d01 %metdir% %metfile_01% %metfile_02% 10 1 HMI_20180701_1100

rem ************** WRF d02 ***********************
SET metdir=D:\HYSPLIT_Stuff\MetData\WRF\d02\
SET metfile_01=wrfout_d02_20180701.ARL
SET metfile_02=wrfout_d02_20180630.ARL

call SET_TRAJ_DOS_001 18 07 01 11 00 39.242 -76.363 50.0 0 12 BACKWARD HMI_20180701_1100_50m_d02 %metdir% %metfile_01% %metfile_02% 10 1 HMI_20180701_1100
call SET_TRAJ_DOS_001 18 07 01 11 00 39.242 -76.363 100.0 0 12 BACKWARD HMI_20180701_1100_100m_d02 %metdir% %metfile_01% %metfile_02% 10 1 HMI_20180701_1100
call SET_TRAJ_DOS_001 18 07 01 11 00 39.242 -76.363 300.0 0 12 BACKWARD HMI_20180701_1100_300m_d02 %metdir% %metfile_01% %metfile_02% 10 1 HMI_20180701_1100
call SET_TRAJ_DOS_001 18 07 01 11 00 39.242 -76.363 500.0 0 12 BACKWARD HMI_20180701_1100_500m_d02 %metdir% %metfile_01% %metfile_02% 10 1 HMI_20180701_1100

rem ************** WRF d03 ***********************
SET metdir=D:\HYSPLIT_Stuff\MetData\WRF\d03\
SET metfile_01=wrfout_d03_20180701.ARL
SET metfile_02=wrfout_d03_20180630.ARL

call SET_TRAJ_DOS_001 18 07 01 11 00 39.242 -76.363 50.0 0 12 BACKWARD HMI_20180701_1100_50m_d03 %metdir% %metfile_01% %metfile_02% 10 1 HMI_20180701_1100
call SET_TRAJ_DOS_001 18 07 01 11 00 39.242 -76.363 100.0 0 12 BACKWARD HMI_20180701_1100_100m_d03 %metdir% %metfile_01% %metfile_02% 10 1 HMI_20180701_1100
call SET_TRAJ_DOS_001 18 07 01 11 00 39.242 -76.363 300.0 0 12 BACKWARD HMI_20180701_1100_300m_d03 %metdir% %metfile_01% %metfile_02% 10 1 HMI_20180701_1100
call SET_TRAJ_DOS_001 18 07 01 11 00 39.242 -76.363 500.0 0 12 BACKWARD HMI_20180701_1100_500m_d03 %metdir% %metfile_01% %metfile_02% 10 1 HMI_20180701_1100





echo(
echo --------------------------------------
echo Have just attempted to do one trajectory 
echo --------------------------------------
echo When first trying to run script, it is suggested to exit from script
echo at this point by hitting "CONTROL-C", and then replying "y" to exit
echo in response to the "Terminate Batch Job (Y/N)" query
echo --------------------------------------
echo You can examine the terminal outputs above to see if any obvious errors
echo And also, you can examine "results" directory to see if script is working as desired
echo --------------------------------------
echo For example, this script assumes that the global_reanalysis met data being used 
echo is in the following directory: ..\metdata\global_reanalysis\, 
echo and that these files are present in that directory: RP198309.gbl and RP198310.gbl
echo These files can be obtained from: ftp://arlftp.arlhq.noaa.gov/pub/archives/reanalysis
echo --------------------------------------
echo Once you are satisifed that things are working, you can run the script and 
echo just hit any key at this point to continue on with the remaining 111 runs
echo --------------------------------------
echo(

pause

