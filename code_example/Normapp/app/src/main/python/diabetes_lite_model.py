import tensorflow as tf
import numpy as np
from tensorflow.keras.preprocessing import image

MODEL_PATH = "/sdcard/Download/diabetesfoot_model.tflite"
IMG_SIZE = (380, 380)
IMG_SHAPE = IMG_SIZE + (3,)
CLASS_NAMES = ["W0", "W1", "W2", "W3", "W4", "W6"]


# Load the TFLite model and allocate tensors.
interpreter = tf.lite.Interpreter(model_path=MODEL_PATH)
interpreter.allocate_tensors()

# Get input and output tensors.
input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

#TEST_PATH = "./frameRoot/diabetes/diabetes.1.jpg"

def predict(img_path):
    img = image.load_img(img_path, target_size=IMG_SIZE)
    img_array = image.img_to_array(img)
    img_array = tf.expand_dims(img_array, 0)

    interpreter.set_tensor(input_details[0]['index'], img_array)

    interpreter.invoke()

    # Use `tensor()` in order to get a pointer to the tensor.
    output_data = interpreter.get_tensor(output_details[0]['index'])


    score = tf.nn.softmax(output_data[0])
    recog = "Predicted="+ CLASS_NAMES[np.argmax(score)]+ ", Confidence="+ str(100 * np.max(score))
    with open("/sdcard/Download/diabetes.txt", "w") as f:
        f.write(str(recog))
    return recog
    #print(score)
    #print(f"Predicted = {CLASS_NAMES[np.argmax(score)]}")
    #print(f"Confidence = {100 * np.max(score)}")
