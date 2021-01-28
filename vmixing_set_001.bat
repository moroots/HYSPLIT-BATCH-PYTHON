@echo off
rem BATCH file to SET vmixing 

SET exec=..\exec\

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

rem parameter #1: latitude
rem parameter #2: longitude
rem parameter #3: start height
rem parameter #4: directory for met file
rem parameter #5: name of met file
rem parameter #6: run name
rem parameter #7: stability method (KBLS)
rem parameter #8: PBL mixing scheme (KBLT)
rem parameter #9: Optional ouptut variables
rem parameter #10: start yr
rem parameter #11: start mo
rem parameter #12: start da
rem parameter #13: start hr
rem parameter #14: number of hours to run
rem parameter #15: KMIXD
rem parameter #16: KMIX0

SET latitude=%parameter_1%
SET longitude=%parameter_2%
SET height=%parameter_3%
SET metdir=%parameter_4%
SET metfile=%parameter_5%
SET run_name=%parameter_6%
SET KBLS=%parameter_7%
SET KBLT=%parameter_8%
SET extra_variables=%parameter_9%
SET start_year=%parameter_10%
SET start_month=%parameter_11%
SET start_day=%parameter_12%
SET start_hour=%parameter_13%
SET run_hrs=%parameter_14%
SET KMIXD=%parameter_15%
SET KMIX0=%parameter_16%

echo        latitude = %latitude%
echo       longitude = %longitude%
echo          height = %height%
echo          metdir = %metdir%
echo         metfile = %metfile%
echo        run_name = %run_name%
echo            KBLS = %KBLS%
echo            KBLT = %KBLT%
echo extra_variables = %extra_variables%
echo      start_year = %start_year%
echo     start_month = %start_month%
echo       start_day = %start_day%
echo      start_hour = %start_hour%
echo         run_hrs = %run_hrs%
echo           KMIXD = %KMIXD%
echo           KMIX0 = %KMIX0%

rem *********************************************************************
rem   make the CONTROL file that vmixing will use for the simulation
rem *********************************************************************

rem *********************************************************************
rem 1. UTC Starting Time for the Simulation (year, month, day, hour)

rem        Default: 00 00 00 00 00
rem        Enter the two digit values for the UTC time that the calculation is to start.
rem        Use 0's to start at the beginning (or end) of the file according to the
rem        direction of the calculation. All zero values in this field will force the
rem        calculation to use the time of the first (or last) record of the meteorological
rem        data file. In the special case where year and month are zero, day, hour and minute 
rem        are treated as relative to the start or end of the file. For example, the first
rem        record of the meteorological data file usually starts at 0000 UTC. An entry of
rem        "00 00 01 12 00" would start the calculation 36 hours from the start of the data file.

rem        NOTE that as this is the first time writing to the file, there is a single ">"
rem        for subsequent writes, the ">>" symbol is used

ECHO %start_year% %start_month% %start_day% %start_hour% 00 >control.txt

rem **********************************************************************
rem 2. Number of Starting Locations

ECHO 1 >>control.txt

rem **********************************************************************
rem 3. Starting Location [lat,long, height (meters above ground)]

ECHO %latitude% %longitude% %height% >>control.txt

rem **********************************************************************
rem 4. Total Run Time for Simulation (hours)

rem 		Specifies the duration of the calculation in hours.
ECHO %run_hrs% >>control.txt

rem **********************************************************************
rem 5. Vertical motion option

rem			(0:data 1:isob 2:isen 3:dens 4:sigma 5:diverg 6:eta)
rem	    Indicates the vertical motion calculation method.
rem			The default "data" selection will use the meteorological model's
rem 		vertical velocity fields; other options include isobaric,
rem			isentropic, constant density, constant internal sigma coordinate,
rem			computed from the velocity divergence, and a special transformation
rem			to correct the vertical velocities when mapped from quasi-horizontal ETA
rem			surfaces to HYSPLIT's internal terrain following sigma coordinate.
ECHO 0 >>control.txt

