package io.flutter.calificator.benchmark;


import android.content.Context;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.Manifest;
import android.util.Log;
import androidx.core.content.ContextCompat;
import androidx.core.app.ActivityCompat;

import com.chaquo.python.PyException;
import com.chaquo.python.PyObject;
import com.chaquo.python.Python;
import com.chaquo.python.android.AndroidPlatform;

import org.tensorflow.lite.DataType;
import org.tensorflow.lite.support.tensorbuffer.TensorBuffer;

import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import io.flutter.calificator.jnpy.Npy;
import io.flutter.calificator.services.BatteryNotificator;
import io.flutter.calificator.services.ProgressUpdater;
import io.flutter.calificator.services.WifiNotificator;

@SuppressWarnings("unused")
public class CowBodyConditionScore extends Benchmark {

    private static final String TAG = "CowBodyConditionScore";
    private final int MAX_RETRIES = 20;
    private final Context context;

    private ProgressUpdater progressUpdater = null;

    private static final boolean IS_MODEL_QUANTIZED = true;

    private final BatteryNotificator batteryNotificator;
    private final WifiNotificator wifiInfoNotificator;
    private final String img_path = "/sdcard/Download/my.png";
    private final String preprocessed_img_path = "/sdcard/Download/my.npy";

    private BcsDetectionAPIModel detector;
    private PyObject module = null;


    public CowBodyConditionScore(Context context) {
        this.context=context;

        batteryNotificator = BatteryNotificator.getInstance();
        wifiInfoNotificator = WifiNotificator.getInstance();
        Log.d(TAG, "Starting Python environment");
        /** /**The following code was possible thanks to chaquopy gradle plugin:
         * https://chaquo.com/chaquopy/doc/current/android.html#android-requirements
         *
         * Code to initialize Python environment*/
        if (! Python.isStarted()) {
            Python.start(new AndroidPlatform(context));
        }
        Python py = Python.getInstance();
        Log.d(TAG, "Getting preprocess_image python module");
        this.module = py.getModule("preprocess_image");
    }


    @Override
    public float runBenchmark(byte[] content) {
        long jobInitTime = System.currentTimeMillis();
        Log.d(TAG, String.format("Initiating Job at SystemCurrentMillis: %s", jobInitTime));
        try {

            this.detector = BcsDetectionAPIModel.create(
                   context.getAssets(),
                    "bcs_classifier_preProcDE-channels.tflite",
                    "bcslabel.txt",
                    false
            );


        } catch (IOException ex) {
            throw new RuntimeException(ex);
        }

        Log.d(TAG, "Begin iteration over job images");

            boolean success = false;
            Bitmap bm;
            long kb_input = 0;
            long endDetectionTime = -1;
            long endPreprocessingTime = -1;
            TensorBuffer tensorBuffer = null;
            List<Classifier.Recognition> recognitionList = new ArrayList<>();
            StringBuilder recog = new StringBuilder();

            try {

                long startPreprocessingTime = System.currentTimeMillis();
                getImg(0,System.currentTimeMillis(),img_path,content);
                preprocessImg(img_path);
                Npy npy = new Npy(preprocessed_img_path);
                float[] npyData = npy.floatElements();
                int[] inputShape = new int[]{1, 424, 512, 2};   //the data shape before I flattened it
                tensorBuffer = TensorBuffer.createFixedSize(inputShape, DataType.FLOAT32);
                tensorBuffer.loadArray(npyData);
                endPreprocessingTime = System.currentTimeMillis() - startPreprocessingTime;
                success = true;
            } catch (IOException e) {
                e.printStackTrace();
            }
            long startDetectionTime = System.currentTimeMillis();

            /**
             *
             * Here insert code specific to the image recognition model using bm variable as
             * input bitmap for the model.
             * **/
            if (success)
                recognitionList = detector.recognize(tensorBuffer);


            endDetectionTime = System.currentTimeMillis() - startDetectionTime;
            recog.append("'");

            /**
             *
             * Here insert code specific to output of the recognition. Please use recog
             * variable to append the result. The format is like:
             *
             * 'output result, e.g., classes, labels,score'
             *
             * */
            float value=-1;
            for (int i = 0; i < recognitionList.size(); i++) {
            Classifier.Recognition r = recognitionList.get(i);

            if(i==0){
                value= Float.parseFloat(r.getTitle());
            }

            recog.append(r.toString());
            recog.append(";");
        }

            recog.append("'");
            recog.trimToSize();

            String msg =  success + "," + jobInitTime + "," + endDetectionTime + ","/* + endNetworkTime */+ "," + endPreprocessingTime;
             msg += "," + kb_input /*+ "," + rssi_value + "," + batteryLevelInfo + ","*/ + recog;
            Log.i(TAG,"recog: "+msg);

        Log.i(TAG, "runBenchmark: imagePreffix: "/* + imagePrefix + " beginIndex = " + beginFrameIndex + " endIndex = " + endFrameIndex*/);

        Log.d(TAG, "runBenchmark: END");
        this.progressUpdater = null;
        return value;
    }

    private void preprocessImg(String pngImgPath) {

        try {
            /**The following code was possible thanks to chaquopy gradle plugin:
             * https://chaquo.com/chaquopy/doc/current/android.html#android-requirements
             *
             * it is assumed that
             * preprocessing_image script saves a .npy image at: "/sdcard/Download/my.npy"*/
            Log.d(TAG, "calling preprocess_image python module");
            module.callAttr("preprocess_image",pngImgPath);
        } catch (PyException e) {
            e.printStackTrace();
        }
    }


    private long getImg(int retry_nmb, final long request_start_millis, String imgPath, final byte[] content) throws IOException{

        if (retry_nmb > 3) {
            throw new IOException("Max retries reached while trying to save the image.");
        }

        try (FileOutputStream fileOutputStream = new FileOutputStream(imgPath)) {
            fileOutputStream.write(content);
        } catch (IOException e) {
            Log.w(TAG, "Retrying image save, attempt #" + (retry_nmb + 1)+": "+e);
            getImg(retry_nmb+1, request_start_millis, imgPath, content);
        }

        return System.currentTimeMillis() - request_start_millis;
    }

}

