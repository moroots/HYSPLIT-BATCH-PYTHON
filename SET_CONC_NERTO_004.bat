@ECHO OFF

rem example SET file to carry out CONCENTRATION simulations

rem if set PAUSES to 1, then script will include pauses at key points, useful for debugging
rem otherwise, there will be no pauses
rem SET PAUSES=1
SET PAUSES=0

SETLOCAL ENABLEEXTENSIONS

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
rem parameter      #1: start year (UTC)
rem parameter      #2: start month (UTC)
rem parameter      #3: start day (UTC)
rem parameter      #4: start hour (UTC)
rem parameter      #5: start minute (UTC)
rem parameter      #6: run duration (hrs)
rem parameter      #7: run name

rem parameter      #8: met_dir

rem parameter      #9: met_file_01
rem parameter     #10: met_file_02
rem parameter     #11: met_file_03

rem parameter     #12: emit_site_code
rem parameter     #13: pollutant
rem parameter     #14: emit_g_hr

rem parameter     #15: emissions cycling (hours)

rem      0: no cycling, just 1 hour of emissions at the specified rate

rem      1: cycling every hour, so 1 hr emissions specified are repeated every hour
rem         this makes the emissions continuous throughout the run at the specified rate

rem parameter     #16: dispersion scheme

rem parameter     #17: numpar

rem parameter     #18: maxpar

rem parameter     #19: fixed time step (minutes)

rem parameter     #20: Environment (1=NOAA)
rem parameter     #21: executable
rem parameter     #22: RESULTS_DIR

rem parameter     #23: monitoring_site_code
rem parameter     #24: EMITIMES file

SET start_year=%parameter_1%
echo start year = %start_year%

SET start_month=%parameter_2%
echo start month = %start_month%

SET start_day=%parameter_3%
echo start day = %start_day%

SET start_hour=%parameter_4%
echo start hour = %start_hour%

SET start_minute=%parameter_5%
echo start minute = %start_minute%

SET duration=%parameter_6%
echo duration = %duration%

SET run_name=%parameter_7%
echo run name = %run_name%

SET met_dir=%parameter_8%
echo met_dir = %met_dir%

SET met_file_01=%parameter_9%
echo met_file_01 = %met_file_01%

SET met_file_02=%parameter_10%
echo met_file_02 = %met_file_02%

SET met_file_03=%parameter_11%
echo met_file_03 = %met_file_03%

SET emit_site_code=%parameter_12%
echo emit_site_code = %emit_site_code%

SET pollutant=%parameter_13%
echo pollutant = %pollutant%

SET emit_g_hr=%parameter_14%
echo emit_g_hr = %emit_g_hr%

SET emit_cycling=%parameter_15%
echo emit_cycling = %emit_cycling%

SET dispersion=%parameter_16%
echo dispersion = %dispersion%

SET numpar=%parameter_17%
echo numpar = %numpar%

SET maxpar=%parameter_18%
echo maxpar = %maxpar%

SET time_step=%parameter_19%
echo time_step = %time_step%

SET ENVR=%parameter_20%
echo ENVR = %ENVR%

SET executable=%parameter_21%
echo  executable = %executable%

SET BASE_RESULTS_DIR=%parameter_22%
echo  BASE_RESULTS_DIR = %BASE_RESULTS_DIR%

SET monitoring_site_code=%parameter_23%
echo monitoring_site_code = %monitoring_site_code%

SET EMITIMES_file=%parameter_24%
echo EMITIMES_file = %EMITIMES_file%

rem if %PAUSES%==1 pause

echo inside SET, ENVR = %ENVR%

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

rem if %PAUSES%==1 pause

rem *************************************************************
rem   establish RESULTS directory                                
rem *************************************************************

SET RESULTS_DIR=%RESULTS_BASE_DIR%\%run_name%\

rem if results directory does not exist, create it:
IF NOT EXIST %RESULTS_DIR% mkdir %RESULTS_DIR%

echo have established results directory if it didn't already exist
rem if %PAUSES%==1 pause

rem *********************************************************************
rem   first create CONTROL file HYSPLIT uses to simulate concentration
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

ECHO 24 >>control.txt

rem **********************************************************************

rem 3. Starting Location [lat,long, height (meters above ground)]
rem    ** NOTE that if we set KMSL = 2 in setup file below, then
rem       heights here are interpreted as fractions of the Planetary Boundary Layer (PBL)
rem       so, in that case, if height is set to 0.5, for example, 
rem       it means that the trajectory starts in the middle of the PBL for any given starting time.

rem       west longitudes are negative; south latitudes are negative

SET LAT=39.1792
SET LONG=-76.5383
SET HEIGHT=212

for /L %%A in (1,1,24) Do echo %LAT% %LONG% %HEIGHT% >>control.txt

rem **********************************************************************
rem 4. Total Run Time for Simulation (hours)

rem        Default: 48

rem     Specifies the duration of the calculation in hours.
rem     Backward calculations are entered as negative hours.
rem     A backward trajectory starts from the trajectory termination
rem     point and proceeds upwind.
rem     Meteorological data are processed in reverse-time order.

echo %duration% >>control.txt

rem **********************************************************************

rem 5. Vertical motion option

rem        (0:data 1:isob 2:isen 3:dens 4:sigma 5:diverg 6:eta)
rem        (7:     8:      9: upward, burst, downward; 10: downward only)

rem        Default: 0

rem        Indicates the vertical motion calculation method.
rem        The default "data" selection will use the meteorological model's
rem        vertical velocity fields; other options include isobaric,
rem        isentropic, constant density, constant internal sigma coordinate,
rem        computed from the velocity divergence, and a special transformation
rem        to correct the vertical velocities when mapped from quasi-horizontal ETA
rem        surfaces to HYSPLIT's internal terrain following sigma coordinate.

echo 0 >>control.txt

rem **********************************************************************

rem 6. Top of model domain (internal coordinates m-agl)

rem        Default: 10000.0

rem     Sets the vertical limit of the internal meteorological grid.
rem        If calculations are not required above a certain level, fewer meteorological
rem        data are processed thus speeding up the computation. Trajectories will
rem        terminate when they reach this level. A secondary use of this parameter is
rem        to set the model's internal scaling height - the height at which the
rem        internal sigma surfaces go flat relative to terrain. The default internal
rem        scaling height is set to 25 km but it is set to the top of the model
rem        domain if the entry exceeds 25 km. Further, when meteorological data are
rem        provided on terrain sigma surfaces it is assumed that the input data
rem        were scaled to a height of 20 km (RAMS) or 34.8 km (COAMPS). If a different
rem        height is required to decode the input data, it should be entered on
rem        this line as the negative of the height. HYSPLIT's internal scaling height
rem        remains at 25 km unless the absolute value of the domain top exceeds 25 km.

echo 10000.0 >>control.txt

rem **********************************************************************

rem 7. Number of Input Data Grids

rem        Default: 1

rem        Number of simultaneous input meteorological files. The following two entries
rem        (directory and name) will be repeated this number of times. A simulation
rem        will terminate when the computation is off all of the grids in either
rem        space or time. Trajectory calculations will check the grid each time
rem        step and use the finest resolution input data available at that location
rem        at that time. When multiple meteorological grids have different resolution,
rem        there is an additional restriction that there should be some overlap between
rem        the grids in time, otherwise it is not possible to transfer a trajectory
rem        position from one grid to another.

echo 3 >> control.txt

echo %met_dir% >> control.txt
echo %met_file_01% >> control.txt

echo %met_dir% >> control.txt
echo %met_file_02% >> control.txt

echo %met_dir% >> control.txt
echo %met_file_03% >> control.txt

echo have written met file directory and met file names to control file

