# -*- coding: utf-8 -*-
"""
Created on Mon Nov  9 11:34:58 2020

@author: Magnolia

HYSPLIT vmixing
"""

import subprocess
from pathlib import Path

import pandas as pd

import os
import glob



def vmixing(parms):
    for i in range(0, len(parms['Run Name'])):
           control = f"{parms['Year'][i]} {parms['Month'][i]} {parms['Day'][i]} {parms['Hour'][i]} 00 \n1 \n{parms['Latitude'][i]} {parms['Longitute'][i]} {parms['Height'][i]} \n{parms['Duration'][i]} \n0 \n10000.0 \n1 \n{parms['Metdir'][i]} \n{parms['Metfile'][i]}"

           with open('CONTROL', 'w+') as f:
               f.write(control)

           print(f"CONTROL for {parms['Run Name'][i]} -> COMPLETE")

           setup = f"^&SETUP \nKMIXD = {parms['KMIXD'][0]}, \nKMIX0 = {parms['KMIX0'][0]}, \n\\"

           with open('SETUP.CFG', 'w+') as f:
               f.write(setup)

           print(f"SETUP.CFG for {parms['Run Name'][i]} -> COMPLETE")

           # print("\n Running vmixing")

           executable = r"D:\HYSPLIT_Stuff\hysplit\exec\vmixing.exe"


        # USAGE: vmixing (optional arguments)
        #   -p[process ID]
        #   -s[KBLS - stability method (1=default)]
        #   -t[KBLT - PBL mixing scheme (2=default)]
        #   -d[KMIXD - Mixing height scheme (0=default)]
        #   -l[KMIX0 - Min Mixing height (50=default)]
        #   -a[CAMEO optional variables (0[default]=No, 1=Yes, 2=Yes + Wind Direction]
        #   -m[TKEMIN - minimum TKE limit for KBLT=3 (0.001=default)]
        #   -w[an extra file for turbulent velocity variance (0[default]=No,1=Yes)]

           run = [executable,
               f"-s{parms['KBLS'][i]}",
               f"-t{parms['KBLT'][i]}",
               f"-l{parms['KMIXD'][i]}",
               f"-d{parms['Extra Var'][i]}",
               "-a2"]

           run_str = ' '.join(run)
           print(f'\nParameters Set: \n {run_str}')

           print('\nRunning HYSPLIT vmixing')
           with open('vmix_console.txt', 'w') as f:
               f.write(run_str)
               process = subprocess.run(run, stdout=f, text=True)
               if process.returncode == 0: print('\nVmixing COMPLETE')
               else: print('\nOops, There was an error')

           # MOVING FILES
           if parms['Output Path'][i]:
               output_path = Path(parms['Output Path'][i])

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
           files = ['MESSAGE..txt', 'WARNING', 'STABILITY..txt', 'CONTROL']
           for file in files:
               try:
                   if parms['Run Name'][i]:
                       new_file = f"{parms['Run Name'][i]}.{file.replace('..txt', '')}.txt"

                   else:
                       new_file = f"{parms['Metfile'][i].split('.')[0]}.{file.replace('..txt','')}.txt"

                   filepath = Path.cwd() / file

                   if filepath.exists():

                       if output_path:
                           output_path = Path(output_path)

                           if not output_path.exists():
                               print('\n Output path not found \n')
                               answer = input(f' \n Would you like to create this path? (Y, N) \n {output_path} \n Choice = ')

                               if answer.lower() == 'y':
                                   print('\n Creating Directory\n ')
                                   output_path.mkdir()
                                   new_path = output_path / new_file

                               if answer.lower() == 'n':
                                   print('\n Output will be in the current directory \n')
                                   new_path = filepath.parent / new_file

                           else: new_path = output_path / new_file

                       else: new_path = filepath.parent / new_file

                       filepath.replace(new_path)

               except: print('Oops, I messed up. There was an issue')

           print(f'Process Complete Ckeck -> {new_path.parent}')

    return


