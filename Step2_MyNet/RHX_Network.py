import tensorflow as tf
import numpy as np
from matplotlib import pyplot as plt
import RHX_Input



###-- -------------------------------- --###
###-- Part 1: Define Variables   Start --###

def weight_variable(shape):
    initial = tf.truncated_normal(shape, stddev=0.1)
    return tf.Variable(initial)

def bias_variable(shape):
    initial = tf.constant(0.1,shape=shape)
    return tf.Variable(initial)

def conv2d(x,W):
    # stride [1, x_movement, y_movement, 1]
    # 'SAME' same as orign pic
    return tf.nn.conv2d(x, W, strides=[1, 2, 2, 1], padding='SAME')

def deconv2d(x,W,output_shape):
    # stride [1, x_movement, y_movement, 1]
    # 'SAME' same as orign pic
    return tf.nn.conv2d_transpose(x, W, output_shape, strides=[1, 2, 2, 1], padding='SAME')

def max_pool_2x2(x,name):
    # stride [1, x_movement, y_movement, 1]
    return tf.nn.max_pool(x, ksize=[1,3,3,1], strides=[1,1,1,1], padding='SAME',name = name)




def batchnorm(Ylogits, is_test, iteration, offset, convolutional=False):
    exp_moving_avg = tf.train.ExponentialMovingAverage(0.999, iteration) # adding the iteration prevents from averaging across non-existing iterations
    bnepsilon = 1e-5
    if convolutional:
        mean, variance = tf.nn.moments(Ylogits, [0, 1, 2])
    else:
        mean, variance = tf.nn.moments(Ylogits, [0])
    update_moving_everages = exp_moving_avg.apply([mean, variance])
    m = tf.cond(is_test, lambda: exp_moving_avg.average(mean), lambda: mean)
    v = tf.cond(is_test, lambda: exp_moving_avg.average(variance), lambda: variance)
    Ybn = tf.nn.batch_normalization(Ylogits, m, v, offset, None, bnepsilon)
    return Ybn, update_moving_everages


###-- Part 1: Define Variables  End --###
###-- ----------------------------- --###




###-- ------------------------------------------------ --###
###-- Part 3: Define CNN layer and Draw a Graph  Start --###


def inference(x_image,IMAGE_x_SIZE,batchsize):
    ''' Build the Network 
        
        Args:
        images: Images returned from distorted_inputs() or inputs()
        
        Returns:
        prediction

        '''
    Depth_1 = 32
    Depth_2 = 64
    Depth_3 = 128



    ## conv1 layer ##
    with tf.name_scope('Conv1_layer'):
        W_conv1 = weight_variable([5,5,1,Depth_1])   # patch 5x5, in size 512 x 512 x 1, out size 256 x 256 x 2
        b_conv1 = bias_variable([Depth_1])
        h_conv1 = tf.nn.sigmoid(conv2d(x_image,W_conv1) + b_conv1, name = 'Convolution1') # output size n/2xn/2x32
        h_pool1 = max_pool_2x2(h_conv1,name = 'Pooling1')                              # output size n/2xn/2x32

    ## conv2 layer ##
    with tf.name_scope('Conv2_layer'):
        W_conv2 = weight_variable([5,5,Depth_1,Depth_2])   # patch 3x3, in size 256 x 256 x 2, out size 128 x 128 x 4
        b_conv2 = bias_variable([Depth_2])
        h_conv2 = tf.nn.sigmoid(conv2d(h_pool1,W_conv2) + b_conv2, name = 'Convolution2') # output size n/4xn/4x16
        h_pool2 = max_pool_2x2(h_conv2,name = 'Pooling2')                              # output size n/4xn/4x16


    ## deconv2 layer ##
    with tf.name_scope('deConv2_layer'):
        W_deconv2 = weight_variable([5,5,Depth_1,Depth_2]) #??  # patch 3x3, in size 128x128x4, out size 256x256x2
        b_deconv2 = bias_variable([Depth_1])
        h_deconv2 = tf.sigmoid(deconv2d(h_pool2,W_deconv2,[batchsize,IMAGE_x_SIZE/2,IMAGE_x_SIZE/2,Depth_1]) + b_deconv2, name = 'deConvolution2') # output size n/2xn/2x16
        h_depool2 = max_pool_2x2(h_deconv2,name = 'Pooling_2')                                 # output size n/4xn/4x16

    ## deconv1 layer ##
    with tf.name_scope('deConv1_layer'):
        W_deconv1  = weight_variable([5,5,1,Depth_1]) #??  # patch 3x3, in size 256x256x2, input size 512*512*1
        b_deconv1  = bias_variable([1])
        prediction = tf.sigmoid(deconv2d(h_depool2,W_deconv1,[batchsize,IMAGE_x_SIZE,IMAGE_x_SIZE,1])+b_deconv1)   # output size n/2xn/2x16


    return prediction




###-- Part 3: Define CNN layer and Draw a Graph End --###
###-- --------------------------------------------- --###