rem if %PAUSES%==1 pause

rem *************************************************************************
rem  10- Number of different pollutants
rem *************************************************************************

rem Default: 1

rem Multiple pollutant species may be defined for emissions. Each pollutant is assigned to its own particle or puff and
rem therefore may behave differently due to deposition or other pollutant specific characteristics. Each will be tracked
rem on its own concentration grid. The following four entries are repeated for each pollutant defined.

echo 1 >> control.txt

rem *************************************************************************
rem  11-15 The following 4 lines for each pollutant
rem *************************************************************************

rem *************************************************************************
rem 11(1)- Pollutant four Character Identification
rem *************************************************************************

rem Default:TEST

rem Provides a four-character label that can be used to identify the pollutant. The label is written with the
rem concentration output grid to identify output records associated with that pollutant and will appear in display
rem labels. Additional user supplied deposition and chemistry calculations may be keyed to this identification string.

echo %pollutant% >> control.txt

rem *************************************************************************
rem 12(2)- Emission rate (per hour)
rem *************************************************************************

rem Default: 1.0

rem Mass units released each hour. Units are arbitrary except when specific chemical transformation subroutines are
rem associated with the calculation. Output air concentration units will be in the same units as specified on this line.
rem For instance an input of kg/hr results in an output of kg/m3. When multiple sources are defined this rate is
rem assigned to all sources unless the optional parameters are present on line 3(1).

rem echo %emit_g_hr% >> control.txt
rem with EMITIMES, will use emit of 0 here
echo 0.0 >> control.txt

rem *************************************************************************
rem 13(3)- Hours of emission
rem *************************************************************************

rem Default: 1.0

rem The duration of emission may be defined in fractional hours. An emission duration of less than one time-step will
rem be emitted over one time-step with a total emission that would yield the requested rate over the emission
rem duration.

rem echo 1 >> control.txt
rem with EMITIMES will use 0 here
echo 0 >> control.txt

rem note, if want longer emissions, will use emissions cycling, in SETUP.CFG below

rem *************************************************************************
rem 14(4)- Release start time: year month day hour minute
rem *************************************************************************

rem Default: [simulation start]

rem The previously specified hours of emission start at this time. An entry of zero's in the field, when input is read
rem from a file, will also result in the selection of the default values that will correspond with the starting time of the
rem meteorological data file. Day and hour are treated as relative to the file start when month is set to zero.

echo 00 00 00 00 00 >> control.txt

rem *************************************************************************
rem Dispersion calculations are performed on the computational (meteorological) grid without regard to the definition or
rem location of any concentration grid. Therefore it is possible to complete a simulation and have no results to view if the
rem concentration grid was in the wrong location. In addition, very small concentration grid spacing will reduce the model's
rem integration time step and may result is substantially longer simulation clock times.
rem *************************************************************************


rem *************************************************************************
rem 15- Number of simultaneous concentration grids
rem *************************************************************************

rem Default: 1

rem Multiple or nested grids may be defined. The concentration output grids are treated independently. The following
rem 10 entries will be repeated for each grid defined.

echo 2 >> control.txt

rem *****************************************************************************
rem GRID #1 dispersion grid around source, big enough to include monitoring site
rem *****************************************************************************

rem *************************************************************************
rem 16(1)- Center Latitude, Longitude (degrees)
rem *************************************************************************

rem Default: [source location]

rem Sets the center position of the concentration sampling grid in degrees and decimal. Input of zero's will result in
rem selection of the default value, the location of the emission source. Sometimes it may be desirable to move the
rem grid center location downwind near the center of the projected plume position.

rem will set the center at the emissions site

echo 0.0 0.0  >> control.txt

rem will set the center at the monitoring site = Hart-Miller Island
rem echo 39.2496 -76.3640  >> control.txt

rem *************************************************************************
rem 17(2)- Grid spacing (degrees) Latitude, Longitude
rem *************************************************************************

rem Default: 1.0 1.0

rem Sets the interval in degrees between nodes of the sampling grid. Puffs must pass over a node to contribute
rem concentration to that point and therefore if the spacing is too wide, they may pass between intersection points.
rem Particle model calculations represent grid-cell averages, where each cell is centered on a node position, with its
rem dimensions equal to the grid spacing. Finer resolution concentration grids require correspondingly finer
rem integration time-steps. This may be mitigated to some extent by limiting fine resolution grids to only the first few
rem hours of the simulation.

rem In the special case of a polar (arc,distance) concentration grid, defined when the namelist variable cpack=3, the
rem definition changes such that the latitude grid spacing equals the sector angle in degrees and the longitude grid
rem spacing equals the sector distance spacing in kilometers.

echo 0.02 0.02 >> control.txt

rem *************************************************************************
rem 18(3)- Grid span (deg) Latitude, Longitude
rem *************************************************************************

rem Default: [180.0] [360.0]

rem Sets the total span of the grid in each direction. For instance, a span of 10 degrees would cover 5 degrees on each
rem side of the center grid location. A plume that goes off the grid would have cutoff appearance, which can
rem sometimes be mitigated by moving the grid center further downwind.
rem In the special case of a polar (arc,distance) concentration grid, defined when the namelist variable cpack=3, the
rem definition changes such that the latitude span always equals 360.0 degrees and the longitude span equals the total
rem downwind distance in kilometers. Note that the number of grid points equals 360/arc-angle or the total-distance
rem divided by the sector-distance.

rem screening_radius_max_km=100.0
echo 2.0 2.0 >> control.txt

rem *************************************************************************
rem 19(4)- Enter grid # 1 directory
rem *************************************************************************

rem Default: ( \main\sub\output\ )

