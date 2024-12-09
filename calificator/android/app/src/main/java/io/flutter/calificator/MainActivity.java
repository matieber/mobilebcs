package io.flutter.calificator;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.widget.TextView;
import android.Manifest;
import android.content.pm.PackageManager;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.core.content.ContextCompat;

import java.util.Map;

import io.flutter.calificator.benchmark.CowBodyConditionScore;
import io.flutter.calificator.services.BenchmarkExecutor;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;


public class MainActivity extends FlutterActivity {

    // CHANGE THIS CONSTANTS TO THE VALUE OF YOUR PREFERENCE
    public static final String PATH = "/sdcard/Download/";
    public static final String INFORM_SERVICE_PROGRESS = "INFORM_SERVICE_PROGRESS";
    public static final String INFORM_SERVICE_RUNNING = "RUNNING";
    public static final String PERFORM_ACTION = "PERFORM_ACTION";
    public static final String SERVICE_MSG = "SERVICE_MSG";
    public static final String INFORM_SERVICE_TERMINATED = "TERMINATED";
    public static final String UNSET_KEEP_SCREEN_ON = "UNSET_KEEP_SCREEN_ON";
    public static final String SET_KEEP_SCREEN_ON = "SET_KEEP_SCREEN_ON";
    public static final String INFORM_SERVICE_JOB_FINISHED = "JOB_FINISHED";
    private Intent execServiceIntent;
    private static final String TAG = "MainActivity";

    private CowBodyConditionScore cowBodyConditionScore;

    private static final String CHANNEL = "io.flutter.calificator/calificator";


    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine){
        final MethodChannel methodChannel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL);
        super.configureFlutterEngine(flutterEngine);
        methodChannel
                .setMethodCallHandler(
                (call,result)->{

                    if(call.method.equals("calculateScore")){
                        Map<String,Object> arguments=call.arguments();
                        int position = (int) arguments.get("position");
                        Log.d(TAG, "in-plugin-processing-score in index: "+position);
                        float score=calculateScore( position);
                        result.success(score);
                    }else {
                        result.notImplemented();
                    }
                    return;
                }
                );
    }

    private float calculateScore(int position) {
        return cowBodyConditionScore.runBenchmark(position);
    }

    private void initiateBenchmarksExecutionSet() {


        execServiceIntent = new Intent(this, BenchmarkExecutor.class);
        ContextCompat.startForegroundService(this, execServiceIntent);

    }

    @Override
    protected void onStart() {
        super.onStart();
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Context context = getApplicationContext();
        requestStoragePermissions();
        initiateBenchmarksExecutionSet();
        cowBodyConditionScore = new CowBodyConditionScore(context);


    }



    public void requestStoragePermissions() {
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.R) {
            // Para Android 11 (API 30) o superior
            if (!android.os.Environment.isExternalStorageManager()) {
                Intent intent = new Intent(android.provider.Settings.ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION);
                intent.setData(android.net.Uri.parse("package:" + getPackageName()));
                startActivity(intent);
            }
        } else {
            // Para Android 10 (API 29) o inferior
            if (ContextCompat.checkSelfPermission(this, Manifest.permission.WRITE_EXTERNAL_STORAGE)
                    != PackageManager.PERMISSION_GRANTED) {
                ActivityCompat.requestPermissions(this,
                        new String[]{Manifest.permission.WRITE_EXTERNAL_STORAGE, Manifest.permission.READ_EXTERNAL_STORAGE},
                        1);
            }
        }
    }
}
