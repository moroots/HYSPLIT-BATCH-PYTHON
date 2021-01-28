@ECHO OFF

rem example SET file to carry out BACK TRAJECTORY simulations

rem TRAJ_SET_DOS_001: for trajectory simulations corresponding to the Tutorial frequency section 6.1

rem if set PAUSES to 1, then script will include pauses at key points, useful for debugging
rem otherwise, there will be no pauses
SET PAUSES=1
rem SET PAUSES=0

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

rem *************************************************************

SET start_year=%parameter_1%
rem   UTC starting year
echo start year = %start_year%

SET start_month=%parameter_2%
rem   UTC starting month
echo start month = %start_month%

SET start_day=%parameter_3%
rem   UTC starting day
echo start day = %start_day%

SET start_hour=%parameter_4%
rem   UTC starting hour
echo start hour = %start_hour%

SET start_minute=%parameter_5%
rem   UTC starting minute
echo start minute = %start_minute%

SET LAT=%parameter_6%
echo LAT = %LAT%

SET LONG=%parameter_7%
echo LONG = %LONG%

SET HEIGHT=%parameter_8%
echo HEIGHT = %HEIGHT%

SET KMSL=%parameter_9%
echo KMSL = %KMSL%

SET duration=%parameter_10%
rem   run duration in hours
echo run duration (hrs) = %duration%

SET direction=%parameter_11%
echo direction = %direction%

SET run_name=%parameter_12%
echo run name = %run_name%

SET metfile_dir=%parameter_13%
echo metfile_dir = %metfile_dir%

SET metfile_01=%parameter_14%
echo metfile_01 = %metfile_01%

SET metfile_02=%parameter_15%
echo metfile_02 = %metfile_02%

SET output_delta=%parameter_16%
echo output_delta = %output_delta%

SET ENVR=%parameter_17%
echo ENVR = %ENVR%

SET RESULTS_SUB_DIRECTORY=%parameter_18%
echo RESULTS_SUB_DIRECTORY = %RESULTS_SUB_DIRECTORY%