rem **********************************************************************
rem 6. Top of model domain (internal coordinates m-agl)

rem 		Sets the vertical limit of the internal meteorological grid.
rem			If calculations are not required above a certain level, fewer meteorological
rem			data are processed thus speeding up the computation. Trajectories will
rem			terminate when they reach this level. A secondary use of this parameter is
rem			to set the model's internal scaling height - the height at which the
rem			internal sigma surfaces go flat relative to terrain. The default internal
rem			scaling height is set to 25 km but it is set to the top of the model
rem			domain if the entry exceeds 25 km. Further, when meteorological data are
rem			provided on terrain sigma surfaces it is assumed that the input data
rem			were scaled to a height of 20 km (RAMS) or 34.8 km (COAMPS). If a different
rem 		height is required to decode the input data, it should be entered on
rem			this line as the negative of the height. HYSPLIT's internal scaling height
rem			remains at 25 km unless the absolute value of the domain top exceeds 25 km.
ECHO 25000.0 >>control.txt

rem **********************************************************************
rem 7. Number of Input Data Grids

rem			Number of simultaneous input meteorological files. The following two entries
rem			(directory and name) will be repeated this number of times. A simulation
rem			will terminate when the computation is off all of the grids in either
rem			space or time. Trajectory calculations will check the grid each time
rem			step and use the finest resolution input data available at that location
rem			at that time. When multiple meteorological grids have different resolution,
rem			there is an additional restriction that there should be some overlap between
rem			the grids in time, otherwise it is not possible to transfer a trajectory
rem			position from one grid to another.

ECHO 1 >>control.txt

rem Meteorological data grid directory and file name

rem 		Default: ( \main\sub\data\ )
rem 		Directory location of the meteorological file on the grid specified.
rem			Always terminate with the appropriate slash (\ or /).

ECHO %metdir% >>control.txt
ECHO %metfile% >>control.txt

rem *************************************

rem IF EXIST CONTROL.%run_name% DEL CONTROL.%run_name%
rem copy control.txt CONTROL.%run_name%

IF EXIST CONTROL DEL CONTROL
copy control.txt CONTROL

rem *************************************
rem  DONE establishing CONTROL file      
rem *************************************

rem   **********************************************************************
rem   \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
rem   **********************************************************************
rem     ESTABLISH SETUP.CFG FILE
rem   **********************************************************************
rem     The SETUP.CFG namelist file is not required, and if not present in the root
rem     startup directory, default values are used.  These parameters can all be
rem     changed without recompilation by modification of the contents of SETUP.CFG
rem     and in some cases their modification will substantially change the nature
rem     of the simulation. The configuration file should be present in the root
rem     directory.

if exist setup.txt del setup.txt

echo ^&SETUP > setup.txt

rem Mixed Layer Depth Computation

rem   ---------------------------------------------------------------------------------
rem     KMIXD (0) - Mixed Layer Depth (new July-Aug 2008)
rem   ---------------------------------------------------------------------------------

rem KMIXD is used to control how the boundary layer depth is computed. 
rem In addition as acting as a vertical lid to particle dispersion (advection is not affected),
rem the mixed layer depth is also used to scale the boundary layer mixing coefficients
rem and computing turbulent fluxes from wind and temperature profiles. 
rem The default is to use the value provided by the meteorological model through the 
rem input data set. The profile can also be used if available. 
rem The computation defaults to use temperature profiles if the mixed layer field is not available.
rem Another option to use for testing is to replace the index value (0,1,2) 
rem with a value greater than 10. In this situation, that value will be used
rem as the mixed layer depth and will be constant for the duration of the simulation.

rem 0 = Use meteorological model MIXD if available (DEFAULT)
rem 1 = Compute from the temperature profile
rem 2 = Compute from the TKE profile
rem > = 10 use this value as a constant