def importing(data_path):
    # current = os.getcwd()
    data = {}
    ID = {}
    print(f'\n Importing STABILITY output -> {data_path}')
    for filename in glob.glob(os.path.join(data_path, '*.stability.txt')):
        """Search for the given string in file and return lines containing that string,
        along with line numbers"""

        with open(filename, 'r') as f:
            line = f.readline()
            ID[filename.split('\\')[-1]] = line.replace('  ', '').split(' ')
            # columns = f.readline().split("\s+")
            # units = f.readline().split()
            # print(units)
        # GET MARK TO FIX VMIXING.exe STABIlITY..txt IS FORMATED INCORRECTLY
        # cols = []
        # for i in len():
        #     cols.append(f"{columns} {units}")

        with open(filename, 'r') as f:
            data[filename.split('\\')[-1]] = pd.read_fwf(f, header=None, skiprows=3)

    return ID, data

import matplotlib.pyplot as plt
import matplotlib.dates as mdates
def MixHeight(data_dict, plot='on'):
    MxHgt = {}
    for key in data_dict:
        time = pd.to_datetime(data_dict[key][0], unit='D', origin=pd.Timestamp('2017-12-31 00:00'))
        MxHgt[key.split('.')[0]] = pd.DataFrame({'JDAY': data_dict[key][0],'UTC': time, 'MxHgt': data_dict[key][7]})

    if plot.lower() == "on":
        for key in data_dict:
            k = key.split('.')[0]
            plt.figure(figsize=(10, 6))
            ax = plt.subplot()
            ax.plot(MxHgt[k]['UTC'], MxHgt[k]['MxHgt'])
            ax.set_title(k, pad=10)
            ax.set_ylabel('Altitude (m AGL)')
            ax.set_xlabel('Hours:Minutes (UTC)')
            ax.xaxis.set_major_formatter(mdates.DateFormatter("%H:%M"))
            ax.xaxis.set_major_locator(mdates.HourLocator(interval=3))   #to get a tick every 15 minutes
            ax.set_xlim([MxHgt[k]['UTC'].iloc[0], MxHgt[k]['UTC'].iloc[0]+pd.Timedelta(days=1)])
            plt.rcParams.update({'font.size': 18})
            plt.savefig(f".\WRF_Stability\{k}.MxHgt.png", dpi=600)

    return MxHgt



#%%

parms = {'Latitude': ['39.254', '39.6'],
         'Longitute': ['-76.709', '-76.2'],
         'Height': ['0.0', '0.0'],
         'Metdir': [r'D:\HYSPLIT_Stuff\MetData\WRF\d03\\',
                    r'D:\HYSPLIT_Stuff\MetData\WRF\d03\\'],
         'Metfile': [r'wrfout_d03_20180701.ARL',
                     r'wrfout_d03_20180701.ARL'],
         'Run Name': [r'UMBC_vmix_20180701_d03_KMIXD_1',
                      r'IDK_vmix_20180701_d03_KMIXD_1'],
         'KBLS': ['1', '1'], 'KBLT': ['2', '2'], 'Extra Var': ['2', '2'],
         'Year': ['00', '00'], 'Month': ['00', '00'], 'Day': ['00', '00'], 'Hour': ['00', '00'],
         'Duration': ['9999', '9999'], 'KMIXD': ['1', '2'], 'KMIX0': ['0', '0'],
         'Output Path': [r'WRF_Stability', r'WRF_Stability']}

# vmixing(parms)
test = importing(r"C:\Users\Magnolia\OneDrive - UMBC\Research\Summer 2020\NERTO\Code\Python\Projects\WRF_Stability")

MxHgt = MixHeight(test[1])
#%%

# for
# parms = {'Latitude': ['39.254', '39.6'],
#          'Longitute': ['-76.709', '-76.2'],
#          'Height': ['0.0', '0.0'],
#          'Metdir': [r'D:\HYSPLIT_Stuff\MetData\WRF\d03\\',
#                     r'D:\HYSPLIT_Stuff\MetData\WRF\d03\\'],
#          'Metfile': [r'wrfout_d03_20180701.ARL',
#                      r'wrfout_d03_20180701.ARL'],
#          'Run Name': [r'UMBC_vmix_20180701_d03_KMIXD_1',
#                       r'IDK_vmix_20180701_d03_KMIXD_1'],
#          'KBLS': ['1', '1'], 'KBLT': ['2', '2'], 'Extra Var': ['2', '2'],
#          'Year': ['00', '00'], 'Month': ['00', '00'], 'Day': ['00', '00'], 'Hour': ['00', '00'],
#          'Duration': ['9999', '9999'], 'KMIXD': ['1', '2'], 'KMIX0': ['0', '0'],
#          'Output Path': [r'WRF_Stability', r'WRF_Stability']}

# print(parms)

