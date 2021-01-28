# -*- coding: utf-8 -*-
"""
Created on Thu Oct 29 20:59:58 2020

@author: Magnolia

"""
from pathlib import Path
import HYSPLIT_PROFILE as Profile
import matplotlib.pyplot as plt

# -------------------------- #
# --- Constants            - #
# -------------------------- #

HMI_lat = 39.242
HMI_lon = -76.363

UMBC_lat = 39.254
UMBC_lon = -76.709

BrSh_lat = 39.1792
BrSh_lon = -76.5383

lat = [HMI_lat, UMBC_lat, BrSh_lat]
lon = [HMI_lon, UMBC_lon, BrSh_lon]
loc = ['HMI', 'UMBC', 'BrSh']

#%% RUN PROFILE.EXE

# ARW-WRF
for i in [1,2,3]:
    metdir = f'D:\HYSPLIT_Stuff\MetData\WRF\d0{i}\\'
    print(f'{metdir}')
    metfile = f'wrfout_d0{i}_20180701.ARL'
    print(f'File: {metfile}')
    output_path = Path(r"C:\Users\Magnolia\OneDrive - UMBC\Research\Summer 2020\NERTO\Code\Python\Projects\WRF_Profiles")
    for j in [0,1,2]:
        Profile.run_profile(metdir, metfile, lat[j], lon[j], run_name=f"{loc[j]}_{metfile.split('.')[0]}", output_path=output_path)

#%% RUN PROFILE.EXE

# ARW-WRF
for i in [1,2,3]:
    metfile = f'wrfout_d0{i}_20180701.ARL'
    # print(f'File: {metfile}')
    output_path = Path(r"C:\Users\Magnolia\OneDrive - UMBC\Research\Summer 2020\NERTO\Code\Python\Projects\WRF_Profiles")
    for j in [0,1,2]:
        file = f"profile.{loc[j]}_{metfile.split('.')[0]}.txt"
        Profile.import_profile(Path(output_path / file))
        profile = Profile.grab_pkl(output_path / file.replace('.txt', '.pkl'))
        Profile.get_grid(profile)
        save = Path(output_path / file.replace('.txt', ''))
        HYSPLIT_PBLH, UsedGrid, date_time = Profile.PBLH(profile, title=f"{loc[j]} WRFd0{i}", sav_nam=f"{save}")

#%% SONDE vs HYSPLIT

# Run (ict)_Sondes.py first

for i in [1,2,3]:
    metfile = f'wrfout_d0{i}_20180701.ARL'
    # print(f'File: {metfile}')
    output_path = Path(r"C:\Users\Magnolia\OneDrive - UMBC\Research\Summer 2020\NERTO\Code\Python\Projects\WRF_Profiles")
    file = f"profile.HMI_{metfile.split('.')[0]}.txt"
    Profile.import_profile(Path(output_path / file))
    profile = Profile.grab_pkl(output_path / file.replace('.txt', '.pkl'))
    Profile.get_grid(profile)
    save = Path(output_path / file.replace('.txt', ''))
    HYSPLIT_PBLH, UsedGrid, date_time = Profile.PBLH(profile, title=f"HMI WRFd0{i}", sav_nam=f"{save}", plot_it=0)

    plt.figure(figsize=(10,6))
    plt.plot(date_time, HYSPLIT_PBLH, 'ok', linewidth=2, label='WRF PBLH')
    plt.plot(datetime(2018, 7, 1, 17, 15, 34), Sonde_PBLH['2018-07-01 17:15:34']*1000, '*b', markersize=10, label='2018-07-01 17:15:34')
    plt.plot(datetime(2018, 7, 1, 20, 2, 10), Sonde_PBLH['2018-07-01 20:02:10']*1000, '*r', markersize=10, label='2018-07-01 20:02:10')
    plt.title(f'({UsedGrid[0][0][0]}, {UsedGrid[0][0][1]}) HMI WRFd0{i} [{date_time[0].year},{date_time[0].month},{date_time[0].day}]')
    plt.ylabel('Altitude (m AGL)')
    plt.xlabel('Hours (UTC)')
    plt.ylim(0, 3000)
    plt.legend()
    plt.savefig(f'{save}_with_Sond.png', dpi=600)


