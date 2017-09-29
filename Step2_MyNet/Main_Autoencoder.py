from matplotlib import pyplot as plt
import tensorflow as tf
import numpy as np
import pandas as pd
import time
import RHX_Input
import RHX_Network
import RHX_Transformation



import os
if os.path.exists('my_net/') is False:
    os.makedirs('my_net/')


if os.path.exists('my_net_best/') is False:
    os.makedirs('my_net_best/')



###--------------------------------------------------------------###
'''            --     Part 1: Loading  images    --              '''

My_Data = RHX_Input.LoadImage(directory='../Step1_DataPreparation/D2_CSV_data',Filename='Yeastbow2',LabelSize=256**2) # Get location
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

IMAGE_x_SIZE = InputSize
IMAGE_y_SIZE = OutputSize

#x_image,y_image = RHX_Transformation.inputs(xs,ys,InputSize,OutputSize,IMAGE_x_SIZE,IMAGE_y_SIZE)
x_image,y_image = RHX_Transformation.distorted_inputs(xs,ys,InputSize,OutputSize,IMAGE_x_SIZE,IMAGE_y_SIZE)


prediction = RHX_Network.inference(x_image,IMAGE_x_SIZE,tf.shape(x_image)[0])


###-- ---------------------------------------- --###
###-- Part 4: Define Cost and accuracy : start --###

with tf.name_scope('loss'):
    prediction = tf.reshape(prediction, [IMAGE_x_SIZE,IMAGE_x_SIZE])
    x_image    = tf.reshape(x_image,    [IMAGE_x_SIZE,IMAGE_x_SIZE])
    y_image    = tf.reshape(y_image,    [IMAGE_y_SIZE,IMAGE_y_SIZE])

#    loss    =  tf.reduce_mean(tf.pow(x_image - prediction, 2))*1e6
    loss    =  tf.reduce_sum( tf.pow(y_image - prediction, 2) )/tf.reduce_sum(y_image)*1e3

    tf.scalar_summary('loss',loss)

with tf.name_scope('train'):
#    train_step  = tf.train.GradientDescentOptimizer(1e-3).minimize(loss)
#         train_step  = tf.train.MomentumOptimizer(0.1,0.1).minimize(loss)
    train_step  = tf.train.AdamOptimizer(1e-5).minimize(loss)
#    train_step  = tf.train.AdagradOptimizer(1e-3).minimize(loss)
#     train_step  = tf.train.RMSPropOptimizer(0.1).minimize(loss)

with tf.name_scope('Train_accuracy'):
    accuracy = 1-loss
    tf.scalar_summary('accuracy',accuracy)


init   = tf.initialize_all_variables()
sess   = tf.Session()


### initstate = 0 means use history parameters number
### initstate = 1 means random initialization

initstate  = 0

if initstate is 1:
    sess.run(init)
else:
    saver = tf.train.Saver()
    saver.restore(sess,"my_net/save_net.ckpt")


merge  = tf.merge_all_summaries()
train_writer = tf.train.SummaryWriter("logs/CNN_train",sess.graph)
test_writer  = tf.train.SummaryWriter("logs/CNN_test")

###-- Part 4: Define Cost and accuracy : end --###
###-- -------------------------------------- --###



###-- -------------------------------------- --###
###--      Part 5: Moniter Gif : start       --###


def Collection(Predict_data,X_flip,Output):
    Temp   = pd.DataFrame(np.concatenate([Predict_data.reshape([-1]),X_flip.reshape([-1])])).T
    Output = pd.concat([Output,Temp])
    return Output

# predict same picture
x_temp, y_temp = My_Data.Batch_test(1)  #load training data

# init Output
Output = pd.DataFrame(np.concatenate([y_temp.reshape([-1]),x_temp.reshape([-1])])).T



###--      Part 5: Moniter Gif : End         --###
###-- -------------------------------------- --###



###-- ------------------------ --###
###-- Part 6: Training : start --###

BN=1
Best_Socre=1e5

