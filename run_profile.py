# -*- coding: utf-8 -*-
"""
Created on Thu Oct 29 12:59:22 2020

@author: Magnolia

HYSPLIT Profile

"""

import subprocess
from pathlib import Path

# -------------------------- #
# --- Constants            - #
# -------------------------- #

HMI_lat = 39.242
HMI_lon = -76.363

UMBC_lat = 39.254
UMBC_lon = -76.709

BrSh_lat = 39.1792
BrSh_lon = -76.5383

# -------------------------- #
# -- Paths                 - #
# -------------------------- #

metdir = r'D:\HYSPLIT_Stuff\MetData\WRF\d03\\'

metfile = r'wrfout_d03_20180701.ARL'

executable = r'D:\HYSPLIT_Stuff\hysplit\exec\profile.exe'

#%%
# -------------------------- #
# -- RUN HYSPLIT PROFILE   - #
# -------------------------- #

def run_profile(metdir, metfile, lat, lon, off=0, interval=1, duration=9999, wdir=1, e=0, run_name=None, output_path=None):

    # Usage: profile [-options]
    #  -d[Input metdata directory name with ending /]
    #  -f[input metdata file name]
    #  -y[Latitude]
    #  -x[Longitude]
    #  -o[Output time offset (hrs)]
    #  -t[Output time interval (hrs)]
    #  -n[Hours after start time to stop output (hrs))]
    #  -w[Wind direction instead of components=1]
    #  -p[process ID number for output text file]
    #  -e[extra digit in output values (0)-no, 1-yes]

    # Check that the Data path is valid
    data_path = Path(metdir) / Path(metfile);
    if not data_path.exists():
        print('\n Filepath not found')
        return

    run = [executable,
           f'-d{metdir}',
           f'-f{metfile}',
           f'-y{lat}',
           f'-x{lon}',
           f'-o{off}',
           f'-t{interval}',
           f'-n{duration}',
           f'-w{wdir}',
           f'-e{e}']

    run_str = ' '.join(run)
    print(f'\n Parameters Set: \n {run_str}')

    print('\n Running HYSPLIT profile')
    with open('profile_1.txt', 'w') as f:
        f.write(run_str)
        process = subprocess.run(run, stdout=f, text=True)
        if process.returncode == 0: print('\n PROFILE COMPLETE')
        else: print('\n Oops, There was an error'); return


    # MOVING FILES
    if output_path:
        output_path = Path(output_path)

        if not output_path.exists():
            print('\n Output path not found \n')
            answer = input(f' \n Would you like to create this path? (Y, N) \n {output_path} \n Choice = ')

            if answer.lower() == 'Y':
                print('\n Creating Directory\n ')
                output_path.mkdir()

            if answer.lower() == 'N':
                print('\n Output will be in the current directory \n')


    # MOVING FILES
    print('\n Moving Files')
    files = ['MESSAGE', 'WARNING', 'profile.txt']
    for file in files:
        try:
            if file == 'profile.txt':

                if run_name:
                    new_file = run_name

                else:
                    new_file = f"profile.{metfile.split('.')[0]}.txt"

            else: new_file = file + '.txt'

            filepath = Path.cwd() / file

            if filepath.exists():

                if output_path:
                    output_path = Path(output_path)

                    if not output_path.exists():
                        print('\n Output path not found \n')
                        answer = input(f' \n Would you like to create this path? (Y, N) \n {output_path} \n Choice = ')

                        if answer.lower() == 'Y':
                            print('\n Creating Directory\n ')
                            output_path.mkdir()
                            new_path = output_path / new_file

                        if answer.lower() == 'N':
                            print('\n Output will be in the current directory \n')
                            new_path = filepath.parent / new_file

                    else: new_path = output_path / new_file

                else: new_path = filepath.parent / new_file

                filepath.replace(new_path)

        except: print('Oops, I messed up. There was an issue')

    print(f'Process Complete Ckeck -> {new_path.parent}')

    return

#%% Testing
test_path = r'C:\Users\Magnolia\OneDrive - UMBC\Research\Summer 2020\NERTO\Code\Python\Projects\Test'
run_profile(metdir, metfile, HMI_lat, HMI_lon, output_path=test_path)

