# -*- coding: utf-8 -*-
"""
Created on Thu Oct 29 20:03:55 2020

@author: Magnolia

HYSPLIT_PROFILE

"""
#
import subprocess
from pathlib import Path

import numpy as np
import pandas as pd
import pickle

import matplotlib.pyplot as plt
from datetime import datetime

#%% -------------------------- #
# --- RUN HYSPLIT PROFILE    - #
# ---------------------------- #

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

    executable = r'D:\HYSPLIT_Stuff\hysplit\exec\profile.exe'

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
                    new_file = f"{run_name}.profile.txt"

                else:
                    new_file = f"{metfile.split('.')[0]}.profile.txt"

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

#%% -------------------------- #
# --- IMPORT PROFILE         - #
# ---------------------------- #

def import_profile(filepath):
    with open(filepath) as f:
        profile={}; x = 0

        count = 0
        for line_1 in f:

            count += 1

            if count == 1:
                name = line_1


            if count == 2:
                start = line_1.split(': ')[-1]


            if count == 3:
                stop = line_1.split(': ')[-1]

            if line_1.split(':')[0] == ' Profile Time':
                prf_ID=line_1.split(':  ')[-1].split('\n')[0]
                l = 0; x += 1

                for line_2 in f:

                    l += 1

                    if l == 1:
                        Near_Grid = line_2

                    if l == 3:
                        names = line_2.split()

                    if l == 4:
                        units_2D = line_2.split()

                    if l==5:
                        data = np.array([line_2.split()[1:]]).astype(float)
                        Fields_2D = pd.DataFrame(data, columns=names)

                    if l == 7: header = line_2.split()

                    if l == 8: units_3D = line_2.split()

                    if l == 9:
                        contents = np.array([line_2.split()[1:]]).astype(float)
                        for line_3 in f:
                            if line_3.split() == []: break
                            # print(np.array(line.split()[1:]))
                            content = np.array([line_3.split()[1:]]).astype(float)
                            contents = np.append(contents, content, axis=0)
                        Fields_3D = pd.DataFrame(data=contents, columns=header)
                    # print(line_3.split())
                    if line_2.replace('_', '').split() == []: break

                profile[prf_ID] = {'Used Grid': Near_Grid,
                                   '2D Fields': Fields_2D,
                                   '2D Units': units_2D,
                                   '3D Fields': Fields_3D,
                                   '3D Units': units_3D}

    filepath = str(filepath)
    with open(f"{filepath.replace('.txt', '.pkl')}", 'wb') as savefile:
        pickle.dump(profile, savefile)

    return profile

#%% -------------------------- #
# --- Getting the Pickle     - #
# ---------------------------- #

def grab_pkl(filename):
    with open(filename, 'rb') as f:
        profile = pickle.load(f)
    return profile

#%% -------------------------- #
# --- Getting the Grid       - #
# ---------------------------- #

def get_grid(profile):
    UsedGrid = []
    date_time = []
    for key in profile.keys():
        test = np.array([profile[key]['Used Grid'].replace(',', '').split()])[:, [9, 11]].astype(float)
        UsedGrid.append(test)
        date_time.append(datetime.strptime(key, "%y %m %d %H %M"))
    return UsedGrid, date_time

#%% -------------------------- #
# --- Grab PBLH              - #
# ---------------------------- #

def PBLH(profile, plot_it=1, title=None, sav=1, sav_nam=None):

    PBLH = []
    UsedGrid = []
    date_time = []

    for key in profile.keys():
        PBLH.append(profile[key]['2D Fields']['PBLH'].iloc[0])
        test = np.array([profile[key]['Used Grid'].replace(',', '').split()])[:, [9, 11]].astype(float)
        UsedGrid.append(test)
        date_time.append(datetime.strptime(key, "%y %m %d %H %M"))

    if plot_it == 1:
        plt.figure(figsize=(10,6))
        plt.plot(date_time, PBLH, 'o-k', linewidth=2, label='WRF PBLH')
        if not title:
            plt.title(f'[{date_time[0].year},{date_time[0].month},{date_time[0].day}] PBLH: ({UsedGrid[0][0][0]}, {UsedGrid[0][0][1]})')
        elif type(title) is str:
            plt.title(f'({UsedGrid[0][0][0]}, {UsedGrid[0][0][1]}) {title} [{date_time[0].year},{date_time[0].month},{date_time[0].day}]')
        plt.ylabel('Altitude (m AGL)')
        plt.xlabel('Hours (UTC)')
        plt.ylim(0, 3000)
        plt.legend()

    if sav==1:
        plt.savefig(f'{sav_nam}.png', dpi=600)
        # print(f'SAVE -> {sav_nam}')

    return PBLH, UsedGrid, date_time