for i in range(1000000):
    x_data, y_data = My_Data.Batch_train(1)  #load training data
    
    sess.run(train_step,feed_dict={xs:x_data,ys:y_data, keep_prob: 1,is_training: BN,tst: True,iter: i})
    
    ###-- Print and check every 10 epohs, if accuracy decrese more than 30%, then stop --###
    if i%10000==0:
        My_Data.RandomLoad()  # Load data

    if i%400==0:
        # predict same picture
        Predict_data,X_flip,Y_flip = sess.run([prediction,x_image,y_image], feed_dict={xs: x_temp, ys: y_temp, keep_prob: 1,is_training: 1,tst: False,iter: 1})
        Output = Collection(Predict_data,X_flip,Output)

    if i%10000==0:
        Output.T.to_csv('process'+str(i)+'.csv',index=None)
        Output = pd.DataFrame(np.concatenate([y_temp.reshape([-1]),x_temp.reshape([-1])])).T
        Output = pd.DataFrame(Output.values[-1,:]).T

    if i%100==0:
        x_data_test, y_data_test = My_Data.Batch_test(1)
        Temp_Accuracy1 = sess.run(loss, feed_dict={xs: x_data_test, ys: y_data_test, keep_prob: 1,is_training: BN,tst: False,iter: i});
        x_data_test, y_data_test = My_Data.Batch_test(1)
        Temp_Accuracy2 = sess.run(loss, feed_dict={xs: x_data_test, ys: y_data_test, keep_prob: 1,is_training: BN,tst: False,iter: i});
        x_data_test, y_data_test = My_Data.Batch_test(1)
        Temp_Accuracy3 = sess.run(loss, feed_dict={xs: x_data_test, ys: y_data_test, keep_prob: 1,is_training: BN,tst: False,iter: i});
        x_data_test, y_data_test = My_Data.Batch_test(1)
        Temp_Accuracy4 = sess.run(loss, feed_dict={xs: x_data_test, ys: y_data_test, keep_prob: 1,is_training: BN,tst: False,iter: i});
        x_data_test, y_data_test = My_Data.Batch_test(1)
        Temp_Accuracy5 = sess.run(loss, feed_dict={xs: x_data_test, ys: y_data_test, keep_prob: 1,is_training: BN,tst: False,iter: i});

        Temp_Accuracy = 0.2*(Temp_Accuracy1+Temp_Accuracy2+Temp_Accuracy3+Temp_Accuracy4+Temp_Accuracy5)


        with open("result.txt","a") as f:
            f.write('Prediction loss:  ' + str(Temp_Accuracy)+'\n')
        print 'Prediction loss:  ' + str(Temp_Accuracy)
        print 'Training loss:  ' + str(sess.run(loss, feed_dict={xs: x_data, ys: y_data, keep_prob: 1,is_training: 0,tst: False,iter: i}))
        print '---------------------------------'
        

        if (np.isnan(Temp_Accuracy)):
            saver = tf.train.Saver()
            saver.restore(sess,"my_net/save_net.ckpt")
            with open("result.txt","a") as f:
                f.write("Restore .../n")
            print "Restore"
#            break
        summary= sess.run(merge, feed_dict={xs: x_data_test, ys: y_data_test,keep_prob: 1,is_training: BN,tst: True,iter: i})
        test_writer.add_summary(summary, i)
                
        result = sess.run(merge, feed_dict={xs:x_data,ys:y_data,keep_prob: 1,is_training: BN,tst: True,iter: i})
        train_writer.add_summary(result,i )
        
        
        
        ###-- Save parameters every 100 epohs  --###
        if i%500==0:
            if (Temp_Accuracy<Best_Socre):
                Best_Socre = Temp_Accuracy
                with open("result_best.txt","a") as f:
                    f.write('Prediction loss:  ' + str(Best_Socre)+'\n')
                    f.write( "Saving .../n")
                print "Saving..."
                
                saver = tf.train.Saver()
                save_path = saver.save(sess,"my_net_best/save_net.ckpt")
                
                with open("result_best.txt","a") as f:
                    f.write("Done!/n")
            else:
                with open("result.txt","a") as f:
                    f.write( "Saving .../n")
                print "Saving..."
                        
                saver = tf.train.Saver()
                save_path = saver.save(sess,"my_net/save_net.ckpt")
                        
                with open("result.txt","a") as f:
                    f.write("Done!/n")

print "Done!"

