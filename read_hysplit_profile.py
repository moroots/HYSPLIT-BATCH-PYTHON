# -*- coding: utf-8 -*-
"""
Created on Sat Oct 24 23:55:04 2020

@author: Magnolia

GET HYSPLIT Profile

"""

import numpy as np
import pandas as pd
import pickle

def import_profile(filepath):
    with open(filepath) as f:
        profile={}; x = 0
        # profile_save={}
        count = 0
        for line_1 in f:
            # print(line_1)
            count += 1
            # print(count)
            if count == 1:
                name = line_1
                # print(name)

            if count == 2:
                start = line_1.split(': ')[-1]
                # print(start)

            if count == 3:
                stop = line_1.split(': ')[-1]
                # print(stop)

            # if count==6: print(line.split(':')[0])
            if line_1.split(':')[0] == ' Profile Time':
                prf_ID=line_1.split(':  ')[-1].split('\n')[0]
                l = 0; x += 1
                # print(f'Profile Number {x}')
                for line_2 in f:
                    # print(line_2)
                    l += 1
                    # print(line)
                    if l == 1:
                        Near_Grid = line_2
                        # print(line)
                    if l == 3:
                        # print(line)
                        # Fields_2D = {}
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
                # profile_save[prf_ID] = {'Used Grid': Near_Grid,
                #                    '2D Fields': Fields_2D.to_dict(),
                #                    '2D Units': units_2D,
                #                    '3D Fields': Fields_3D.to_dict(),
                #                    '3D Units': units_3D}

    # SAVE THE FILE !!!
    # with open(f"{filepath.replace('.txt', '.json')}", 'w') as savefile:
    #     json.dump(profile_save, savefile, indent=4, sort_keys=True)

    with open(f"{filepath.replace('.txt', '.pkl')}", 'wb') as savefile:
        pickle.dump(profile, savefile)

    return profile
#%% RUN IT
filepath=r'C:\Users\Magnolia\OneDrive - UMBC\Research\Summer 2020\NERTO\Code\Python\Projects\profile.HMI_WRFd03_20180701.txt'
profile = import_profile(filepath)

#%% Pull Pkl
def grab_pkl(filename):
    with open(filename, 'rb') as f:
        profile = pickle.load(f)
    return profile

filepath=r'C:\Users\Magnolia\OneDrive - UMBC\Research\Summer 2020\NERTO\Code\Python\Projects\profile.HMI_WRFd03_20180701.pkl'
profile = grab_pkl(filepath)
