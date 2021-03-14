# ID: 2021220942
# NAME: 류종석
# File name: read_iris_v2.py
# Platform: Python 3.9.0 on Window 10 (PyCharm)
# Required Package(s): sys numpy 

##############################################################
# Template file for homework programming assignment 1
# Modify the first 5 lines according to your implementation
# This file is just for an example. Feel free to modify it.
##############################################################

##############################################################
# NOTE: import sys and numpy only. 
# No other packages are allowed to be imported
##############################################################
import sys
import numpy as np

if len(sys.argv) < 2:
    print('usage: ' + sys.argv[0] + ' text_file_name')
else:
    ##############################################################
    # WRITE YOUR OWN CODE LINES
    # - open the input file, without pandas or csv packages
    # - read header line
    # - read data and class labels
    # - compute mean and standard deviation
    # - disply them
    ##############################################################

    # csv 파일 일때
    # arg[1]에서 마지막 3글자가 csv이면
    if sys.argv[1][-3:].lower() == 'csv':
        names = np.array(['sepal_length', 'sepal_width', 'petal_length', 'petal_width', 'species'])

        # loadtxt로 파일 읽어오기
        # dtype으로 각 데이터 타입 변경, 구분자 ',' 헤더제거거, 각필드에대해 배열 반환
        data = np.loadtxt(sys.argv[1],
                       dtype={'names': ('sepal_length', 'sepal_width', 'petal_length', 'petal_width', 'species'),
                              'formats': (np.float64, np.float64, np.float64, np.float64, '|S15')},
                       delimiter=',', skiprows=1, unpack=True)

        # sepal_length 평균, 표준편차
        S_L1 = round(np.array(data[0]).mean(), 2)
        S_L2 = round(np.array(data[0]).std(), 2)

        # sepal_width 평균, 표준편차
        S_W1 = round(np.array(data[1]).mean(), 2)
        S_W2 = round(np.array(data[1]).std(), 2)

        # petal_length 평균, 표준편차
        P_L1 = round(np.array(data[2]).mean(), 2)
        P_L2 = round(np.array(data[2]).std(), 2)

        # petal_width 평균, 표준편차
        P_W1 = round(np.array(data[3]).mean(), 2)
        P_W2 = round(np.array(data[3]).std(), 2)

        # pdf와 통일하기 위함
        print("-----------------------------------------------------------")
        print("    ",names[0],"",names[1],"",names[2],"",names[3])
        print("mean", "\t    ", S_L1, "\t", S_W1, "\t       ", P_L1, "\t    ", "%.2f"%P_W1)
        print("std", "\t    ", S_L2, "\t", S_W2, "\t       ", P_L2, "\t    ", "%.2f"%P_W2)
        print("-----------------------------------------------------------")

    else:
        names = np.array(["SL", "SW", "PL", "PW", "CLASS"])
        # loadtxt로 파일 읽어오기
        # dtype으로 각 데이터 타입 변경, 구분자 ',' 헤더제거거, 각필드에대해 배열 반환
        data = np.loadtxt(sys.argv[1],
                          dtype={'names': ("SL", "SW", "PL", "PW", "CLASS"),
                                 'formats': (np.float64, np.float64, np.float64, np.float64, "|S15")},
                          delimiter='\t', skiprows=1,unpack=True)

        # SL 평균, 표준편차
        SL1 = round(np.array(data[0]).mean(), 2)
        SL2 = round(np.array(data[0]).std(), 2)

        # SW 평균, 표준편차
        SW1 = round(np.array(data[1]).mean(), 2)
        SW2 = round(np.array(data[1]).std(), 2)

        # PL 평균, 표준편차
        PL1 = round(np.array(data[2]).mean(), 2)
        PL2 = round(np.array(data[2]).std(), 2)

        # PW 평균, 표준편차
        PW1 = round(np.array(data[3]).mean(), 2)
        PW2 = round(np.array(data[3]).std(), 2)

        # pdf와 통일하기 위함
        print("-----------------------------------------------------------")
        print("\t      ", names[0], "\t  ", names[1], "\t\t ", names[2], "\t      ", names[3])
        print("mean", "\t    ", SL1, "\t", SW1, "\t       ", PL1, "\t    ", "%.2f" % PW1)
        print("std", "\t    ", SL2, "\t", SW2, "\t       ", PL2, "\t    ", "%.2f" % PW2)
        print("-----------------------------------------------------------")