rem *************************************************************
rem   if %ENVR%==1 (
rem   ENVR=1 is for Mark's computer at NOAA, used for testing
rem *************************************************************

echo inside SET, ENVR = %ENVR%

if %ENVR%==1   goto ENVR_1
if %ENVR%==2   goto ENVR_2

:ENVR_1
rem  SET KEY DIRECTORIES
SET WORK_DIR=.\
SET RESULTS_BASE_DIR=..\results
SET EXEC_DIR=..\exec\
rem if results directory does not exist, create it:
IF NOT EXIST %RESULTS_BASE_DIR% mkdir %RESULTS_BASE_DIR%
rem directory for hyts_exec (do NOT include back slash at end)
SET hyts_exec_dir=..\exec
goto ENVR_end

:ENVR_2
rem right now same as ENVR=1, but, can be customized for any given local 
rem environment, on anyone's particular computer

rem  SET KEY DIRECTORIES
SET WORK_DIR=.\
SET RESULTS_BASE_DIR=..\results
SET EXEC_DIR=..\exec\
rem if results directory does not exist, create it:
IF NOT EXIST %RESULTS_BASE_DIR% mkdir %RESULTS_BASE_DIR%
rem directory for hyts_exec (do NOT include back slash at end)
SET hyts_exec_dir=..\exec
goto ENVR_end

:ENVR_end

echo ENVR has been set to %ENVR%

if %PAUSES%==1 pause

rem *************************************************************
rem   establish RESULTS directory                                
rem *************************************************************

SET RESULTS_DIR=%RESULTS_BASE_DIR%\%RESULTS_SUB_DIRECTORY%\

rem if results directory does not exist, create it:
IF NOT EXIST %RESULTS_DIR% mkdir %RESULTS_DIR%

echo have established results directory if it didn't already exist
if %PAUSES%==1 pause

rem *****************************************************************
rem   THE TYPE OF CONTROL FILE THAT THIS SET BATCH FILE CREATES      
rem *****************************************************************

rem    83 09 28 18                
rem    1                          
rem    39.90 -84.22 750.0         
rem    48                         
rem    0                          
rem    10000.0                    
rem    2                          
rem    C:/Tutorial/captex/        
rem    RP198309.gbl               
rem    C:/Tutorial/captex/        
rem    RP198310.gbl               
rem    ./                         
rem    fdump83092818              

rem *********************************************************************
rem   first we will create the CONTROL file that HYSPLIT uses
rem   to simulate the back-trajectory
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

ECHO %start_year% %start_month% %start_day% %start_hour% %start_minute% >control.txt

rem **********************************************************************
rem 2. Number of Starting Locations
rem					Default: 1

ECHO 1 >>control.txt

rem **********************************************************************

rem 3. Starting Location [lat,long, height (meters above ground)]
rem    ** NOTE that if we set KMSL = 2 in setup file below, then
rem       heights here are interpreted as fractions of the Planetary Boundary Layer (PBL)
rem       so, in that case, if height is set to 0.5, for example, 
rem       it means that the trajectory starts in the middle of the PBL for any given starting time.

rem       west longitudes are negative; south latitudes are negative

ECHO %LAT% %LONG% %HEIGHT% >>control.txt

rem **********************************************************************
rem 4. Total Run Time for Simulation (hours)

rem    		Default: 48

rem 		Specifies the duration of the calculation in hours.
rem 		Backward calculations are entered as negative hours.
rem 		A backward trajectory starts from the trajectory termination
rem     point and proceeds upwind.
rem   	Meteorological data are processed in reverse-time order.

rem     because of an issue in how HYSPLIT decides when to output to 
rem     the tdump file, must use a value 1 hour longer
rem     this relates to being able to start in the middle of an hour
rem     and still be able to go all the way to the end of the trajectory

if %direction%==BACKWARD  goto BACKWARD
if %direction%==FORWARD   goto FORWARD

:BACKWARD
echo in BACKWARD direction section 
SET /A adjusted_hrs = 1 + %duration%
ECHO -%adjusted_hrs% >>control.txt
goto DIRECTION_END

:FORWARD
echo in FORWARD direction section
SET /A adjusted_hrs = 1 + %duration%
ECHO %adjusted_hrs% >>control.txt
goto DIRECTION_END

:DIRECTION_END

rem **********************************************************************

rem 5. Vertical motion option

rem			(0:data 1:isob 2:isen 3:dens 4:sigma 5:diverg 6:eta)

rem 			Default: 0

rem 	  Indicates the vertical motion calculation method.
rem 		The default "data" selection will use the meteorological model's
rem 		vertical velocity fields; other options include isobaric,
rem   	isentropic, constant density, constant internal sigma coordinate,
rem 		computed from the velocity divergence, and a special transformation
rem 		to correct the vertical velocities when mapped from quasi-horizontal ETA
rem 		surfaces to HYSPLIT's internal terrain following sigma coordinate.

ECHO 0 >>control.txt

rem **********************************************************************

rem 6. Top of model domain (internal coordinates m-agl)

rem 			Default: 10000.0

rem 		Sets the vertical limit of the internal meteorological grid.
rem 		If calculations are not required above a certain level, fewer meteorological
rem 		data are processed thus speeding up the computation. Trajectories will
rem 		terminate when they reach this level. A secondary use of this parameter is
rem 		to set the model's internal scaling height - the height at which the
rem 		internal sigma surfaces go flat relative to terrain. The default internal
rem 		scaling height is set to 25 km but it is set to the top of the model
rem 		domain if the entry exceeds 25 km. Further, when meteorological data are
rem 		provided on terrain sigma surfaces it is assumed that the input data
rem 		were scaled to a height of 20 km (RAMS) or 34.8 km (COAMPS). If a different
rem 		height is required to decode the input data, it should be entered on
rem 		this line as the negative of the height. HYSPLIT's internal scaling height
rem 		remains at 25 km unless the absolute value of the domain top exceeds 25 km.

rem ECHO 25000.0 >>control.txt
ECHO 10000.0 >>control.txt

rem **********************************************************************

rem 7. Number of Input Data Grids

rem 		Default: 1

rem 		Number of simultaneous input meteorological files. The following two entries
rem 		(directory and name) will be repeated this number of times. A simulation
rem 		will terminate when the computation is off all of the grids in either
rem 		space or time. Trajectory calculations will check the grid each time
rem 		step and use the finest resolution input data available at that location
rem 		at that time. When multiple meteorological grids have different resolution,
rem 		there is an additional restriction that there should be some overlap between
rem 		the grids in time, otherwise it is not possible to transfer a trajectory
rem 		position from one grid to another.

ECHO 2 >>control.txt

rem *************************************************************************
rem -- 1st met file
rem *************************************************************************

rem Meteorological data grid # 1 directory

rem 		Default: ( \main\sub\data\ )

rem 		Directory location of the meteorological file on the grid specified.
rem 		Always terminate with the appropriate slash (\ or /).

ECHO %metfile_dir% >>control.txt

rem ************************************************************************
rem Meteorological data grid # 1 file name

rem 		Default: file_name

rem 		Name of the file containing meteorological data.
rem 		Located in the previous directory.

ECHO %metfile_01% >>control.txt

rem ************************************************************************
rem     This example script has two met files. 
rem     Typical HYSPLIT installation limits total number of met files to <=12.
rem ************************************************************************

ECHO %metfile_dir% >>control.txt
ECHO %metfile_02% >>control.txt

rem ECHO %metfile_dir% >>control.txt
rem ECHO %metfile_03% >>control.txt

rem *************************************************************************
rem 10 - Directory of trajectory output file

rem 			Default: ( \main\trajectory\output\ )

rem 			Directory location to which the text trajectory end-points file will
rem				be written. Always terminate with the appropriate slash (\ or /).

ECHO %WORK_DIR% >>control.txt

rem *************************************************************************
rem 11- Name of the trajectory endpoints file

rem 			Default: file_name

rem 			The trajectory end-points output file is named in this entry line.

ECHO tdump.txt >>control.txt

rem  sometimes machines go so fast that there is a problem with file handles
rem  so have put a short pause here to ensure that this does not happen
timeout 1

IF EXIST CONTROL. DEL CONTROL.

copy control.txt CONTROL.

rem  sometimes machines go so fast that there is a problem with file handles
rem  so have put a short pause here to ensure that this does not happen
timeout 1

rem *************************************
rem  DONE establishing CONTROL file
rem *************************************

echo have written CONTROL file
if %PAUSES%==1 pause

rem *************************************
rem  now establish SETUP.CFG file
rem *************************************

IF EXIST SETUP.CFG DEL SETUP.CFG
rem copy setup_cfg_frac_pbl.txt SETUP.CFG

IF EXIST setup.txt del setup.txt

rem now figured out how to ECHO an ampersand -- have to have a ^ in front!
ECHO  ^&setup > setup.txt

rem KHMAX is the maximum duration of the trajectory
rem we are setting this to the actual duration of the run that we want
ECHO KHMAX=%duration%, >> setup.txt

rem KMSL flag establishes vertical meausurement unit for start height
rem KMSL = 2 = fraction of planetary boundary layer
ECHO KMSL=%KMSL%, >> setup.txt

rem  The endpoint write interval TOUT(60) sets the time interval in minutes
rem  at which trajectory end-point positions will be written to the output file.
rem  Output intervals of less than 60 minutes can be selected.
rem  This will also force the internal time step to be an even multiple
rem  of the output interval.

ECHO TOUT = %output_delta%, >> setup.txt

rem   ---------------------------------------------------------------------------------
rem     MGMIN (10) (Meteorological Sub-grid Size) is the minimum size in grid units
rem     of the meteorological sub-grid. The sub-grid is set dynamically during the
rem     calculation and depends upon the horizontal distribution of end-points and
rem     the wind speed.  Larger sub-grids than necessary will slow down the
rem     calculation by forcing the processing of meteorological data in regions where
rem     no transport or dispersion calculations are being performed.  In some
rem     situations, such as when the computation is between meteorological data files
rem     that have no temporal overlap, the model may try to reload meteorological data
rem     with a new sub-grid.  This will result in a fatal error.  One solution to this
rem     error would be to increase the minimum grid size larger than the meteorological
rem     grid to force a full-grid data load.

ECHO MGMIN = 10,   >>setup.txt

rem  *******************************************
rem    Add Meteorology Output Along Trajectory
rem  *******************************************

rem  Sets the option to write the value of certain meteorological
rem  variables along the trajectory to the trajectory output file.
rem  The marker variables are set to (1) to turn on the option.
rem  Multiple variables may be selected for simultaneous output
rem  but only one variable may be plotted. If multiple variables
rem  are selected in conjunction with the trajectory display option,
rem  then only the last variable output will be shown in the graphic.
rem  The variable output order is fixed in the program and cannot be changed.
rem  Potential Temperature in degrees Kelvin TM_TPOT (0|1)
rem  Ambient Temperature in degrees Kelvin TM_TAMB (0|1)
rem  Precipitation rainfall in mm per hour TM_RAIN (0|1)
rem  Mixing Depth in meters TM_MIXD (0|1)
rem  Relative Humidity in percent TM_RELH (0|1)
rem  Solar Radiation downward solar radiation flux in watts TM_DSWF (0|1)
rem  Terrain Height in meters required for the trajectory plot to show underlying terrain TM_TERR (0|1)

rem ECHO TM_TPOT = 1, >> setup.txt
rem ECHO TM_TAMB = 1, >> setup.txt
rem ECHO TM_RAIN = 1, >> setup.txt
ECHO TM_MIXD = 1, >> setup.txt
rem ECHO TM_RELH = 1, >> setup.txt
rem ECHO TM_SPHU = 1, >> setup.txt
rem ECHO TM_MIXR = 1, >> setup.txt
rem ECHO TM_DSWF = 1, >> setup.txt
rem ECHO TM_TERR = 1 >> setup.txt

rem NOTE -- don't put comma as this is last entry of namelist file

rem   ---------------------------------------------------------------------------------
ECHO  /   >>setup.txt
rem   ---------------------------------------------------------------------------------

rem  sometimes machines go so fast that there is a problem with file handles
rem  so have put a short pause here to ensure that this does not happen
timeout 1

copy setup.txt SETUP.CFG

rem  sometimes machines go so fast that there is a problem with file handles
rem  so have put a short pause here to ensure that this does not happen
timeout 1

echo have written SETUP.CFG
if %PAUSES%==1 pause

rem **********************************************************************
rem    NOW THAT ALL INPUTS HAVE BEEN SET, DO SIMULATION
rem **********************************************************************

IF EXIST tdump.txt DEL tdump.txt

%EXEC_DIR%hyts_std

echo have run hyts_std
if %PAUSES%==1 pause

rem **********************************************************************
rem    NOW MAKE A MAP OF THE OVERALL RESULTS of this simulation
rem    and create GIS-compatible outputs
rem **********************************************************************

rem   HERE ARE COMMAND LINE OPTIONS FOR TRAJPLOT

rem   Remember that you can always get the options by executing
rem   the program without putting any options in...
rem   This works for most of the programs in the EXEC directory

rem  C:\hysplit4\working_met>..\exec\trajplot
rem  USAGE: trajplot -[options (default)]

rem   -a[GIS output: (0)-none 1-GENERATE_points 3-KML 4-partial_KML 5-GENERATE_lines]
rem   -A[KML options: 0-none 1-no extra overlays 2-no endpoints 3-Both 1&2]
rem   -e[End hour to plot: #, (all) ]
rem   -f[Frames: (0)-all files on one  1-one per file]
rem   -g[Circle overlay: ( )-auto, #circ(4), #circ:dist_km]
rem   -h[Hold map at center lat-lon: (source point), lat:lon]
rem   -i[Input files: name1+name2+... or +listfile or (tdump)]
rem   -j[Map background file: (arlmap) or shapefiles.<(txt)|process suffix>]
rem   -k[Kolor: 0-B&W, (1)-Color, N:colortraj1,...colortrajN] 1=red,2=blue,3=green,4=cyan,5=magenta,6=yellow,7=olive
rem   -l[Label interval: ... -12, -6, 0, (6), 12, ... hrs; <0=with respect to traj start, >0=synoptic times)]
rem   -L[LatLonLabels: none=0 auto=(1) set=2:value(tenths)]
rem   -m[Map proj: (0)-Auto 1-Polar 2-Lambert 3-Merc 4-CylEqu]
rem   -o[Output file name: (trajplot.ps)]
rem   -p[Process file name suffix: (ps) or process ID]
rem   -s[Symbol at trajectory origin: 0-no (1)-yes]
rem   -v[Vertical: 0-pressure (1)-agl, 2-theta 3-meteo 4-none]
rem   -z[Zoom factor:  0-least zoom, (50), 100-most zoom]

rem    NOTE: leave no space between option and value

rem **********************************************************************
rem    before making the map, establish the STATIONPLOT.CFG file
rem **********************************************************************

rem  if STATIONPLOT.CFG file is present and in the right format,
rem  then HYSPLIT will use it.
rem  THE FORMAT FOR THE STATIONPLOT.CFG file is the following:

rem  If the file STATIONPLOT.CFG exists in the root directory, plot character(s)
rem  specified in that file or it plots a symbol if no characters are given.
rem  The format is F6.2,1X,F7.2,1X,A :

rem  123.56x1234.67xA

rem  Here's an example of a few lines of such a file:

rem   39.18  -76.54
rem   40.12 -113.71
rem  -12.65  110.54 a
rem   86.23  -90.00 c

rem  * for the first two points in the example above, a circle would be plotted
rem  * for the 3rd point an "a" would be plotted,
rem  * and for the 4th pt, a "c" would be plotted;
rem  * these could be changed to any other one-character text symbols

rem  copy appropriate stationplot file information to standard file name
rem  required by TRAJPLOT ("STATIONPLOT.CFG"):

rem  NOTE: for this example, will not be using this feature

IF EXIST STATIONPLOT.CFG DEL STATIONPLOT.CFG

IF EXIST STATIONPLOT_EXAMPLE.txt COPY STATIONPLOT_EXAMPLE.txt STATIONPLOT.CFG

rem **********************************************************************
rem  first run trajplot to output GIS points:                             
rem **********************************************************************

IF EXIST plot_250.ps DEL plot_250.ps
IF EXIST GIS_traj_ps_01.txt DEL GIS_traj_ps_01.txt
%EXEC_DIR%trajplot -itdump.txt -oplot_250 -v3 -l1 -h -g0:250 -m0 -a1
IF EXIST GIS_traj_ps_01.txt COPY GIS_traj_ps_01.txt GIS_POINTS.TXT
IF EXIST GIS_POINTS.TXT %EXEC_DIR%ascii2shp %run_name%_points points <GIS_POINTS.TXT

rem  sometimes machines go so fast that there is a problem with file handles
rem  so have put a short pause here to ensure that this does not happen
timeout 1

echo have run trajplot to get GIS points
if %PAUSES%==1 pause

rem **********************************************************************
rem  then run trajplot to make GIS lines:                                 
rem **********************************************************************

IF EXIST plot_250.ps DEL plot_250.ps
IF EXIST GIS_traj_ps_01.txt DEL GIS_traj_ps_01.txt
%EXEC_DIR%trajplot -itdump.txt -oplot_250 -v3 -l1 -h -g0:250 -m0 -a5
IF EXIST GIS_traj_ps_01.txt COPY GIS_traj_ps_01.txt GIS_LINES.TXT
IF EXIST GIS_LINES.TXT %EXEC_DIR%ascii2shp %run_name%_lines lines <GIS_LINES.TXT

rem  sometimes machines go so fast that there is a problem with file handles
rem  so have put a short pause here to ensure that this does not happen
timeout 1

echo have run trajplot to get GIS lines
if %PAUSES%==1 pause

rem **********************************************************************
rem  then run trajplot to get Google Earth output:                        
rem **********************************************************************

IF EXIST GE_traj_01.kml DEL GE_traj_01.kml
IF EXIST GE_traj_01.kmz DEL GE_traj_01.kmz

%EXEC_DIR%trajplot -itdump.txt -oGE_traj -v3 -l1 -h -m0 -a3 -A1

echo have run trajplot to get Google Earth output
if %PAUSES%==1 pause

rem **********************************************************************
rem  convert output map to jpg, using density of 150
rem **********************************************************************

rem  this makes a jpg of about 200kB... but a little fuzzy
rem  if you want a sharper image, can use density of 300 or even higher
rem  but this makes the jpg sizes bigger...

IF EXIST plot_250.jpg DEL plot_250.jpg
IF EXIST plot_250.ps convert -trim -density 150 plot_250.ps plot_250.jpg

echo have converted ps to jpg
if %PAUSES%==1 pause

rem **********************************************************************
rem      COPY OUTPUT files to include RUN NAME
rem **********************************************************************

rem IF EXIST plot.ps DEL plot.ps
IF EXIST GE_traj_01.kml      COPY GE_traj_01.kml %run_name%.kml
IF EXIST GE_traj_01.kmz      COPY GE_traj_01.kmz %run_name%.kmz
IF EXIST plot_250.jpg COPY plot_250.jpg %run_name%_250km.jpg
IF EXIST plot_250.ps  COPY plot_250.ps %run_name%_250km.ps
IF EXIST tdump.txt     COPY tdump.txt %run_name%.tdp
IF EXIST CONTROL.      COPY CONTROL. %run_name%.ctl
IF EXIST MESSAGE.      COPY MESSAGE. %run_name%.msg
IF EXIST SETUP.CFG     COPY SETUP.CFG %run_name%.cfg

echo have copied output files to include run-name
if %PAUSES%==1 pause

rem **********************************************************************
rem     CREATE RESULTS SUBDIRECTORIES
rem **********************************************************************

IF NOT EXIST %RESULTS_DIR%kml\        mkdir %RESULTS_DIR%kml\
IF NOT EXIST %RESULTS_DIR%ps_250km\  mkdir %RESULTS_DIR%ps_250km\
IF NOT EXIST %RESULTS_DIR%jpg_250km\ mkdir %RESULTS_DIR%jpg_250km\
IF NOT EXIST %RESULTS_DIR%tdp\        mkdir %RESULTS_DIR%tdp\
IF NOT EXIST %RESULTS_DIR%ctl\        mkdir %RESULTS_DIR%ctl\
IF NOT EXIST %RESULTS_DIR%msg\        mkdir %RESULTS_DIR%msg\
IF NOT EXIST %RESULTS_DIR%cfg\        mkdir %RESULTS_DIR%cfg\
IF NOT EXIST %RESULTS_DIR%lns\        mkdir %RESULTS_DIR%lns\
IF NOT EXIST %RESULTS_DIR%pts\        mkdir %RESULTS_DIR%pts\

echo have created separate folders for each file type, if they did not already exist
if %PAUSES%==1 pause

rem **********************************************************************
rem     MOVE FILES to RESULTS SUBDIRECTORIES                               
rem **********************************************************************

IF EXIST %run_name%.kml        MOVE %run_name%.kml %RESULTS_DIR%kml\
IF EXIST %run_name%_250km.jpg  MOVE %run_name%_250km.jpg %RESULTS_DIR%jpg_250km\
IF EXIST %run_name%_250km.ps   MOVE %run_name%_250km.ps  %RESULTS_DIR%ps_250km\
IF EXIST %run_name%.tdp        MOVE %run_name%.tdp %RESULTS_DIR%tdp\
IF EXIST %run_name%.ctl        MOVE %run_name%.ctl %RESULTS_DIR%ctl\
IF EXIST %run_name%.msg        MOVE %run_name%.msg %RESULTS_DIR%msg\
IF EXIST %run_name%.cfg        MOVE %run_name%.cfg %RESULTS_DIR%cfg\

IF EXIST %run_name%_points.shp MOVE %run_name%_points.shp %RESULTS_DIR%pts\
IF EXIST %run_name%_points.shx MOVE %run_name%_points.shx %RESULTS_DIR%pts\
IF EXIST %run_name%_points.dbf MOVE %run_name%_points.dbf %RESULTS_DIR%pts\
IF EXIST %run_name%_points.prj MOVE %run_name%_points.prj %RESULTS_DIR%pts\

IF EXIST %run_name%_lines.shp  MOVE %run_name%_lines.shp %RESULTS_DIR%lns\
IF EXIST %run_name%_lines.shx  MOVE %run_name%_lines.shx %RESULTS_DIR%lns\
IF EXIST %run_name%_lines.dbf  MOVE %run_name%_lines.dbf %RESULTS_DIR%lns\
IF EXIST %run_name%_lines.prj  MOVE %run_name%_lines.prj %RESULTS_DIR%lns\

echo have moved files to appropriate results subdirectories
if %PAUSES%==1 pause

:script_end

rem  sometimes machines go so fast that there is a problem with file handles
rem  so have put a short pause here to ensure that this does not happen
timeout 1
