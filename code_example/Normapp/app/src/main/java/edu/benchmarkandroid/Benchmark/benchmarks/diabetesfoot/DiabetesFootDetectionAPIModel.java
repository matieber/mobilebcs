/* Copyright 2019 The TensorFlow Authors. All Rights Reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
==============================================================================*/

package edu.benchmarkandroid.Benchmark.benchmarks.diabetesfoot;

import android.content.res.AssetFileDescriptor;
import android.content.res.AssetManager;
import android.graphics.Bitmap;
import android.util.Log;

import com.chaquo.python.PyException;

import org.tensorflow.lite.DataType;
import org.tensorflow.lite.Interpreter;
import org.tensorflow.lite.gpu.CompatibilityList;
import org.tensorflow.lite.gpu.GpuDelegate;
import org.tensorflow.lite.support.image.ImageProcessor;
import org.tensorflow.lite.support.image.TensorImage;
import org.tensorflow.lite.support.image.ops.ResizeOp;
import org.tensorflow.lite.support.image.ops.ResizeWithCropOrPadOp;
import org.tensorflow.lite.support.image.ops.Rot90Op;
import org.tensorflow.lite.support.tensorbuffer.TensorBuffer;

import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.MappedByteBuffer;
import java.nio.channels.FileChannel;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Vector;
import java.util.logging.Logger;

import edu.benchmarkandroid.Benchmark.benchmarks.dogsBenchmark.Classifier;

/**
 * Wrapper for frozen detection models trained using the Tensorflow Object Detection API:
 * - https://github.com/tensorflow/models/tree/master/research/object_detection
 * where you can find the training code.
 * <p>
 * To use pretrained models in the API or convert to TF Lite models, please see docs for details:
 * - https://github.com/tensorflow/models/blob/master/research/object_detection/g3doc/detection_model_zoo.md
 * - https://github.com/tensorflow/models/blob/master/research/object_detection/g3doc/running_on_mobile_tensorflowlite.md#running-our-model-on-android
 */
public class DiabetesFootDetectionAPIModel implements Classifier {


    private static final float IMAGE_MEAN = 0.0f;
    private static final float IMAGE_STD = 255.0f;
    private static final String TAG = "DiabetesFootDetectionAPIModel";
    private static int NUM_THREADS = 4;
    private boolean isModelQuantized;
    // Pre-allocated buffers.
    private ByteBuffer imgData;
    private TensorImage inputImageBuffer;


    private final Vector<String> labels = new Vector<>();

    private  float[][] mResult ;
    private Interpreter tfLite;
    private GpuDelegate gpuDelegate;
    private int inputSize = 380;
    private int[] intValues;

    private DiabetesFootDetectionAPIModel() {
    }

    /**
     * Memory-map the model file in Assets.
     */
    private static MappedByteBuffer loadModelFile(AssetManager assets, String modelFilename)
            throws IOException {
        AssetFileDescriptor fileDescriptor = assets.openFd(modelFilename);
        FileInputStream inputStream = new FileInputStream(fileDescriptor.getFileDescriptor());
        FileChannel fileChannel = inputStream.getChannel();
        long startOffset = fileDescriptor.getStartOffset();
        long declaredLength = fileDescriptor.getDeclaredLength();
        return fileChannel.map(FileChannel.MapMode.READ_ONLY, startOffset, declaredLength);
    }

    /**
     * Initializes a native TensorFlow session for classifying images.
     *
     * @param assetManager  The asset manager to be used to load assets.
     * @param modelFilename The filepath of the model GraphDef protocol buffer.
     * @param labelsarray The filepath of label file for classes.
     *
     */
    public static DiabetesFootDetectionAPIModel create(
            final AssetManager assetManager,
            final String modelFilename,
            final String[] labelsarray,
            final boolean useGpu,
            final boolean isQuantized)
            throws IOException {
        final DiabetesFootDetectionAPIModel d = new DiabetesFootDetectionAPIModel();

        d.labels.addAll(Arrays.asList(labelsarray));
        try {
            Interpreter.Options options = new Interpreter.Options();
            if (useGpu) {
                CompatibilityList compatibilityList = new CompatibilityList();

                d.gpuDelegate = new GpuDelegate(compatibilityList.getBestOptionsForThisDevice());
                options.addDelegate(d.gpuDelegate);
            } else {
                options.setNumThreads(NUM_THREADS);
                options.setUseXNNPACK(false);
            }
            int numBytesPerChannel;
            if (isQuantized) {
                numBytesPerChannel = 1; // Quantized
            } else {
                numBytesPerChannel = 4; // Floating point
            }
            d.tfLite = new Interpreter(loadModelFile(assetManager, modelFilename), options);
            d.imgData = ByteBuffer.allocateDirect(d.inputSize * d.inputSize * 3 * numBytesPerChannel);
            d.imgData.order(ByteOrder.nativeOrder());
            d.intValues = new int[d.inputSize * d.inputSize];
            d.mResult = new float[1][d.labels.size()];

        } catch (Exception e) {
            throw new IOException(e);
        }
        return d;
    }