rem echo  KMIXD  = 0,        >>setup.txt
echo  KMIXD  = %KMIXD% , >> setup.txt

rem   ---------------------------------------------------------------------------------
rem     KMIX0 (250) - Minimum Mixing Depth (new July-Aug 2008)
rem   ---------------------------------------------------------------------------------

rem KMIX0 is a related parameter that sets the minimum mixing depth. 
rem The earlier HYSPLIT default value was 150 meters and was related to the typical 
rem vertical resolution of the meteorological data. 
rem A resolution near the surface of 15 hPa is typical of pressure-level data files.
rem This suggests that it is difficult to infer a mixed layer depth of less
rem than 150 m (10 m per hPa) for most meteorological input data.

rem vertical resolution in met data files has been increasing and 
rem so the DEFAULT value has been decreased in recent years.
rem 50 = The current minimum mixing depth set in vmixing

rem echo  KMIX0  = 50,      >>setup.txt
echo  KMIX0  = %KMIX0% ,      >>setup.txt

rem   ---------------------------------------------------------------------------------
echo  /   >>setup.txt
rem   ---------------------------------------------------------------------------------

if exist SETUP.CFG del SETUP.CFG
rename setup.txt SETUP.CFG

rem IF EXIST SETUP.%run_name% DEL SETUP.%run_name%
rem copy SETUP.CFG SETUP.%run_name%

echo  finished creating CONTROL and SETUP.CFG

rem C:\hysplit4\working_vmixing_tutorial>..\exec\vmixing
rem  Creates a time series of meteorological stability parameters

rem  USAGE: vmixing (optional arguments)
rem  -p[process ID]
rem  -s[KBLS - stability method (1=default)]
rem  -t[KBLT - PBL mixing scheme (2=default)]
rem  -a[CAMEO optional variables (0[default]=No, 1=Yes, 2=Yes + Wind Direction]
rem  -m[TKEMIN - minimum TKE limit for KBLT=3 (0.001=default)]
rem  -w[an extra file for turbulent velocity variance (0[default]=No,1=Yes)]

rem %exec%vmixing -p!run_name! -s!KBLS! -t!KBLT! -a!extra_variables!
%exec%vmixing -s!KBLS! -t!KBLT! -a!extra_variables!

IF EXIST %run_name%.warn DEL %run_name%.warn
IF EXIST WARNING rename WARNING %run_name%.warn

IF EXIST %run_name%.ctl DEL %run_name%.ctl
IF EXIST CONTROL rename CONTROL %run_name%.ctl

IF EXIST %run_name%.stability.txt DEL %run_name%.stability.txt
IF EXIST STABILITY..txt rename STABILITY..txt %run_name%.stability.txt

IF EXIST %run_name%.cfg DEL %run_name%.cfg
IF EXIST SETUP.CFG rename SETUP.CFG %run_name%.cfg

IF EXIST %run_name%.msg DEL %run_name%.msg
IF EXIST MESSAGE..txt rename MESSAGE..txt %run_name%.msg

SET RESULTS_BASE_DIR=..\results
rem if base results directory does not exist, create it:
IF NOT EXIST %RESULTS_BASE_DIR% mkdir %RESULTS_BASE_DIR%

SET RESULTS_DIR=!RESULTS_BASE_DIR!\vmixing\
IF NOT EXIST !RESULTS_DIR! mkdir !RESULTS_DIR!

rem move output files to results directory
IF EXIST %run_name%.ctl  MOVE %run_name%.ctl %RESULTS_DIR%
IF EXIST %run_name%.cfg  MOVE %run_name%.cfg %RESULTS_DIR%
IF EXIST %run_name%.msg  MOVE %run_name%.msg %RESULTS_DIR%
IF EXIST %run_name%.warn  MOVE %run_name%.warn %RESULTS_DIR%
IF EXIST %run_name%.stability.txt  MOVE %run_name%.stability.txt %RESULTS_DIR%





