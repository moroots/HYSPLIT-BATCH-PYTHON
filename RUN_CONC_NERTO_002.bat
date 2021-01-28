@ECHO OFF

rem RUN_CONC_NERTO_001.ksh
rem    first try for initial NERTO runs
rem    based on SET_CONC_BV_001.ksh
rem    based on SET_CONC_RICHMOND_005.ksh

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

rem      0: no cycling, just 1 hour of emissions at the specified rate (or, if using EMITIMES)

rem      1: cycling every hour, so 1 hr emissions specified are repeated every hour
rem         this makes the emissions continuous throughout the run at the specified rate

rem parameter     #16: dispersion scheme

rem parameter     #17: numpar

rem parameter     #18: maxpar

rem parameter     #19: fixed time step (minutes)

rem parameter     #20: Environment (1=NOAA)
rem parameter     #21: executable
rem parameter     #22: base_results_dir

rem parameter     #23: monitoring_site_code
rem parameter     #24: EMITIMES file

rem file:///pub/archives/owlets2/wrfout_d01_20180630.ARL
rem file:///pub/archives/owlets2/wrfout_d01_20180701.ARL
rem file:///pub/archives/owlets2/wrfout_d01_20180702.ARL

rem *************************
rem run_name=BRS_test_002
rem *************************

SET start_year=2018 && SET start_month=07 && SET start_day=01 && SET start_hour=01 && SET start_minute=00 && SET run_duration=22 && SET run_name=BRS_test_002 && SET met_dir=J:\ARCHIVE\MET_DATA\WRF_OWLETS2\ && SET met_file_01=wrfout_d01_20180701.ARL && SET met_file_02=wrfout_d01_20180701.ARL && SET met_file_03=wrfout_d01_20180701.ARL && SET emit_site_code=BRS && SET pollutant=NDEP && SET emit_g_hr=1.0 && SET emit_cycle_hrs=0 && SET dispersion_scheme=0 && SET numpar=100 && SET maxpar=2500 && SET timestep=5 && SET ENVR=1 && SET exec=hycs_std && SET base_results_dir=/home/markc/hysplit4/results && SET monitoring_site_code=HMI && SET EMITIMES_file=EMITIMES_BRS_July_01_2018.txt

SET SET_SCRIPT=SET_CONC_NERTO_002.bat

rem %SET_SCRIPT% %start_year% %start_month% %start_day% %start_hour% %start_minute% %run_duration% %run_name% %met_dir% %met_file_01% %met_file_02% %met_file_03% %emit_site_code% %pollutant% %emit_g_hr% %emit_cycle_hrs% %dispersion_scheme% %numpar% %maxpar% %timestep% %ENVR% %exec% %base_results_dir% %monitoring_site_code% %EMITIMES_file%

rem *************************
rem run_name=BRS_test_003
rem *************************

SET start_year=2018 && SET start_month=07 && SET start_day=01 && SET start_hour=01 && SET start_minute=00 && SET run_duration=22 && SET run_name=BRS_test_003 && SET met_dir=J:\ARCHIVE\MET_DATA\WRF_OWLETS2\ && SET met_file_01=wrfout_d01_20180701.ARL && SET met_file_02=wrfout_d01_20180701.ARL && SET met_file_03=wrfout_d01_20180701.ARL && SET emit_site_code=BRS && SET pollutant=NDEP && SET emit_g_hr=1.0 && SET emit_cycle_hrs=0 && SET dispersion_scheme=0 && SET numpar=1000 && SET maxpar=25000 && SET timestep=0 && SET ENVR=1 && SET exec=hycs_std && SET base_results_dir=/home/markc/hysplit4/results && SET monitoring_site_code=HMI && SET EMITIMES_file=EMITIMES_BRS_July_01_2018.txt

SET SET_SCRIPT=SET_CONC_NERTO_002.bat

rem %SET_SCRIPT% %start_year% %start_month% %start_day% %start_hour% %start_minute% %run_duration% %run_name% %met_dir% %met_file_01% %met_file_02% %met_file_03% %emit_site_code% %pollutant% %emit_g_hr% %emit_cycle_hrs% %dispersion_scheme% %numpar% %maxpar% %timestep% %ENVR% %exec% %base_results_dir% %monitoring_site_code% %EMITIMES_file%

rem ********************************
rem run_name=BRS_20180701_d03_base
rem ********************************

SET start_year=2018 && SET start_month=07 && SET start_day=01 && SET start_hour=01 && SET start_minute=00 && SET run_duration=22 && SET run_name=BRS_20180701_d03_base && SET met_dir=J:\ARCHIVE\MET_DATA\WRF_OWLETS2\ && SET met_file_01=wrfout_d03_20180701.ARL && SET met_file_02=wrfout_d03_20180701.ARL && SET met_file_03=wrfout_d03_20180701.ARL && SET emit_site_code=BRS && SET pollutant=NDEP && SET emit_g_hr=1.0 && SET emit_cycle_hrs=0 && SET dispersion_scheme=0 && SET numpar=10000 && SET maxpar=250000 && SET timestep=0 && SET ENVR=1 && SET exec=hycs_std && SET base_results_dir=/home/markc/hysplit4/results && SET monitoring_site_code=HMI && SET EMITIMES_file=EMITIMES_BRS_July_01_2018.txt

SET SET_SCRIPT=SET_CONC_NERTO_002.bat

rem %SET_SCRIPT% %start_year% %start_month% %start_day% %start_hour% %start_minute% %run_duration% %run_name% %met_dir% %met_file_01% %met_file_02% %met_file_03% %emit_site_code% %pollutant% %emit_g_hr% %emit_cycle_hrs% %dispersion_scheme% %numpar% %maxpar% %timestep% %ENVR% %exec% %base_results_dir% %monitoring_site_code% %EMITIMES_file%

rem **********************************
rem run_name=BRS_20180701_d03_rotate
rem **********************************

SET start_year=2018 && SET start_month=07 && SET start_day=01 && SET start_hour=01 && SET start_minute=00 && SET run_duration=22 && SET run_name=BRS_20180701_d03_rotate && SET met_dir=J:\ARCHIVE\MET_DATA\WRF_OWLETS2\ && SET met_file_01=wrfout_d03_20180701.ARL && SET met_file_02=wrfout_d03_20180701.ARL && SET met_file_03=wrfout_d03_20180701.ARL && SET emit_site_code=BRS && SET pollutant=NDEP && SET emit_g_hr=1.0 && SET emit_cycle_hrs=0 && SET dispersion_scheme=0 && SET numpar=10000 && SET maxpar=250000 && SET timestep=0 && SET ENVR=1 && SET exec=hycs_std && SET base_results_dir=/home/markc/hysplit4/results && SET monitoring_site_code=HMI && SET EMITIMES_file=EMITIMES_BRS_July_01_2018.txt

SET SET_SCRIPT=SET_CONC_NERTO_003.bat

%SET_SCRIPT% %start_year% %start_month% %start_day% %start_hour% %start_minute% %run_duration% %run_name% %met_dir% %met_file_01% %met_file_02% %met_file_03% %emit_site_code% %pollutant% %emit_g_hr% %emit_cycle_hrs% %dispersion_scheme% %numpar% %maxpar% %timestep% %ENVR% %exec% %base_results_dir% %monitoring_site_code% %EMITIMES_file%

