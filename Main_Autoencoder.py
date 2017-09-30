
'''    Yeastbow Network            '''
'''    -----------         RHX     '''
'''    -----------  2017.10.01     '''

from matplotlib import pyplot as plt
import tensorflow as tf
import numpy as np
import pandas as pd
import time
import RHX_Input
import RHX_Network
import RHX_Transformation
import scipy.io as scio
import os


if os.path.exists('my_net/') is False:
    os.makedirs('my_net/')


if os.path.exists('my_net_best/') is False:
    os.makedirs('my_net_best/')


###--------------------------------------------------------------###
'''            --     Part 1: Loading  images    --              '''

My_Data = RHX_Input.LoadImage(directory='Data/',Filename='Yeastbow2',LabelSize=256**2) # Get location
My_Data.RandomLoad()  # Load data

Patch_Size  = My_Data.InputSize  # Get Patch_Size

###---------------------------------------------------------------###



###---------------------------------------------------------------###
'''            --     Part 2: define  placeholder    --           '''

with tf.name_scope('Inputs'):
    xs          = tf.placeholder(tf.float32, [None,Patch_Size*Patch_Size], name = 'x_input')
    ys          = tf.placeholder(tf.float32, [None,Patch_Size*Patch_Size], name = 'y_input')

    x_image = tf.cast(tf.reshape(xs, [-1,Patch_Size,Patch_Size,1]), tf.float32)
    y_image = tf.cast(tf.reshape(ys, [-1,Patch_Size,Patch_Size,1]), tf.float32)

###-- -------------------------------------------------- --###



###---------------------------------------------------------------###
'''     --     Part 3:  get prediction from network    --         '''

x_image,y_image = RHX_Transformation.distorted_inputs(x_image,y_image)

prediction = RHX_Network.inference(x_image)

###-- -------------------------------------------------- --###



###-- ---------------------------------------- --###
'''     --      Part 4: Define Cost and accuracy     --    '''

with tf.name_scope('loss'):
    prediction = tf.reshape(prediction, [-1])
    x_image    = tf.reshape(x_image,    [-1])
    y_image    = tf.reshape(y_image,    [-1])

#    loss    =  tf.reduce_mean(tf.pow(x_image - prediction, 2))*1e6
    loss    =  tf.reduce_sum( tf.pow(y_image - prediction, 2) )/tf.reduce_sum(y_image)*1e3

    tf.scalar_summary('loss',loss)

with tf.name_scope('train'):
#    train_step  = tf.train.GradientDescentOptimizer(1e-3).minimize(loss)
#    train_step  = tf.train.MomentumOptimizer(0.1,0.1).minimize(loss)
    train_step  = tf.train.AdamOptimizer(1e-5).minimize(loss)
#    train_step  = tf.train.AdagradOptimizer(1e-3).minimize(loss)
#     train_step  = tf.train.RMSPropOptimizer(0.1).minimize(loss)

###-- -------------------------------------- --###


###-- ---------------------------------------- --###
'''     --      Part 5: Initialization    --    '''

init   = tf.initialize_all_variables()
sess   = tf.Session()


### initstate = 0 means use history parameters number
### initstate = 1 means random initialization

initstate  = 1

if initstate is 1:
    sess.run(init)
else:
    saver = tf.train.Saver()
    saver.restore(sess,"my_net/save_net.ckpt")


merge  = tf.merge_all_summaries()
train_writer = tf.train.SummaryWriter("logs/CNN_train",sess.graph)
test_writer  = tf.train.SummaryWriter("logs/CNN_test")

###-- -------------------------------------- --###




###-- -------------------------------------- --###
''' --           Part 6: Moniter Gif        -- '''

def Collection(Predict_data,Output):
    Output = pd.concat([Output.T,pd.DataFrame(Predict_data.reshape([-1])).T]).T
    return Output

# predict same picture
x_Gif, y_Gif = My_Data.Batch_test(1)  #load training data

# init Output
Output = pd.DataFrame([])

###-- -------------------------------------- --###



###-- -------------------------------------- --###
''' --           Part 7: Training         -- '''

Best_Socre=1e5

for i in range(100000):
    x_data, y_data = My_Data.Batch_train(1)  #load training data
    
    sess.run(train_step,feed_dict={xs:x_data,ys:y_data})
    
    ###-- Print and check every 10 epohs, if accuracy decrese more than 30%, then stop --###
    if (i+1)%10000==0:
        My_Data.RandomLoad()  # Load data

    if i%100==0:
        # predict same picture
        y_Gif_prediction = sess.run(prediction, feed_dict={xs: x_Gif, ys: y_Gif })
        Output = Collection(y_Gif_prediction, Output)
    
    if (i+1)%5000==0:
        scio.savemat('process'+str(i)+'.mat', {'Prediction':Output.values,'Image':[x_Gif],'PatchSize':[Patch_Size]})
        Output = pd.DataFrame(y_Gif_prediction.reshape([-1]))

    if i%100==0:
        x_data_test, y_data_test = My_Data.Batch_test(1)
        Temp_Accuracy = sess.run(loss, feed_dict={xs: x_data_test, ys: y_data_test});

        with open("result.txt","a") as f:
            f.write('Prediction loss:  ' + str(Temp_Accuracy)+'\n')
        print str(i) + 'th Prediction loss:  ' + str(Temp_Accuracy)
        print 'Training loss:  '   + str(sess.run(loss, feed_dict={xs: x_data, ys: y_data}))
        print '---------------------------------'
        
        # check if traing is valid, if it's failed, will reload parameters from best.
        if (np.isnan(Temp_Accuracy)):
            saver = tf.train.Saver()
            saver.restore(sess,"my_net_best/save_net.ckpt")
            with open("result.txt","a") as f:
                f.write("Restore .../n")
            print "Restore"

        summary= sess.run(merge, feed_dict={xs: x_data_test, ys: y_data_test})
        test_writer.add_summary(summary, i)
                
        result = sess.run(merge, feed_dict={xs:x_data,       ys:y_data})
        train_writer.add_summary(result, i)
        
        
        
        ###-- Save parameters every 500 epohs  --###
        if i%500==0:
            if (Temp_Accuracy<Best_Socre):
                Best_Socre = Temp_Accuracy
                with open("result_best.txt","a") as f:
                    f.write('Prediction loss:  ' + str(Best_Socre)+'\n')
                print "Saving..."
                
                saver = tf.train.Saver()
                save_path = saver.save(sess,"my_net_best/save_net.ckpt")
                
            else:
                print "Saving..."
                        
                saver = tf.train.Saver()
                save_path = saver.save(sess,"my_net/save_net.ckpt")


print "Done!"

