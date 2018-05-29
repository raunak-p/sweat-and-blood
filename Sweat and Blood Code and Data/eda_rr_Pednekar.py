import pandas as pd
import numpy as np


#reads in main dataframe
def get_main_dataframe(final_data):
    data = pd.read_csv(final_data)
    return data


#creates a csv file of mean values by 1 factor grouping. Dataframe is the main dataframe
def make_grouped_csv_one_factor(dataframe, factor, name):
    factor_grouped_data = dataframe.groupby([factor]).mean()
    factor_grouped_data.to_csv(name)

#creates a csv file of mean values by 2 factor grouping. Dataframe is the main dataframe
def make_grouped_csv_two_factor(dataframe,factor1, factor2, name):
   2factor_grouped_data = dataframe.groupby([factor1, factor2]).mean()
   2factor_grouped_data.to_csv(name)



# reads in EDA datafile needed
def getEDAdata(filename):
    # Returns an array of RR data with each participant as columns
    # Downsample from 256Hz to 1Hz
    RR_array = pd.read_csv("./EDA/" + filename + ".csv")
    downsampled = RR_array.ix[1::256]
    return downsampled

#splits EDA into tonic and phasic components for one participant. Returns tonic.
##Does this by creating a moving average of memory +- (n-1)/2.
def make_tonic_EDA(EDA_total, n = 9):
    if n%2 == 0:
        print "Pick an even number for n"

    else:
        EDA_tonic_1 = EDA_total["FB001"].as_matrix()
        EDA_tonic_1 = np.cumsum(EDA_tonic_1) #cumsum is cumuluative sum
        EDA_tonic_1[n:] = EDA_tonic_1[n:] - EDA_tonic_1[:-n]
        EDA_tonic_1 = EDA_tonic_1[n - 1:] / n
        EDA_tonic = np.zeros(EDA_tonic_1.shape[0] + n-1)
        EDA_tonic[ :(n-1)/2]  = EDA_tonic_1[0]
        EDA_tonic[((n - 1) / 2): -((n-1)/2)] = EDA_tonic_1
        EDA_tonic[-((n - 1) / 2):] = EDA_tonic_1[-1]

    return EDA_tonic


#returns phasic component of EDA
def make_phasic_EDA(EDA_total, EDA_tonic):
    EDA_phasic = EDA_total - EDA_tonic
    return EDA_phasic


#reads in RR file
def readRRdata(filename):
    # Returns an array of RR data with each participant as columns
    # Already at 1Hz
    RR_array = pd.read_csv("./RR/" + filename + ".csv")
    return RR_array

#calcuates heart rate variability(rmssd measure) of every
def hrv_calculator(rr):
    rr_diff = rr.diff()
    rr_diff_sqr = np.square(rr_diff)
    hrv_squared = rr_diff_sqr.mean()
    hrv = np.sqrt(hrv_squared)
    rmssd = hrv * 1000
    return rmssd


#
def cluster_anova(cluster_list, hrv):
    cluster_1 = []
    cluster_2 = []
    cluster_3 = []
    for i in range(len(cluster_list)):
        cluster = cluster_list[i]
        if cluster == 1:
            cluster_1.append(hrv[i])
        if cluster == 2:
            cluster_2.append(hrv[i])
        if cluster == 3:
            cluster_3.append(hrv[i])
    return cluster_1, cluster_2, cluster_3

def main():
    # main_data = get_main_dataframe("finalDataframe.csv")



    clusters = [2, 3, 2, 1, 1, 2, 1, 1, 1, 2, 2, 1, 1, 2, 1, 2, 1, 1, 2, 1, 1, 3, 3, 2, 3, 2, 3, 3, 1, 2, 3, 3, 1, 1, 2,
                2, 2, 2, 2, 1, 2, 2, 1, 1, 1, 2, 1, 1, 1, 1, 3, 3, 1, 1, 1, 2, 3, 1, 2, 1, 3, 1, 1, 1, 2, 1, 1, 1, 3, 1,
                3, 2, 2, ]





##Not working basline correction code

# def eda_baseline_correction(dataframe, eda_baseline):
#     dataframe["eda_corr"] = np.zeros((dataframe.shape[0]))
#     # print dataframe
#     p = 0
#     for i in range(dataframe.shape[0]):
#         baseline_index = dataframe["Person"][i].astype(int)
#         # print  baseline_index, type(baseline_index), "AHDSAHDAH"
#         dataframe["eda_corr"][i] = dataframe["EDA"][i] - eda_baseline[baseline_index]
#         p+= 1
#         if p % 20 == 0:
#             print "On the %d row..." % p
#     return dataframe


if __name__ == "__main__":
    main()