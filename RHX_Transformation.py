
import tensorflow as tf
import numpy as np





def distorted_inputs(x_image,y_image):
    """Construct distorted input for training.
        
    Args:
        xs: Images. 1D tensor of [Batchsize*InputSize*InputSize*1].
        ys: Labels. 1D tensor of [Batchsize*InputSize*InputSize*1].
    
    Returns:
        x_image: Images. 4D tensor of [batch_size, IMAGE_SIZE, IMAGE_SIZE, 1] size.
        y_image: Labels. 4D tensor of [batch_size, IMAGE_SIZE, IMAGE_SIZE, 1] size.
    """
    Patch_Size = tf.shape(x_image)[1]

    x_image = tf.cast(tf.reshape(x_image, [Patch_Size,Patch_Size,1]), tf.float32)
    y_image = tf.cast(tf.reshape(y_image, [Patch_Size,Patch_Size,1]), tf.float32)

    # Randomly flip the image horizontally.
    Seednum = np.random.randint(0,2)
    if Seednum == 1:
        x_image = tf.image.flip_left_right(x_image)
        y_image = tf.image.flip_left_right(y_image)

    Seednum = np.random.randint(0,2)
    if Seednum == 1:
        x_image = tf.image.flip_up_down(x_image)
        y_image = tf.image.flip_up_down(y_image)

#    distorted_x_image = tf.image.random_brightness(distorted_x_image, max_delta=63)
#    distorted_x_image = tf.image.random_contrast(distorted_x_image, lower=0.2, upper=1)
    
#    distorted_x_image = tf.image.per_image_whitening(distorted_x_image)
#    distorted_y_image = tf.image.per_image_whitening(distorted_y_image)

    x_image = tf.reshape(x_image, [-1,Patch_Size,Patch_Size,1])
    y_image = tf.reshape(y_image, [-1,Patch_Size,Patch_Size,1])



    return x_image, y_image





