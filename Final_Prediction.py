import tensorflow as tf
import pandas as pd
import numpy as np
import RHX_Network
import RHX_Transformation
import RHX_Input
import time
import os

tf.reset_default_graph() #This will ensure that the variables get the names you intended, but it will invalidate previously-created graphs

###--------------------------------------------------------------###
'''            --     Part 1: Loading  images    --              '''

My_Data = RHX_Input.LoadImage(directory='../Step1_DataPreparation/D2_CSV_data',Filename='prediction',LabelSize=1) # Get location
My_Data.RandomLoad()  # Load data

InputSize  = My_Data.InputSize  # Get InputSize

###---------------------------------------------------------------###


###---------------------------------------------------------------###
'''            --     Part 2: define  placeholder    --           '''

with tf.name_scope('inputs'):
    xs          = tf.placeholder(tf.float32, [None,InputSize*InputSize],   name = 'x_input')
    
    keep_prob   = tf.placeholder(tf.float32, name ='Dropout')
    tst         = tf.placeholder(tf.bool)    # test flag for batch norm
    iter        = tf.placeholder(tf.int32)
    is_training = tf.placeholder(tf.float32, name='is_training')

###-- -------------------------------------------------- --###



###---------------------------------------------------------------###
'''     --     Part 3:  get prediction from network    --         '''


x_image = tf.cast(tf.reshape(xs, [-1,InputSize,InputSize,1]), tf.float32)

batchsize = tf.shape(x_image)[0]

prediction = RHX_Network.inference(x_image,InputSize,batchsize)


# ###-- ---------------------------------------- --###
# ###-- Part 4: load parameters from nets: start --###

sess   = tf.Session()


saver = tf.train.Saver()
saver.restore(sess,"my_net/save_net.ckpt")


###-- Part 4: load parameters from nets: start  --###
###-- -------------------------------------- --###


print "Done!"







time0=time.time()
####################################################
####################################################

# Combine Prediction and Input
x_data_test, y_data_test = My_Data.Batch_Prediction(-1)


Predict_data = np.array(sess.run([prediction], feed_dict={xs: x_data_test,  keep_prob: 1,is_training: 1,tst: False,iter: 1}))

Output = Predict_data.reshape(Predict_data.shape[1],Predict_data.shape[2]*Predict_data.shape[3])



if os.path.exists('../Step3_Performance/Result') is False:
    os.mkdir('../Step3_Performance/Result')

# Write it into csv
import scipy.io as scio
scio.savemat('../Step3_Performance/Result/prediction.mat', {'Data_whole':Output,'Data_whole_image':x_data_test})


print 'prediction.csv has been writen! time is:' + str(time.time()-time0) +'s'


####################################################
####################################################




