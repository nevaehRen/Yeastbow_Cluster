
import tensorflow as tf
import numpy as np


def inputs(xs,ys,InputSize,OutputSize,IMAGE_x_SIZE,IMAGE_y_SIZE):
    """Construct input for training.
        
    Args:
        xs: Images. 1D tensor of [Batchsize*InputSize*InputSize*1].
        ys: Labels. 1D tensor of [Batchsize*InputSize*InputSize*1].
    
    Returns:
        x_image: Images. 4D tensor of [batch_size, IMAGE_SIZE, IMAGE_SIZE, 1] size.
        y_image: Labels. 4D tensor of [batch_size, IMAGE_SIZE, IMAGE_SIZE, 1] size.
    """
        
    x_image     = tf.reshape(xs, [-1,InputSize, InputSize, 1],   name='Input_Image' )
    y_image     = tf.reshape(ys, [-1,OutputSize,OutputSize,1],   name='Output_Image')

    if InputSize!=IMAGE_x_SIZE:
        x_image     = tf.image.resize_images(x_image, IMAGE_x_SIZE, IMAGE_x_SIZE  )
        y_image     = tf.image.resize_images(y_image, IMAGE_y_SIZE, IMAGE_y_SIZE  )


    return x_image, y_image




def distorted_inputs(xs,ys,InputSize,OutputSize,IMAGE_x_SIZE,IMAGE_y_SIZE):
    """Construct distorted input for training.
        
    Args:
        xs: Images. 1D tensor of [Batchsize*InputSize*InputSize*1].
        ys: Labels. 1D tensor of [Batchsize*InputSize*InputSize*1].
    
    Returns:
        x_image: Images. 4D tensor of [batch_size, IMAGE_SIZE, IMAGE_SIZE, 1] size.
        y_image: Labels. 4D tensor of [batch_size, IMAGE_SIZE, IMAGE_SIZE, 1] size.
    """

    distorted_x_image = tf.cast(tf.reshape(xs, [-1,InputSize,InputSize,1]), tf.float32)
    distorted_y_image = tf.cast(tf.reshape(ys, [-1,OutputSize,OutputSize,1]), tf.float32)

    if InputSize!=IMAGE_x_SIZE:
        Seednum = np.random.randint(0,1234)
        distorted_x_image = tf.random_crop(distorted_x_image, [-1,IMAGE_x_SIZE, IMAGE_x_SIZE,1],seed=Seednum)
        distorted_y_image = tf.random_crop(distorted_y_image, [-1,IMAGE_y_SIZE, IMAGE_y_SIZE,1],seed=Seednum)

    # Randomly flip the image horizontally.
    Seednum = np.random.randint(0,2)
    if Seednum == 1:
        distorted_x_image = tf.image.flip_left_right(distorted_x_image)
        distorted_y_image = tf.image.flip_left_right(distorted_y_image)

    Seednum = np.random.randint(0,2)
    if Seednum == 1:
        distorted_x_image = tf.image.flip_up_down(distorted_x_image)
        distorted_y_image = tf.image.flip_up_down(distorted_y_image)

#    distorted_x_image = tf.image.random_brightness(distorted_x_image, max_delta=63)
#    distorted_x_image = tf.image.random_contrast(distorted_x_image, lower=0.2, upper=1)
    
#    distorted_x_image = tf.image.per_image_whitening(distorted_x_image)
#    distorted_y_image = tf.image.per_image_whitening(distorted_y_image)

    x_image = tf.reshape(distorted_x_image, [-1,IMAGE_x_SIZE,IMAGE_x_SIZE,1])
    y_image = tf.reshape(distorted_y_image, [-1,IMAGE_y_SIZE,IMAGE_y_SIZE,1])



    return x_image, y_image





