# -*- coding: utf-8 -*-
"""
Created on Sun Oct 25 07:59:05 2020

@author: Magnolia

PLOT HYSPLIT PROFILE

"""

from read_hysplit_profile import grab_pkl
import matplotlib.pyplot as plt
from datetime import datetime
import numpy as np
import matplotlib as mpl

filepath=r'C:\Users\Magnolia\OneDrive - UMBC\Research\Summer 2020\NERTO\Code\Python\Projects\profile.HMI_WRFd03_20180701.pkl'
profile = grab_pkl(filepath)

def get_grid(profile = profile):
    UsedGrid = []
    date_time = []
    for key in profile.keys():
        test = np.array([profile[key]['Used Grid'].replace(',', '').split()])[:, [9, 11]].astype(float)
        UsedGrid.append(test)
        date_time.append(datetime.strptime(key, "%y %m %d %H %M"))
    return UsedGrid, date_time

def PBLH(profile = profile):
    PBLH = []
    UsedGrid = []
    date_time = []
    for key in profile.keys():
        PBLH.append(profile[key]['2D Fields']['PBLH'].iloc[0])
        test = np.array([profile[key]['Used Grid'].replace(',', '').split()])[:, [9, 11]].astype(float)
        UsedGrid.append(test)
        date_time.append(datetime.strptime(key, "%y %m %d %H %M"))

    plt.figure(figsize=(10,6))
    plt.plot(date_time, PBLH, 'o-k', linewidth=2)
    plt.title(f'[{date_time[0].year},{date_time[0].month},{date_time[0].day}] PBLH: ({UsedGrid[0][0][0]}, {UsedGrid[0][0][1]})')
    plt.ylabel('Altitude (m AGL)')
    plt.xlabel('Hours (UTC)')
    return profile

PBLH = PBLH()

keys = list(profile.keys())
WSPD = np.array([profile[keys[0]]['3D Fields']['WSPD']]).astype(float)
PRES = np.array([profile[keys[0]]['3D Fields']['PRES']]).astype(float)
ALT0 = np.array([profile[keys[0]]['3D Fields']['ALT0']]).astype(float)
TPOT = np.array([profile[keys[0]]['3D Fields']['TPOT']]).astype(float)
Hr = []

for key in keys[1::]:
    press = np.array([profile[key]['3D Fields']['PRES']]).astype(float)
    wspeed = np.array([profile[keys[0]]['3D Fields']['WSPD']]).astype(float)
    alt0 = np.array([profile[keys[0]]['3D Fields']['ALT0']]).astype(float)
    tpot = np.array([profile[keys[0]]['3D Fields']['TPOT']]).astype(float)
    PRES = np.append(PRES, press, axis=0)
    WSPD = np.append(WSPD, wspeed, axis=0)
    ALT0 = np.append(ALT0, alt0, axis=0)
    TPOT = np.append(TPOT, tpot, axis=0)

date_time = []
for key in profile.keys():
    date_time = datetime.strptime(key, "%y %m %d %H %M")
    Hr.append(date_time.hour)

PRES = np.rot90(PRES)
WSPD = np.rot90(WSPD)
ALT0 = np.rot90(ALT0)
TPOT = np.rot90(TPOT)
Hr = np.array([Hr])

# Hr = np.rot90(Hr)

# plt.pcolormesh(Hr, ALT0, WSPD)
plt.pcolormesh(Hr, ALT0, WSPD, cmap='jet', shading='auto', norm=mpl.colors.LogNorm(vmin=0.1, vmax=10))
# plt.ylim(1000, 800)

#%% Find Height?
Z = []
Rd = 287
g = 9.81
Cp = 1004
PRSS = profile[keys[0]]['2D Fields']['PRSS']

for i in range(0, len(PRES[0, :])):
    z = -(Rd) / g
    z *= np.log(PRES[0, i] / PRES)
    z *= (PRES[0, i] / PRSS)**(Cp/Rd)
    z *= TPOT[0, i]


#%%
def pcolormesh(alt, r, t, title='default', shade='auto', cmin=1, cmax=15, logscale='on', cmap='jet', varname=None, ylim=None):

    fig, ax = plt.subplots(figsize=(10, 8))
    if logscale=='on':
        im = ax.pcolormesh(t, alt, r, cmap=cmap, shading=shade, norm=mpl.colors.LogNorm(vmin=cmin, vmax=cmax))
    elif logscale == 'off':
        im = ax.pcolormesh(t, alt, r, cmap=cmap, shading=shade, vmin=cmin, vmax=cmax)

    if varname=="WDir":
        cbar = fig.colorbar(im, ticks=[0, 90, 180, 270, 360])
        cbar.ax.set_yticklabels(['North', 'East', 'South', 'West', 'North'])  # horizontal colorbar
        cbar.ax.set_ylabel('Degrees')

    elif varname == 'spd':
        cbar = plt.colorbar(im, ax=ax)
        cbar.ax.set_ylabel('Velocity (m/s)')

    elif varname == 'distance':
        cbar = plt.colorbar(im, ax=ax)
        cbar.ax.set_ylabel('Distance Traveled (km)')

    else:
        cbar = plt.colorbar(im, ax=ax)

    if type(ylim) is type([]):
        ax.set_ylim(ylim)
    plt.xlabel('Hours (UTC)')
    plt.ylabel('Altitude (km AGL)')
    plt.xticks(np.arange(0, 25, 3))
    # converter = mdates.ConciseDateConverter()
    # munits.registry[datetime.datetime] = converter

    # fig.autofmt_xdate()


    if title == 'default':
        # if varname=='WDir':
        #     ax.set_title()
        ax.set_title('pcolormesh curtain')
    else:
        try: ax.set_title(title)
        except: print('Unsupported figure title')

    return

# pcolormesh(ALT0, , t)