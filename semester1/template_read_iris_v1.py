# ID: ELEC946
# NAME: Intelligent System Design
# File name: template_read_iris_v1.py
# Platform: Python 3.5.2 on Ubuntu Linux 16.04
# Required Package(s): sys numpy pandas

##############################################################
# Template file for homework programming assignment 1
# Modify the first 5 lines according to your implementation
# This file is just for an example. Feel free to modify it.
##############################################################

import sys
import numpy as np
import pandas as pd

if len(sys.argv) < 2:
    print('usage: ' + sys.argv[0] + ' text_file_name')
else:
    # determine delimieter based on file extension - may be used by pandas
    # this is just to show how to use command line arguments. 
    # any modification is accepted depending on your implementation.
    if sys.argv[1][-3:].lower() == 'csv': delimeter = ','
    else: delimeter = '[ \t\n\r]'  # default is all white spaces 

    # read CSV/Text file with pandas
    f = pd.read_csv(sys.argv[1],sep=delimeter,engine='python')

    ##############################################################
    # WRITE YOUR OWN CODE LINES
    # - read header line
    # - read data and class labels
    # - compute mean and standard deviation
    # - disply them 
    ##############################################################
