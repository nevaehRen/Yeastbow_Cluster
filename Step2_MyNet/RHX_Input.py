###-- --------------------------------------------- --###
###-- Part 0: scan_files()   Start --###
import pandas as pd
import numpy as np
import os
import time


def scan_files(directory,prefix=None,postfix=None):
    '''This is used to read image from csv file. Attention: csv file should obey this: Label-Image (first column is label!!!)
        
        Input:
        prefix: "mnist_train"
        
        Output:
        files_list: ["mnist_train1.csv" mnist_train2.csv] '''
    
    files_list=[]
    for root, sub_dirs, files in os.walk(directory):
        for special_file in files:
            if postfix:
                if special_file.endswith(postfix):
                    files_list.append(os.path.join(root,special_file))
            elif prefix:
                if special_file.startswith(prefix):
                    files_list.append(os.path.join(root,special_file))
            else:
                files_list.append(os.path.join(root,special_file))
    return files_list

###-- Part 0: scan_files()   End --###
###-- --------------------------------------------- --###


###-- --------------------------------------------- --###
###-- Part 1: Define Loading Image Function   Start --###


class LoadImage():
    '''This is used to read image from csv file. Attention: csv file should obey this: Label-Image (first column is label!!!)
        
        Input:
        Filename: Filename_train.csv  and  Filename_test.csv  will be loaded automatically
        OneHot  : label coding method
        
        Output:
        InputSize : s.a. InputSize*InputSize
        OutputSize: s.a. 10      1
        x_data,y_data: traing and testing data'''
    
    def __init__(self, directory, Filename, BatchSize=1, LabelSize=1):
        self.BatchSize   = BatchSize
        self.Filename    = Filename
        self.LabelSize   = LabelSize
        self.files_train = scan_files(directory,self.Filename+'_train')
        self.files_test  = scan_files(directory,self.Filename+'_test')
    
    def RandomLoad(self):
        ''' Random load 1 train.csv and 1 test.csv, and normalize images and labels to [0,1 ]'''
        
        print "Loading ... "
        time0=time.time()
        if len(self.files_train)>1:
            self.Images_train = pd.read_csv(self.files_train[np.random.randint(0,len(self.files_train))]).T
            self.Images_test  = pd.read_csv(self.files_test [np.random.randint(0,len(self.files_test ))]).T
        else:
            self.Images_train = pd.read_csv(self.files_train[0]).T
            self.Images_test  = pd.read_csv(self.files_test[0]).T
        
        print "Loading done! time: ", time.time()-time0
        
        self.InputSize    = np.int32(np.sqrt(self.Images_train.shape[1]-self.LabelSize))
        self.OutputSize   = np.int32(np.sqrt(self.LabelSize))
        self.Frames       = np.int32(self.Images_train.shape[0])
        
        ## normalization images and labels
        self.Labels_test  = self.Images_test.values[:,0:self.LabelSize]
        self.Labels_train = self.Images_train.values[:,0:self.LabelSize]
        self.Images_test  = self.Images_test.values[:,self.LabelSize:]
        self.Images_train = self.Images_train.values[:,self.LabelSize:]

    def Batch_train(self, BatchSize=100):
        ''' Function used to get training batch '''

        self.BatchSize  = BatchSize
        self.Batch_Index = np.random.randint(0,self.Images_train.shape[0],size=self.BatchSize)
        x_data = self.Images_train[self.Batch_Index,:]
        y_data = self.Labels_train[self.Batch_Index,:]
        return x_data,y_data
        
    def Batch_test(self, BatchSize=100):
        ''' Function used to get testing batch '''

        self.BatchSize  = BatchSize
        self.Batch_Index = np.random.randint(0,self.Images_test.shape[0],size=self.BatchSize)
        x_data = self.Images_test[self.Batch_Index,:]
        y_data = self.Labels_test[self.Batch_Index,:]
        return x_data,y_data
    
    def  Batch_Prediction(self,index):
        ''' Function used to get all prediction data'''
        if index<0:
            x_data = self.Images_train
            y_data = self.Labels_train
        else:
            x_data = self.Images_train[[index],:]
            y_data = self.Labels_train[[index],:]
        return x_data,y_data





###-- Part 1: Define Loading Image Function   End --###
###-- ------------------------------------------- --###



