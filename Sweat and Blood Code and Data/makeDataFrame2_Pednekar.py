# Makes a dataframe where each given combination of participant and video an will have their own dataframe that includes
# ECG and EDA data
import pandas as pd
import numpy as np
import xlrd
import re

# Global Constants and Dictionaries
MOVIE_NAME_DICT = {'Entourage': 1, 'Fault': 2, 'Get Hard': 3, 'Victoria': 4}
PLATFORM_DICT = {'TV': 1, 'Mobile': 2}

# Create dataframe: Person, Platform, Movie, RR, EDA
dataframe_columns = ['Person', 'Platform', 'Movie', 'RR', 'EDA']




def createDataframes():
    data = pd.DataFrame(columns=['Participant', 'Advertisement', 'Platform', 'RR', 'ECG', 'EEG-engagement', 'EEG- workload', 'EEG-distraction'])
    print data
    return data


def getRRbaseline(filename):
    # Returns an array of ECG baseline from RR-Baseline.csv
    baseline_array = pd.read_csv("./RR/"+filename+".csv")
    mean_array = baseline_array.mean()
    return mean_array

def readRRdata(filename):
    # Returns an array of RR data with each participant as columns
    # Already at 1Hz
    RR_array = pd.read_csv("./RR/"+filename+".csv")
    return RR_array

def readEDAdata(filename):
    xls = pd.ExcelFile("./EDA/"+filename+".xlsx")
    sheet_names = xls.sheet_names
    return sheet_names

def getEDAbaseline(filename):
    baseline_array = pd.read_csv("./EDA/"+filename+".csv")
    baseline_array.replace(r'\s+', np.nan, regex=True) # Make blank cells NaN
    mean_array = baseline_array.mean()
    return mean_array

def getEDAdata(filename):
    # Returns an array of RR data with each participant as columns
    # Downsample from 256Hz to 1Hz
    RR_array = pd.read_csv("./EDA/" + filename + ".csv")
    downsampled = RR_array.ix[1::256]
    return downsampled

def getData(movie_name, platform):
    """Returns array for EDA and RR for a given movie and platform"""
    EDA_name = 'EDA-' + movie_name + '-' + platform
    RR_name = 'RR-' + movie_name + '-' + platform
    print EDA_name
    print RR_name
    EDA_data = getEDAdata(EDA_name)
    RR_data = readRRdata(RR_name)
    return EDA_data, RR_data

def populateDataframe(df,movie_name, platform):
    """Append new data with correct numbering"""
    EDA_data, RR_data = getData(movie_name, platform)
    #  Dataframe: Person, Platform, Movie, RR, EDA

    # Get min index
    min_index = min(EDA_data.shape[0], RR_data.shape[0]) # Find smaller data
    num_participant = 74
    column_names = list(EDA_data)[:num_participant]
    index_name_EDA = list(EDA_data.index)
    index_name_RR = list(RR_data.index)

    # print column
    # Continuously append data from one participant and one index

    # Loop through Participants
    print column_names
    for col in column_names:
        print col
        # Loop through index
        for i in range(min_index):
            index_EDA = index_name_EDA[i]
            index_RR = index_name_RR[i]
            RR_col = RR_data[col][index_RR]
            df2 = pd.DataFrame([[int(col[-3:]), # Column to participant number
                                PLATFORM_DICT[platform],
                                MOVIE_NAME_DICT[movie_name],
                                RR_col,
                                EDA_data[col][index_EDA]]],
                                columns = dataframe_columns)
            df = df.append(df2)
    return df


def main():
    # File Naming Convention: <Datatype>-<Movie Name>-<Platform>

    # Get Baseline First

    # Create dataframe: Person, Platform, Movie, RR, EDA
    df = pd.DataFrame(columns=dataframe_columns)

    # For each combination of movie and platform
    for movie in MOVIE_NAME_DICT:
        for platform in PLATFORM_DICT:
            # populateDataframe(df,movie,platform)
            df = populateDataframe(df, movie, platform)

    df.to_csv('finalDataFrame.csv')




if __name__ == "__main__":
    main()