    @Override
    public List<Recognition> recognizeImage(final Bitmap bitmap) {
        TensorImage inputImage = loadImage(bitmap,0);
        //bitmap.copyPixelsToBuffer(imgData);

        /*imgData.rewind();
        for (int i = 0; i < inputSize; ++i) {
            for (int j = 0; j < inputSize; ++j) {
                int pixelValue = intValues[i * inputSize + j];
                if (isModelQuantized) {
                    // Quantized model
                    imgData.put((byte) ((pixelValue >> 16) & 0xFF));
                    imgData.put((byte) ((pixelValue >> 8) & 0xFF));
                    imgData.put((byte) (pixelValue & 0xFF));
                } else { // Float model
                    imgData.putFloat((((pixelValue >> 16) & 0xFF) - IMAGE_MEAN) / IMAGE_STD);
                    imgData.putFloat((((pixelValue >> 8) & 0xFF) - IMAGE_MEAN) / IMAGE_STD);
                    imgData.putFloat(((pixelValue & 0xFF) - IMAGE_MEAN) / IMAGE_STD);
                }
            }
        }*/


        final ArrayList<Recognition> recognitions = new ArrayList<>(1);
        Log.d("DiabetesFootDetectionAPIModel",mResult.toString());
        int max= argmax (mResult[0]);
        recognitions.add(
                new Recognition(
                        "0" , labels.elementAt(max)                         ,
                        mResult[0][max],
                        max,null));
        return recognitions;
    }

    private TensorImage loadImage(final Bitmap bitmap, int sensorOrientation) {
        // Loads bitmap into a TensorImage.
        inputImageBuffer.load(bitmap);

        // Creates processor for the TensorImage.
        int cropSize = Math.min(bitmap.getWidth(), bitmap.getHeight());
        int numRoration = sensorOrientation / 90;
        ImageProcessor imageProcessor =
                new ImageProcessor.Builder()
                        .add(new ResizeWithCropOrPadOp(cropSize, cropSize))
                        .add(new ResizeOp(inputSize, inputSize, ResizeOp.ResizeMethod.BILINEAR))
                        .add(new Rot90Op(numRoration))
                        //.add(getPreprocessNormalizeOp())
                        .build();
        return imageProcessor.process(inputImageBuffer);
    }

    @Override
    public void enableStatLogging(final boolean logStats) {
    }

    @Override
    public String getStatString() {
        return "";
    }

    @Override
    public void close() {
        if (tfLite != null) {
            //The app may crash if this is done!
            tfLite.close();
            tfLite = null;
        }
        if (gpuDelegate != null) {
            gpuDelegate.close();
            gpuDelegate = null;
        }
    }

    public void setNumThreads(int num_threads) {
        DiabetesFootDetectionAPIModel.NUM_THREADS = num_threads;
        //if (tfLite != null) tfLite.setNumThreads(num_threads);
    }

    @Override
    public void setUseNNAPI(boolean isChecked) {

    }

    @Override
    public boolean isGPUAvailable() {
        CompatibilityList compatibilityList = new CompatibilityList();

        return compatibilityList.isDelegateSupportedOnThisDevice();
    }

    private static int argmax(float[] probs) {
        int maxIdx = -1;
        float maxProb = 0.0f;
        for (int i = 0; i < probs.length; i++) {
            if (probs[i] > maxProb) {
                maxProb = probs[i];
                maxIdx = i;
            }
        }
        return maxIdx;
    }

}
