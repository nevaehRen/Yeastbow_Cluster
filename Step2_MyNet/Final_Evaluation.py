import tensorflow as tf
import pandas as pd
import numpy as np
import RHX_Network
import RHX_Transformation
import RHX_Input
import os
import shutil
import time


tf.reset_default_graph() #This will ensure that the variables get the names you intended, but it will invalidate previously-created graphs

###--------------------------------------------------------------###
'''            --     Part 1: Loading  images    --              '''

My_Data = RHX_Input.LoadImage(directory='../Step1_DataPreparation/D2_CSV_data',Filename='Evaluation',LabelSize=256**2) # Get location
My_Data.RandomLoad()  # Load data

InputSize  = My_Data.InputSize  # Get InputSize
OutputSize = My_Data.OutputSize # Get OutputSize

###---------------------------------------------------------------###


###---------------------------------------------------------------###
'''            --     Part 2: define  placeholder    --           '''

with tf.name_scope('inputs'):
    xs          = tf.placeholder(tf.float32, [None,InputSize*InputSize],   name = 'x_input')
    ys          = tf.placeholder(tf.float32, [None,OutputSize*OutputSize], name = 'y_input')
    
    keep_prob   = tf.placeholder(tf.float32, name ='Dropout')
    
    tst         = tf.placeholder(tf.bool)    # test flag for batch norm
    iter        = tf.placeholder(tf.int32)
    
    is_training = tf.placeholder(tf.float32, name='is_training')

###-- -------------------------------------------------- --###



###---------------------------------------------------------------###
'''     --     Part 3:  get prediction from network    --         '''


x_image = tf.cast(tf.reshape(xs, [-1,InputSize,InputSize,1]), tf.float32)


prediction = RHX_Network.inference(x_image,InputSize,tf.shape(x_image)[0])

sess   = tf.Session()

# ###-- ---------------------------------------- --###
# ###-- Part 4: load parameters from nets: start --###


if os.path.exists('../Step3_Performance/Evaluation') is False:
    os.mkdir('../Step3_Performance/Evaluation')
else:
    os.system('rm -fr ../Step3_Performance/Evaluation')

    os.mkdir('../Step3_Performance/Evaluation')


if os.path.exists('../Step3_Performance/Evaluation/CSV') is False:
    os.mkdir('../Step3_Performance/Evaluation/CSV')


for Document in os.listdir('./'):
    if Document[0:6]=='my_net':
        path_parameter = Document
        saver = tf.train.Saver()
        saver.restore(sess,path_parameter+'/save_net.ckpt')
        
        
        ###-- Part 4: load parameters from nets: start  --###
        ###-- -------------------------------------- --###
        
        
        print path_parameter+" Loading Done!"
        
        
        time0=time.time()
        ####################################################
        ####################################################
        
        # Combine Prediction and Input
        x_data_test, y_data_test = My_Data.Batch_Prediction(-1)
        Predict_data = np.array(sess.run([prediction], feed_dict={xs: x_data_test,  keep_prob: 1,is_training: 1,tst: False,iter: 1}))
        Output = Predict_data.reshape(Predict_data.shape[1],Predict_data.shape[2]*Predict_data.shape[3])
        Truth  = y_data_test

    
        print 'Image number: ',Output.shape
        print 'Truth number: ',Output.shape
        
        
        # Write it into csv
        import scipy.io as scio
        scio.savemat('../Step3_Performance/Evaluation/CSV/Evaluation_'+path_parameter+'.mat', {'Prediction_whole':Output,'Image_whole':x_data_test,'Truth_whole':y_data_test})


        print "Result has been writen into csv files ! time is:"+str(time.time()-time0)


####################################################
####################################################


