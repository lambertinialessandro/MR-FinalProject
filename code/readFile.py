# -*- coding: utf-8 -*-
"""
Created Aug 2021

@author: Alessandro Lambertini
"""

def chk2files(f1, f2, series):
    with open(f1, "r") as f:
        f.readline() # jump first line

        InitData = {}
        lineNames = f.readline().split()
        lineData = f.readline().split()

        for k, v in zip(lineNames, lineData):
            InitData[k] = v
        print(InitData)

        lineNames1 = f.readline().split()
        lineNames1 = lineNames1[1:]

    print()

    with open(f2, "r") as f:
        f.readline() # jump first line

        InitData = {}
        lineNames = f.readline().split()
        lineData = f.readline().split()

        for k, v in zip(lineNames, lineData):
            InitData[k] = v
        print(InitData)

        lineNames2 = f.readline().split()
        lineNames2 = lineNames2[1:]
        lineNames2[0] = None

    print()
    print(lineNames1)
    print()
    print(lineNames2)
    print()

    for s in series:
        sNames = []
        sPos = []
        for i in s:
            sNames.append(lineNames1[i])
            try:
                sPos.append( (lineNames2.index(lineNames1[i]))*3 )
            except ValueError:
                sPos.append(0)

        print()

        print(s)
        print(sNames)
        print(sPos)
        print([lineNames2[int(i/3)] for i in sPos])


# USER PARAMETERS
f1 = "./.trc" # MODIFY ME
f2 = "./.trc" # MODIFY ME

series = [[5, 6, 8, 9], # torso 15, 18, 24, 27
          [10, 11, 12, 13], # pelvis 30, 33, 36, 39

          [29, 30, 31], # left knee 87, 90, 93
          [33, 34, 35], # right knee 99, 102, 105

          [36, 37, 40], # letf foot POST 108, 111, 120
          [41, 42, 43], # letf foot ANT 123, 126, 129
          [36, 41], # left foot connections 108, 123
          [37, 43], # left foot connections 111, 129

          [38, 39, 44], # right foot POST 114, 117, 132
          [45, 46, 47], # right foot ANT 135, 138, 141
          [39, 45], # right foot connections 117, 135
          [38, 47], # right foot connections 114, 141

          [29, 31, 50], # left calf 87, 93, 150
          [33, 35, 49], # right calf 99, 105, 147

          [10, 28, 30], # left quad 30, 84, 90
          [13, 32, 34], # right quad 39, 96, 102

          [10, 11, 29], # left amstring 30, 33, 87
          [12, 13, 33], # right amstring 36, 39, 99
          ]

chk2files(f1, f2, series)