rem Directory to which the binary concentration output file for this grid is written. As in other directory entries a
rem terminating  slash is required ("\" or "/" as appropriate for the operating system).

echo ./ >> control.txt

rem *************************************************************************
rem 20(5)- Enter grid # 1 file name
rem *************************************************************************

rem Default: file_name

rem Name of the concentration output file for each grid. See Section 6 for a description of the format of the
rem concentration output file.

echo source_detail.bin >> control.txt

rem *************************************************************************
rem 21(6)- Number of vertical concentration levels
rem *************************************************************************

rem Default: 1

rem The number of vertical levels in the concentration grid including the ground surface level if deposition output is
rem required.

rem in Richmond 004, changed to just two levels (300, 1000)
rem echo 6 >> control.txt
echo 6 >> control.txt

rem *************************************************************************
rem 22(7)- Height of each level (m)
rem *************************************************************************

rem Default: 50

rem Output grid levels may be defined in any order for the puff model as long as the deposition level (0) comes first (a
rem height of zero indicates deposition output). Air concentrations must have a non-zero height defined. A height for
rem the puff model indicates the concentration at that level. A height for the particle model indicates the average
rem concentration between that level and the previous level (or the ground for the first level). Therefore heights for
rem the particle model need to be defined in ascending order. Note that the default is to treat the levels as aboveground-
rem level (AGL) unless the MSL (above Mean-Sea-Level) flag has been set (see advanced configuration).

rem echo 0 200 500 1000 2000 5000 >> control.txt
rem echo 0 200 500 1000 1500 2000 >> control.txt
rem echo 300 1000 >> control.txt

echo 0 50 100 200 500 1000 >> control.txt

rem *************************************************************************
rem 23(8)- Sampling start time: year month day hour minute
rem *************************************************************************

rem Default: [simulation start]

rem Each concentration grid may have a different starting, stopping, and output averaging time. Zero entry will result
rem in setting the default values. "Backward" calculations require that the stop time should come before the start time.

rem what I will do is take the product hour, and just do a snapshot

rem product_month=%39%  echo 'product_month = '%product_month%
rem product_day=%40%  echo 'product_day = '%product_day%
rem product_hour=%41%  echo 'product_hour = '%product_hour%

rem echo 18 %product_month% %product_day% %product_hour% 00 >> control.txt

rem will sample continuously

echo 00 00 00 00 00 00 >> control.txt

rem *************************************************************************
rem 24(9)- Sampling stop time: year month day hour minute
rem *************************************************************************

rem Default: 12 31 24 60

rem After this time no more concentration records are written. Early termination on a high resolution grid (after the
rem plume has moved away from the source) is an effective way of speeding up the computation for high resolution
rem output near the source because once turned-off that particular grid resolution is no longer used for time-step
rem computations.

rem what I will do is take the product hour, and just do a snapshot

rem echo 18 %product_month% %product_day% %product_hour% 00 >> control.txt

rem will sample continuously

echo 00 00 00 00 00 00 >> control.txt

rem *************************************************************************
rem 25(10)- Sampling interval: type hour minute
rem *************************************************************************

rem Default: 0 24 0

rem Each grid may have its own sampling or averaging interval. The interval can be of three different types: averaging
rem (type=0), snapshot (type=1), or maximum (type=2). Averaging will produce output averaged over the specified
rem interval. For instance, you may want to define a concentration grid that produces 24-hour average air
rem concentrations for the duration of the simulation, which in the case of a 2-day simulation will result in 2 output
rem maps, one for each day. Each defined grid can have a different output type and interval. Snapshot (or now) will
rem give the instantaneous output at the output interval, and maximum will save the maximum concentration at each
rem grid point over the duration of the output interval. Therefore, when a maximum concentration grid is defined, it is
rem also required to define an identical snapshot or average grid over which the maximum will be computed. There is
rem also the special case when the type value is less than zero. In that case the value represents the averaging time in
rem hours and the output interval time represents the interval at which the average concentration is output. For
rem instance, a setting of {-1 6 0% would output a one-hour average concentration every six hours.

rem will use 15 minute averages, for now...

echo 0 0 15 >> control.txt

rem *****************************************************************************
rem GRID #2 coarser grid for concplot
rem *****************************************************************************

rem *************************************************************************
rem 16(1)- Center Latitude, Longitude (degrees)
rem *************************************************************************

echo 0.0 0.0  >> control.txt

rem *************************************************************************
rem 17(2)- Grid spacing (degrees) Latitude, Longitude
rem *************************************************************************

echo 0.02 0.02 >> control.txt

rem *************************************************************************
rem 18(3)- Grid span (deg) Latitude, Longitude
rem *************************************************************************

echo 2.0 2.0 >> control.txt

rem *************************************************************************
rem 19(4)- Enter grid # 1 directory
rem *************************************************************************

echo ./ >> control.txt

rem *************************************************************************
rem 20(5)- Enter grid # 1 file name
rem *************************************************************************

echo source_coarse.bin >> control.txt

rem *************************************************************************
rem 21(6)- Number of vertical concentration levels
rem *************************************************************************

echo 1 >> control.txt

rem *************************************************************************
rem 22(7)- Height of each level (m)
rem *************************************************************************

echo 100 >> control.txt

rem *************************************************************************
rem 23(8)- Sampling start time: year month day hour minute
rem *************************************************************************

echo 00 00 00 00 00 00 >> control.txt

rem *************************************************************************
rem 24(9)- Sampling stop time: year month day hour minute
rem *************************************************************************

echo 00 00 00 00 00 00 >> control.txt

rem *************************************************************************
rem 25(10)- Sampling interval: type hour minute
rem *************************************************************************

echo 0 01 00 >> control.txt

rem -------------------------------------------------------------------------------
echo have written conc grid info to control file
rem if %PAUSES%==1 pause
rem -------------------------------------------------------------------------------

rem *************************************************************************
rem This section is used to define the deposition parameters for emitted pollutants. The number of deposition definitions
rem must correspond with the number of pollutants released. There is a one-to-one correspondence. There are 5 entries in
rem the CONTROL file for each defined pollutant. The lines 27(1) through 31(5) correspond with each of the menu items
rem shown in the illustration below. The radio-buttons along the top can be used to set default deposition parameters, which
rem can then be edited as required in the text entry section. The second line of radio-buttons define the deposition values for
rem some preconfigured species: Cesium, Iodine (gaseous and particiulate), and Tritium. The reset button sets all deposition
rem parameters back to zero. Note that turning on deposition will result in the removal of mass and the corresponding reduction in air
rem concentration, the deposition will not be available in any output unless height "0" is defined as one of the concentration grid levels.
rem *************************************************************************

rem *************************************************************************
rem 26 - Number of pollutants depositing
rem *************************************************************************

rem Default: number of pollutants on line # 10

rem Deposition parameters must be defined for each pollutant species emitted. Each species may behave differently
rem for deposition calculations. Each will be tracked on its own concentration grid.

rem The following five lines are
rem repeated for each pollutant defined. The number here must be identical to the number on line 10. Deposition is
rem turned off for pollutants by an entry of zero in all fields.

echo 1 >> control.txt

rem *************************************************************************
rem 27(1)- Particle: Diameter (µm), Density (g/cc), and Shape
rem *************************************************************************

rem Default: 0.0 0.0 0.0

rem These three entries are used to define the pollutant as a particle for gravitational settling and wet removal
rem calculations. A value of zero in any field will cause the pollutant to be treated as a gas. All three fields must be
rem defined (>0) for particle deposition calculations. However, these values only need to be correct only if
rem gravitational settling or resistance deposition is to be computed by the model. Otherwise a nominal value of 1.0
rem may be assigned as the default for each entry to define the pollutant as a particle. If a dry deposition velocity is
rem specified as the first entry in the next line (28), then that value is used as the particle settling velocity rather than
rem the value computed from the particle diameter and density.
rem The particle definitions can be used in conjunction with a special namelist parameter NBPTYP that determines if
rem the model will just release the above defined particles or create a continuous particle distribution using the
rem particle definitions as fixed points within the distribution. This option is only valid if the model computes the
rem gravitational settling velocity rather than pre-defining a velocity for each particle size.

rem *************************************************************************
rem 28(2)- Deposition velocity (m/s), Pollutant molecular weight (Gram/Mole), Surface Reactivity Ratio, Diffusivity Ratio,
rem Effective Henry's Constant
rem *************************************************************************

rem Default: 0.0 0.0 0.0 0.0 0.0

rem Dry deposition calculations are performed in the lowest model layer based upon the relation that the deposition
rem flux equals the velocity times the ground-level air concentration. This calculation is available for gases and
rem particles. The dry deposition velocity can be set directly for each pollutant by entering a non-zero value in the
rem first field. In the special case where the dry deposition velocity is set to a value less than zero, the absolute value
rem will be used to compute gravitational settling but with no mass removal. The dry deposition velocity can also be
rem calculated by the model using the resistance method which requires setting the remaining four parameters
rem (molecular weight, surface reactivity, diffusivity, and the effective Henry's constant). See the table below for
rem more information.

rem *************************************************************************
rem 29(3)- Wet Removal: Actual Henry's constant, In-cloud (GT 1 =L/L; LT 1 =1/s), Below-cloud (1/s)
rem *************************************************************************

rem Default: 0.0 0.0 0.0
rem Suggested: 0.0 8.0E-05 8.0E-05

rem Henry's constant defines the wet removal process for soluble gases. It is defined only as a first-order process by a
rem non-zero value in the field. Wet removal of particles is defined by non-zero values for the in-cloud and belowcloud
rem parameters. In-cloud removal can be defined as a ratio of the pollutant in rain (g/liter) measured at the
rem ground to that in air (g/liter of air in the cloud layer) when the value in the field is greater than one. For withincloud
rem values less than one, the removal is defined as a time constant. Below-cloud removal is always defined
rem through a removal time constant. The default cloud bottom and top RH values can be changed through the
rem SETUP.CFG namelist file. Wet removal only occurs in grid cells with both a non-zero precipitation value and a
rem defined cloud layer.

rem *************************************************************************
rem 30(4)- Radioactive decay half-life (days)
rem *************************************************************************

rem Default: 0.0

rem A non-zero value in this field initiates the decay process of both airborne and deposited pollutants. The particle
rem mass decays as well as the deposition that has been accumulated on the internal sampling grid. The deposition
rem array (but not air concentration) is decayed until the values are written to the output file. Therefore, the decay is
rem applied only the the end of each output interval. Once the values are written to the output file, the values are
rem fixed. The default is to decay deposited material. This can be turned off so that decay only occurs to the particle
rem mass while airborne by setting the decay namelist variable to zero.

rem *************************************************************************
rem 31(5)- Pollutant Resuspension (1/m)
rem *************************************************************************

rem Default: 0.0
rem Suggested: 1.0E-06

rem A non-zero value for the re-suspension factor causes deposited pollutants to be re-emitted based upon soil
rem conditions, wind velocity, and particle type. Pollutant re-suspension requires the definition of a deposition grid,
rem as the pollutant is re-emitted from previously deposited material. Under most circumstances, the deposition
rem should be accumulated on the grid for the entire duration of the simulation. Note that the air concentration and
rem deposition grids may be defined at different temporal and spatial scales.

rem *************************************************************************

if %pollutant%==NDEP goto NDEP
if %pollutant%==HgII goto HgII
if %pollutant%==Hgpt goto Hgpt
if %pollutant%==elem goto elem

:NDEP

   rem   values for non-depositing tracer (zero's for all entries)

   rem Particle:  Diameter (um), Density (g/cc), and Shape
   echo 0.0  0.0  0.0 >>control.txt
   rem Dep vel, MW, surface reactivity, diffusivity ratio, effective HL
   echo 0.0  0.0  0.0  0.0  0.0 >>control.txt
   rem Wet removal: Actual Henry's constant,In-cloud (L/L), Below-cloud (1/s)
   echo 0.0  0.0  0.0 >>control.txt
   rem Radioactive decay half-life (days)
   echo 0.0 >>control.txt
   rem Pollutant Resuspension (1/m)
   echo 0.0 >>control.txt
   goto END_DEPOSITION

:HgII

   rem   values for pollutant 2 HgII

   rem Particle:  Diameter (um), Density (g/cc), and Shape
   echo 0.0  2.0  1.0 >>control.txt
   rem Dep vel, MW, surface reactivity, diffusivity ratio, effective HL
   echo 0.0  271.5  1.0  2.0  1.4E+06 >>control.txt
   rem Wet removal: Actual Henry's constant,In-cloud (L/L), Below-cloud (1/s)
   echo 1.4E+06  6.0E+04  5.0E-05 >>control.txt
   rem Radioactive decay half-life (days)
   echo 0.0 >>control.txt
   rem Pollutant Resuspension (1/m)
   echo 0.0 >>control.txt
   goto END_DEPOSITION

:Hgpt

   rem   values for pollutant 3 Hgpt

   rem Particle:  Diameter (um), Density (g/cc), and Shape
   echo 1.0  2.0  1.0 >>control.txt
   rem Dep vel, MW, surface reactivity, diffusivity ratio, effective HL
   rem HL not relevant but dummied in
   echo 0.0  271.5  1.0  2.0  1.4E+06 >>control.txt
   rem Wet removal: Actual Henry's constant,In-cloud (L/L), Below-cloud (1/s)
   rem HL not relevant but dummied in
   rem echo 0.11  4.0E+04  5.0E-05 >>control.txt
   echo 0.11  6.0E+04  5.0E-05 >>control.txt
   rem Radioactive decay half-life (days)
   echo 0.0 >>control.txt
   rem Pollutant Resuspension (1/m)
   echo 0.0 >>control.txt
   goto END_DEPOSITION
   
:elem

   rem   values for Hg(0)

   rem Particle:  Diameter (um), Density (g/cc), and Shape
   echo 0.0  2.0  1.0 >>control.txt
   rem Dep vel, MW, surface reactivity, diffusivity ratio, effective HL
   echo 0.0  200.6  0.0  2.0  0.11  >>control.txt
   rem Wet removal: Actual Henry's constant,In-cloud (L/L), Below-cloud (1/s)
   echo 0.11  6.0E+04  5.0E-05 >>control.txt
   rem Radioactive decay half-life (days)
   echo 0.0 >>control.txt
   rem Pollutant Resuspension (1/m)
   echo 0.0 >>control.txt
   goto END_DEPOSITION

:END_DEPOSITION

rem  sometimes machines go so fast that there is a problem with file handles
rem  so have put a short pause here to ensure that this does not happen
timeout 1

IF EXIST CONTROL. DEL CONTROL.

rename control.txt CONTROL.

rem  sometimes machines go so fast that there is a problem with file handles
rem  so have put a short pause here to ensure that this does not happen
timeout 1

rem *************************************
rem  DONE establishing CONTROL file
rem *************************************

echo have written CONTROL file
rem if %PAUSES%==1 pause

rem *************************************
rem  now establish SETUP.CFG file
rem *************************************

IF EXIST SETUP.CFG DEL SETUP.CFG

IF EXIST setup.txt del setup.txt

rem now figured out how to ECHO an ampersand -- have to have a ^ in front!
ECHO ^&setup > setup.txt

rem  CAPEMIN=-1 enhanced vertical mixing when CAPE exceeds this value (J/kg)
rem echo CAPEMIN=-1,  >> setup.txt

rem  CMASS=0 compute grid concentrations (0) or grid mass (1)
rem echo CMASS=0,  >> setup.txt

rem  CONAGE=48 particle to or from puff conversions at conage (hours)
rem echo CONAGE=48,  >> setup.txt
rem echo CONAGE=9999,  >> setup.txt

rem  CPACK=1 binary concentration packing 0:none 1:nonzero 2:points 3:polar
echo CPACK=1,  >> setup.txt

rem echo CPACK=3,3,3,1  >> setup.txt

rem  DELT=0.0 integration time step (0=autoset ; greater than zero = constant ; less than zero = minimum)
rem echo DELT=0.0,  >> setup.txt
echo DELT=%time_step%,  >> setup.txt

rem  DXF=1.0 horizontal X-grid adjustment factor for ensemble
rem echo DXF=1.0,  >> setup.txt

rem  DYF=1.0 horizontal Y-grid adjustment factor for ensemble
rem echo DYF=1.0,  >> setup.txt

rem  DZF=0.01 vertical (0.01 ~ 250m) factor for ensemble
rem echo DZF=0.01,  >> setup.txt

rem  EFILE=' ' temporal emission file name

rem if [ -a './EMITIMES.txt' ] ; then ; rm './EMITIMES.txt' ; fi
rem cp %EMITIMES_DIR%%EMITIMES_FILE% './EMITIMES.txt'
rem echo EFILE='EMITIMES.txt', >> setup.txt
echo EFILE='%EMITIMES_file%',  >> setup.txt

rem  FRHMAX=3.0 maximum value for the horizontal rounding parameter
rem echo FRHMAX=3.0,  >> setup.txt

rem  FRHS=1.00 standard horizontal puff rounding fraction for merge
rem echo FRHS=1.00,  >> setup.txt

rem  FRME=0.10 mass rounding fraction for enhanced merging
rem echo FRME=0.10,  >> setup.txt

rem  FRMR=0.0 mass removal fraction during enhanced merging
rem echo FRMR=0.0,  >> setup.txt

rem  FRTS=0.10 temporal puff rounding fraction
rem echo FRTS=0.10,  >> setup.txt

rem  FRVS=0.01 vertical puff rounding fraction
rem echo FRVS=0.01,  >> setup.txt

rem  HSCALE=10800.0 horizontal Lagrangian time scale (sec)
rem echo HSCALE=10800.0,  >> setup.txt

rem  ICHEM=0 chemistry conversion modules 0:none 1:matrix 2:convert 3:dust ...
rem echo ICHEM=0,  >> setup.txt

rem new with RICHMOND, ICHEM=6 sets output to mass mixing ratio, so can then get ppb with conversion...
echo ICHEM=6,  >> setup.txt

rem  INITD=0 initial distribution, particle, puff, or combination

rem The model can be configured as either a full 3D particle or puff model, or some hybrid combination of
rem the two. The released particles or puffs maintain their mode for the entire duration of the simulation.

rem Valid options are:

rem 0 - 3D particle horizontal and vertical (DEFAULT)
rem 1 - Gaussian-horizontal and Top-Hat vertical puff (Gh-THv)
rem 2 - Top-Hat-horizontal and vertical puff (THh-THv)
rem 3 - Gaussian-horizontal puff and vertical particle distribution (Gh-Pv)
rem 4 - Top-Hat-horizontal puff and vertical particle distribution (THh-Pv)

rem Introduced with the September 2004 version are mixed mode model calculations, where the mode can change during
rem transport depending upon the age (from release) of the particle. A mixed-mode may be selected to
rem take advantage of the more accurate representation of the 3D particle approach near the source and the
rem smoother horizontal distribution provided by one of the hybrid puff approaches at the longer transport distances.
rem In a long-range or regional puff simulation, where the concentration grid may be rather coarse, puffs may pass
rem between concentration sampling nodes during the initial stages of the transport, a stage when the plume is still
rem narrow. Using mode #104 would start the simulation with particles (and concentration grid cells) and then switch
rem to puff mode (and concentration sampling nodes) when the particles are distributed over multiple concentration grid cells.

rem Valid options are:

rem 103 - 3D particle (#0) converts to Gh-Pv (#3)
rem 104 - 3D particle (#0) converts to THh-Pv (#4)
rem 130 - Gh-Pv (#3) converts to 3D particle (#0)
rem 140 - THh-Pv (#4) converts to 3D particle (#0)
rem 109 - 3D particle converts to grid (global model)

rem A new option (109) introduced with the January 2009 version (4.9), converts 3D particles to the Global Eulerian Model
rem grid. The particles are transferred to the global grid after the specified number of hours. This approach should only be
rem used for very long-range (hemispheric) transport due to the artificial diffusion introduced when converting pollutant
rem plumes to a gridded advection-diffusion computational approach. The method is ideal for estimating contributions to
rem background concentrations. All mixed-mode particles/puffs (not just 3D) will convert to the global grid if the
rem global option is selected from the special runs menu.

rem     NOTE: with new GEM code, need to set this to a conversion number (i.e., > 100)
rem     For example, INITD = 129
rem     This means that its a conversion (the first digit)
rem     it means that it starts out as a puff (the 2nd digit = 2)
rem     and the third digit is what is converts to... in this case,
rem     9 is undefined, but, this will work for conversion to GEM grid
rem     if the third digit was defined, then it would convert to defined entity

echo INITD=%dispersion%,  >> setup.txt

rem  KBLS=1 boundary layer stability derived from 1:fluxes 2:wind_temperature
rem echo KBLS=1,  >> setup.txt

rem  KBLT=2 boundary layer turbulence parameterizations 1:Beljaars 2:Kanthar 3:TKE
rem echo KBLT=2,  >> setup.txt

rem  KDEF=0 horizontal turbulence 0=vertical 1=deformation
rem echo KDEF=0,  >> setup.txt

rem  KHINP=0 when non-zero sets the age (h) for particles read from PINPF
rem echo KHINP=0,  >> setup.txt

rem  KHMAX=9999 maximum duration (h) for a particle or trajectory
rem echo KHMAX=9999,  >> setup.txt

rem  KMIXD=0 mixed layer obtained from 0:input 1:temperature 2:TKE
rem echo KMIXD=0,  >> setup.txt

rem  KMIX0=250 minimum mixing depth
echo KMIX0=25,  >> setup.txt

rem  KMSL=0 starting heights default to AGL=0 or MSL=1

rem KMSL (0) - sets the default for input heights to be relative to the terrain height of the meteorological model. Hence input
rem heights are specified as AGL. Setting this parameter to 1 forces the model to subtract the local terrain height from
rem source input heights before further processing. Hence input heights should be specified as relative to Mean Sea Level
rem (MSL). In concentration simulations, the MSL option also forces the vertical concentration grid heights to be
rem considered relative to mean sea level. The special option (xBL) sets KMSL to 2 and treats the input height as a fraction
rem of the boundary layer (or mixed layer) depth at the trajectory starting location and time. This option is not valid with
rem any multiple trajectory in time configurations or any of the concentration-dispersion calculations. Valid starting heights
rem can be defined as any non-zero fraction less than 2.0.

rem echo KMSL=0,  >> setup.txt

rem  KPUFF=0 horizontal puff dispersion linear (0) or empirical (1) growth
rem echo KPUFF=0,  >> setup.txt

rem  KRAND=2 method to calculate random number 1=precalculated 2=calculated in pardsp 3=none
rem echo KRAND=2,  >> setup.txt

rem  KRND=6 enhanced merge interval (hours)
rem echo KRND=6,  >> setup.txt

rem  KSPL=1 standard splitting interval (hours)
rem echo KSPL=1,  >> setup.txt

rem  KWET=0 precipitation from an external file
rem echo KWET=0,  >> setup.txt

rem  KZMIX=0 vertical mixing adjustments: 0=none 1=PBL-average 2=scale_TVMIX
rem echo KZMIX=0,  >> setup.txt

rem  MAXDIM=1 maximum number of pollutants to carry on one particle
echo MAXDIM=1,  >> setup.txt

rem  MAXPAR=10000 maximum number of particles carried in simulation
echo MAXPAR=%maxpar%,  >> setup.txt

rem  MESSG='MESSAGE' diagnostic message file base name
echo MESSG='MESSAGE',  >> setup.txt

rem  MGMIN=10 minimum meteorological subgrid size
rem echo MGMIN=10,  >> setup.txt

rem  NBPTYP=1 number of redistributed particle size bins per pollutant type
rem echo NBPTYP=1,  >> setup.txt

rem  NINIT=1 particle initialization (0-none; 1-once; 2-add; 3-replace)
rem echo NINIT=1,  >> setup.txt

rem  NCYCL=0 pardump output cycle time
rem echo NCYCL=0,  >> setup.txt
rem echo NCYCL=1,  >> setup.txt

rem  NDUMP=0 dump particles to/from file 0-none or nhrs-output interval
rem echo NDUMP=0,  >> setup.txt
rem echo NDUMP=1,  >> setup.txt

rem  NUMPAR=2500 number of puffs or particles to released per cycle
rem echo NUMPAR=2500,  >> setup.txt
echo NUMPAR=%numpar%,  >> setup.txt

rem  P10F=1.0 dust threshold velocity sensitivity factor
rem echo P10F=1.0,  >> setup.txt

rem  PINBC=' ' particle input file name for time-varying boundary conditions
rem echo PINBC=' ' >> setup.txt

rem  PINPF=' ' particle input file name for initialization or boundary conditions
rem echo PINPF=' ' >> setup.txt

rem  POUTF=' ' particle output file name
rem echo POUTF='pardump.bin' >> setup.txt

rem  QCYCLE=0.0 optional cycling of emissions (hours)
rem echo QCYCLE=0.0,  >> setup.txt
echo QCYCLE=%emit_cycling%,  >> setup.txt

rem note -- with EMITIMES, will just set this zero
rem echo QCYCLE=0.0,  >> setup.txt

rem  RHB=80 is the RH defining the base of a cloud
rem echo RHB=80,  >> setup.txt

rem  RHT=60 is the RH defining the top of a cloud
rem echo RHT=60,  >> setup.txt

rem  SPLITF=1.0 automatic size adjustment (<0=disable) factor for horizontal splitting
rem echo SPLITF=1.0,  >> setup.txt

rem  TKERD=0.18 unstable turbulent kinetic energy ratio = w'2/(u'2+v'2)
rem echo TKERD=0.18,  >> setup.txt

rem  TKERN=0.18 stable turbulent kinetic energy ratio
rem echo TKERN=0.18,  >> setup.txt

rem  TRATIO=0.75 advection stability ratio
rem echo TRATIO=0.75,  >> setup.txt

rem  TVMIX=1.0 vertical mixing scale factor
rem echo TVMIX=1.0,  >> setup.txt

rem  VDIST='VMSDIST' diagnostic file vertical mass distribution
rem echo VDIST='VMSDIST',  >> setup.txt

rem  VSCALE=200.0 vertical Lagrangian time scale (sec)
rem echo VSCALE=200.0,  >> setup.txt

rem  VSCALEU=200.0 vertical Lagrangian time scale (sec) for unstable PBL
rem echo VSCALEU=200.0,  >> setup.txt

rem  VSCALES=200.0 vertical Lagrangian time scale (sec) for stable PBL
rem echo VSCALES=200.0,  >> setup.txt

rem NOTE -- don't put comma as this is last entry of namelist file

rem   ---------------------------------------------------------------------------------
ECHO / >>setup.txt
rem   ---------------------------------------------------------------------------------

rem  sometimes machines go so fast that there is a problem with file handles
rem  so have put a short pause here to ensure that this does not happen
timeout 1

rename setup.txt SETUP.CFG

rem  sometimes machines go so fast that there is a problem with file handles
rem  so have put a short pause here to ensure that this does not happen
timeout 1

echo have written SETUP.CFG
rem if %PAUSES%==1 pause

rem   ----------------------------------------
rem   create ASCDATA.CFG file
rem  -----------------------------------------

rem this may need to be adjusted for using different / updated boundary files?
rem but current version in my updated Windows hysplit still has these values?

IF EXIST ASCDATA.TXT DEL ASCDATA.TXT

echo -90.0  -180.0  lat/lon of lower left corner (last record in file)  > ASCDATA.TXT
echo 1.0     1.0    lat/lon spacing in degrees between data points     >> ASCDATA.TXT
echo 180     360    lat/lon number of data points                      >> ASCDATA.TXT
echo 2              default land use category                          >> ASCDATA.TXT
echo 0.2            default roughness length (meters)                  >> ASCDATA.TXT
echo '../bdyfiles/' directory location of data files                   >> ASCDATA.TXT

IF EXIST ASCDATA.CFG DEL ASCDATA.CFG

rename ASCDATA.TXT ASCDATA.CFG

echo have written ASCDATA.CFG
echo about to run HYSPLIT

if %PAUSES%==1 pause

rem **********************************************************************
rem    NOW THAT ALL INPUTS HAVE BEEN SET, DO SIMULATION
rem **********************************************************************

IF EXIST source_detail.bin DEL source_detail.bin

IF EXIST source_coarse.bin DEL source_coarse.bin

IF EXIST MESSAGE DEL MESSAGE
IF EXIST WARNING DEL WARNING

echo about to run HYSPLIT
%EXEC_DIR%%executable%

rem **************************************************************
echo have just finished executing executable
if %PAUSES%==1 pause

rem **********************************************************************
rem    NOW MAKE A MAP OF THE OVERALL RESULTS of this simulation
rem **********************************************************************

rem **********************************************************************
rem  run concplot output concentration grid
rem **********************************************************************

rem **********************************************************************
rem  run concplot
rem **********************************************************************

rem      [Thu May 10 17:00:53] [markc@mercury2 ~/hysplit4/working_OWLETS]$ ../exec/concplot
rem       USAGE: concplot -[options (default)]
rem       -a[Arcview GIS: 0-none 1-log10 2-value 3-KML 4-partial KML]
rem       +a[KML altitude mode: (0)-clampedToGround, 1-relativeToGround]
rem       -A[KML options: 0-none 1-KML with no extra overlays]
rem       -b[Bottom display level: (0) m]
rem       -c[Contours: (0)-dyn/exp 1-fix/exp 2-dyn/lin 3-fix/lin 4-set 50-0,interval 10 51-1,interval 10]
rem       -d[Display: (1)-by level, 2-levels averaged]
rem       -e[Exposure units flag: (0)-concentrations, 1-exposure, 2-chemical threshold, 3-hypothetical volcanic ash, 4-mass loading]
rem       -f[Frames: (0)-all frames one file, 1-one frame per file]
rem       -g[Circle overlay: ( )-auto, #circ(4), #circ:dist_km]
rem       -h[Hold map at center lat-lon: (source point), lat:lon]
rem       -i[Input file name: (cdump)]
rem       -j[Graphics map background file name: (arlmap) or shapefiles.<(txt)|process suffix>]]
rem       -k[Kolor: 0-B&W, (1)-Color, 2-No Lines Color, 3-No Lines B&W]
rem       -l[Label options: ascii code, (73)-open star]
rem       +l[Use THIS IS A TEST label: (0)-no, 1-yes]
rem       -L[LatLonLabels: none=0 auto=(1) set=2:value(tenths)]
rem       -m[Map projection: (0)-Auto 1-Polar 2-Lamb 3-Merc 4-CylEqu]
rem       +m[Maximum square value: 0=none, (1)=both, 2=value, 3=square]
rem       -n[Number of time periods: (0)-all, numb, min:max, -incr]
rem       -o[Output file name: (concplot.ps)]
rem       -p[Process file name suffix: (ps) or process ID]
rem       -q[Quick data plot: ( )-none, filename]
rem       -r[Removal: 0-none, (1)-each time, 2-sum, 3-total]
rem       -s[Species: 0-sum, (1)-select, #-multiple]
rem       -t[Top display level: (99999) m]
rem       -u[Units label for mass: (mass), see "labels.cfg" file]
rem       -v[Values[:labels:RRRGGGBBB color (optional,but must have 2 colons to specify color without label)
rem            for <= 25 fixed contours: val1:lab1:RGB1+val2:lab2:RGB2+val3:lab3:RGB3+val4:lab4:RGB4]
rem       -w[Grid point scan for contour smoothing (0)-none 1,2,3, grid points]
rem       -x[Concentration multiplier: (1.0)]
rem       -y[Deposition multiplier:    (1.0)]
rem       -z[Zoom factor: 0-least zoom, (50), 100-most zoom]
rem       -1[Minimum concentration contour value when -c=0 or 1: (0.0)-none, ( )-value]
rem       -2[Minimum deposition contour value when -c=0 or 1: (0.0)-none, ( )-value]
rem       -3[Allow colors to change for dynamic contours (-c=0 or 2): (0)-no, 1-yes]
rem       -4[Plot below threshold minimum contour for chemical output (-e=2): (0)-no, 1-yes]
rem       -5[Use -o prefix name for output kml file when -a=3 or 4: (0)-no, 1-yes]
rem       -8[Create map(s) even if all values zero: (0)-no, 1-yes]
rem       -9[Force sample start time label to start of release: (0)-no, 1-yes]

rem     NOTE: leave no space between option and value

SET grid=source_coarse
SET scale=-g0:100
IF EXIST %grid%.ps DEL %grid%.ps
rem echo 0 100
rem conc multiplication factor of 0.4522E+09 if emit in kg and want output in ppb-volume SO2
SET conc_values=-x0.4522E+09 -v20+10+7+4+2+1+0.7+0.4+0.2 -uppb
%EXEC_DIR%concplot -i%grid%.bin -o%grid% -h39.18:-76.54 $scale -j..\graphics\arlmap %conc_values% %scale% -r0 

SET grid=source_detail
SET scale=-g0:100
IF EXIST %grid%.ps DEL %grid%.ps
rem echo 0 50 100 200 500 1000
rem conc multiplication factor of 0.4522E+09 if emit in kg and want output in ppb-volume SO2
SET conc_values=-x0.4522E+09 -v20+10+7+4+2+1+0.7+0.4+0.2 -uppb
rem -d2 averages all levels
%EXEC_DIR%concplot -i%grid%.bin -o%grid% -h39.18:-76.54 $scale -j..\graphics\arlmap %conc_values% %scale% -r0 -d2 -b0 -t500

echo done with running concplot

echo about to run con2asc

rem if %PAUSES%==1 pause

rem **********************************************************************
rem  RUN con2asc to convert cdump files to ascii so can do postprocessing
rem **********************************************************************

rem     [Fri Sep 14 16:09:10] [markc@mercury2 ~/hysplit4/working_ALOHA]$ ../exec/con2asc
rem      Converts binary concentration file to simple lat/lon based ascii file, one
rem     record per grid point, for any grid point with any level or pollutant not
rem      zero. One output file per sampling time period.
rem
rem      USAGE: con2asc -[options (default)]
rem        -c[Convert all records to one diagnostic file]
rem        -d[Delimit output by comma flag]
rem        -f[File flag for a file for each pollutant-level]
rem        -i[Input file name (cdump)]
rem        -m[Minimum output format flag]
rem        -o[Output file name base (cdump)]
rem        -s[Single output file flag]
rem        -t[Time expanded (minutes) file name flag]
rem        -u[Units conversion multiplier concentration (1.0)]
rem        -U[Units conversion multiplier deposition (1.0)]
rem        -v[Vary output by +lon+lat (default +lat+lon)]
rem        -x[Extended precision flag]
rem        -z[Zero points output flag]
rem
rem      NOTE: leave no space between option and value

SET grid=source_coarse

rem conc multiplication factor of 0.4522E+09 if emit in kg and want output in ppb-volume SO2

%EXEC_DIR%con2asc -i%grid%.bin -o%grid% -d -u0.4522E+09 -s -x

rem creates file called: grid.txt

rem **********************************************************************
rem  RUN con2stn to tabulate results at monitoring site
rem **********************************************************************

rem ----------------------------------------------------------
rem here are some monitoring sites of interest
rem ----------------------------------------------------------

if %monitoring_site_code%==HMI goto site_HMI

:site_HMI
rem Hart-Miller Island
SET site_lat=39.242 
SET site_long=-76.363
goto site_end

:site_end

rem [Thu May 30 16:48:13] [markc@mercury2 ~/hysplit4/working_Hg_Plume]$ ../exec/con2stn
rem  Program to read a hysplit4 concentration file and
rem  print the contents at selected locations.

rem USAGE: con2stn [-options]
rem -a[rotation angle:latitude:longitude]
rem -c[input to output concentration multiplier]
rem -d[mm/dd/yyyy format: (0)=no 1=w-Label 2=wo-Label]
rem -e[output concentration datem format: (0)=F10.1 1=ES10.4]
rem -h[half-life-days (one entry for each pollutant)]
rem -i[input concentration file name]
rem -m[maximum number of stations (200)]
rem -o[output concentration file name]
rem -p[pollutant index (1) or 0 for all pollutants]
rem -r[record format 0=record (1)=column 2=datem]
rem -s[station list file name (contains: id lat lon)]
rem -t[transfer coefficient processing]
rem -x[(n)=neighbor or i for interpolation]
rem -z[level index (1) or 0 for all levels]

rem  NOTE: con2stn does not work with polar conc grids...

echo %monitoring_site_code% %site_lat% %site_long% > station_list.txt

rem conc multiplication factor of 0.4522E+09 if emit in kg and want output in ppb-volume SO2

SET grid=source_coarse
echo about to run con2stn on grid = %grid%
%EXEC_DIR%con2stn -i%grid%.bin -o%grid%.con2stn+00deg.txt -c0.4522E+09 -xi -sstation_list.txt -z0 -r0
%EXEC_DIR%con2stn -i%grid%.bin -o%grid%.con2stn+05deg.txt -c0.4522E+09 -xi -sstation_list.txt -z0 -r0 -a5.0:%LAT%:%LONG%
%EXEC_DIR%con2stn -i%grid%.bin -o%grid%.con2stn-05deg.txt -c0.4522E+09 -xi -sstation_list.txt -z0 -r0 -a-5.0:%LAT%:%LONG%
%EXEC_DIR%con2stn -i%grid%.bin -o%grid%.con2stn+10deg.txt -c0.4522E+09 -xi -sstation_list.txt -z0 -r0 -a10.0:%LAT%:%LONG%
%EXEC_DIR%con2stn -i%grid%.bin -o%grid%.con2stn-10deg.txt -c0.4522E+09 -xi -sstation_list.txt -z0 -r0 -a-10.0:%LAT%:%LONG%
%EXEC_DIR%con2stn -i%grid%.bin -o%grid%.con2stn+15deg.txt -c0.4522E+09 -xi -sstation_list.txt -z0 -r0 -a15.0:%LAT%:%LONG%
%EXEC_DIR%con2stn -i%grid%.bin -o%grid%.con2stn-15deg.txt -c0.4522E+09 -xi -sstation_list.txt -z0 -r0 -a-15.0:%LAT%:%LONG%

SET grid=source_detail
echo about to run con2stn on grid = %grid%
%EXEC_DIR%con2stn -i%grid%.bin -o%grid%.con2stn+00deg.txt -c0.4522E+09 -xi -sstation_list.txt -z0 -r0
%EXEC_DIR%con2stn -i%grid%.bin -o%grid%.con2stn+05deg.txt -c0.4522E+09 -xi -sstation_list.txt -z0 -r0 -a5.0:%LAT%:%LONG%
%EXEC_DIR%con2stn -i%grid%.bin -o%grid%.con2stn-05deg.txt -c0.4522E+09 -xi -sstation_list.txt -z0 -r0 -a-5.0:%LAT%:%LONG%
%EXEC_DIR%con2stn -i%grid%.bin -o%grid%.con2stn+10deg.txt -c0.4522E+09 -xi -sstation_list.txt -z0 -r0 -a10.0:%LAT%:%LONG%
%EXEC_DIR%con2stn -i%grid%.bin -o%grid%.con2stn-10deg.txt -c0.4522E+09 -xi -sstation_list.txt -z0 -r0 -a-10.0:%LAT%:%LONG%
%EXEC_DIR%con2stn -i%grid%.bin -o%grid%.con2stn+15deg.txt -c0.4522E+09 -xi -sstation_list.txt -z0 -r0 -a15.0:%LAT%:%LONG%
%EXEC_DIR%con2stn -i%grid%.bin -o%grid%.con2stn-15deg.txt -c0.4522E+09 -xi -sstation_list.txt -z0 -r0 -a-15.0:%LAT%:%LONG%

rem **********************************************************************
rem      rename OUTPUT files to include RUN NAME
rem **********************************************************************

IF EXIST CONTROL rename CONTROL %run_name%.ctl
IF EXIST MESSAGE rename MESSAGE %run_name%.msg
IF EXIST SETUP.CFG rename SETUP.CFG %run_name%.cfg
IF EXIST WARNING rename WARNING %run_name%.warn
IF EXIST %EMITIMES_file% copy %EMITIMES_file% %run_name%.EMITIMES
IF EXIST station_list.txt copy station_list.txt %run_name%.station_list.txt

SET grid=source_coarse
IF EXIST %grid%.bin rename %grid%.bin %run_name%.%grid%.bin
IF EXIST %grid%.ps rename %grid%.ps %run_name%.%grid%.ps
IF EXIST %grid%.txt rename %grid%.txt %run_name%.%grid%.txt
IF EXIST %grid%.con2stn.txt rename %grid%.con2stn.txt %run_name%.%grid%.con2stn.txt
IF EXIST %grid%.con2stn+00deg.txt rename %grid%.con2stn+00deg.txt %run_name%.%grid%.con2stn+00deg.txt
IF EXIST %grid%.con2stn+05deg.txt rename %grid%.con2stn+05deg.txt %run_name%.%grid%.con2stn+05deg.txt
IF EXIST %grid%.con2stn+10deg.txt rename %grid%.con2stn+10deg.txt %run_name%.%grid%.con2stn+10deg.txt
IF EXIST %grid%.con2stn+15deg.txt rename %grid%.con2stn+15deg.txt %run_name%.%grid%.con2stn+15deg.txt
IF EXIST %grid%.con2stn-05deg.txt rename %grid%.con2stn-05deg.txt %run_name%.%grid%.con2stn-05deg.txt
IF EXIST %grid%.con2stn-10deg.txt rename %grid%.con2stn-10deg.txt %run_name%.%grid%.con2stn-10deg.txt
IF EXIST %grid%.con2stn-15deg.txt rename %grid%.con2stn-15deg.txt %run_name%.%grid%.con2stn-15deg.txt


SET grid=source_detail
IF EXIST %grid%.bin rename %grid%.bin %run_name%.%grid%.bin
IF EXIST %grid%.ps rename %grid%.ps %run_name%.%grid%.ps
IF EXIST %grid%.txt rename %grid%.txt %run_name%.%grid%.txt
IF EXIST %grid%.con2stn.txt rename %grid%.con2stn.txt %run_name%.%grid%.con2stn.txt
IF EXIST %grid%.con2stn+00deg.txt rename %grid%.con2stn+00deg.txt %run_name%.%grid%.con2stn+00deg.txt
IF EXIST %grid%.con2stn+05deg.txt rename %grid%.con2stn+05deg.txt %run_name%.%grid%.con2stn+05deg.txt
IF EXIST %grid%.con2stn+10deg.txt rename %grid%.con2stn+10deg.txt %run_name%.%grid%.con2stn+10deg.txt
IF EXIST %grid%.con2stn+15deg.txt rename %grid%.con2stn+15deg.txt %run_name%.%grid%.con2stn+15deg.txt
IF EXIST %grid%.con2stn-05deg.txt rename %grid%.con2stn-05deg.txt %run_name%.%grid%.con2stn-05deg.txt
IF EXIST %grid%.con2stn-10deg.txt rename %grid%.con2stn-10deg.txt %run_name%.%grid%.con2stn-10deg.txt
IF EXIST %grid%.con2stn-15deg.txt rename %grid%.con2stn-15deg.txt %run_name%.%grid%.con2stn-15deg.txt

rem **********************************************************************
rem     MOVE FILE to RESULTS SUBDIRECTORIES
rem **********************************************************************

IF EXIST %run_name%.ctl MOVE %run_name%.ctl %RESULTS_DIR%
IF EXIST %run_name%.cfg MOVE %run_name%.cfg %RESULTS_DIR%
IF EXIST %run_name%.msg MOVE %run_name%.msg %RESULTS_DIR%
IF EXIST %run_name%.warn MOVE %run_name%.warn %RESULTS_DIR%
IF EXIST %run_name%.EMITIMES MOVE %run_name%.EMITIMES %RESULTS_DIR%
IF EXIST %run_name%.station_list.txt MOVE %run_name%.station_list.txt %RESULTS_DIR%

SET grid=source_coarse
IF EXIST %run_name%.%grid%.bin MOVE %run_name%.%grid%.bin %RESULTS_DIR%
IF EXIST %run_name%.%grid%.ps MOVE %run_name%.%grid%.ps %RESULTS_DIR%
IF EXIST %run_name%.%grid%.txt MOVE %run_name%.%grid%.txt %RESULTS_DIR%
IF EXIST %run_name%.%grid%.con2stn.txt MOVE %run_name%.%grid%.con2stn.txt %RESULTS_DIR%

IF EXIST %run_name%.%grid%.con2stn+00deg.txt MOVE %run_name%.%grid%.con2stn+00deg.txt %RESULTS_DIR%
IF EXIST %run_name%.%grid%.con2stn+05deg.txt MOVE %run_name%.%grid%.con2stn+05deg.txt %RESULTS_DIR%
IF EXIST %run_name%.%grid%.con2stn+10deg.txt MOVE %run_name%.%grid%.con2stn+10deg.txt %RESULTS_DIR%
IF EXIST %run_name%.%grid%.con2stn-05deg.txt MOVE %run_name%.%grid%.con2stn-05deg.txt %RESULTS_DIR%
IF EXIST %run_name%.%grid%.con2stn-10deg.txt MOVE %run_name%.%grid%.con2stn-10deg.txt %RESULTS_DIR%
IF EXIST %run_name%.%grid%.con2stn-15deg.txt MOVE %run_name%.%grid%.con2stn-15deg.txt %RESULTS_DIR%
IF EXIST %run_name%.%grid%.con2stn+15deg.txt MOVE %run_name%.%grid%.con2stn+15deg.txt %RESULTS_DIR%

SET grid=source_detail
IF EXIST %run_name%.%grid%.bin MOVE %run_name%.%grid%.bin %RESULTS_DIR%
IF EXIST %run_name%.%grid%.ps MOVE %run_name%.%grid%.ps %RESULTS_DIR%
IF EXIST %run_name%.%grid%.txt MOVE %run_name%.%grid%.txt %RESULTS_DIR%
IF EXIST %run_name%.%grid%.con2stn.txt MOVE %run_name%.%grid%.con2stn.txt %RESULTS_DIR%

IF EXIST %run_name%.%grid%.con2stn+00deg.txt MOVE %run_name%.%grid%.con2stn+00deg.txt %RESULTS_DIR%
IF EXIST %run_name%.%grid%.con2stn+05deg.txt MOVE %run_name%.%grid%.con2stn+05deg.txt %RESULTS_DIR%
IF EXIST %run_name%.%grid%.con2stn+10deg.txt MOVE %run_name%.%grid%.con2stn+10deg.txt %RESULTS_DIR%
IF EXIST %run_name%.%grid%.con2stn-05deg.txt MOVE %run_name%.%grid%.con2stn-05deg.txt %RESULTS_DIR%
IF EXIST %run_name%.%grid%.con2stn-10deg.txt MOVE %run_name%.%grid%.con2stn-10deg.txt %RESULTS_DIR%
IF EXIST %run_name%.%grid%.con2stn-15deg.txt MOVE %run_name%.%grid%.con2stn-15deg.txt %RESULTS_DIR%
IF EXIST %run_name%.%grid%.con2stn+15deg.txt MOVE %run_name%.%grid%.con2stn+15deg.txt %RESULTS_DIR%

echo done with SET_CONC script
