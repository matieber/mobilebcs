package io.flutter.calificator;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.widget.TextView;
import android.Manifest;
import android.content.pm.PackageManager;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import androidx.annotation.NonNull;
import androidx.core.content.ContextCompat;

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

    private static Context context;

    private static final String CHANNEL = "io.flutter.calificator/calificator";


    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine){
        final MethodChannel methodChannel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL);
        super.configureFlutterEngine(flutterEngine);
        methodChannel
                .setMethodCallHandler(
                (call,result)->{
                    if(call.method.equals("calculateScore")){
                        byte[] content=call.arguments();
                        float score=calculateScore(content);
                        result.success(score);
                    }else {
                        result.notImplemented();
                    }
                    return;
                }
                );
    }

    private float calculateScore(byte[] content) {
        CowBodyConditionScore cowBodyConditionScore = new CowBodyConditionScore(context);
        return cowBodyConditionScore.runBenchmark(content);
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
        context = getApplicationContext();
        requestStoragePermissions();
        initiateBenchmarksExecutionSet();

    }

    // Verifica y solicita permisos si es necesario
    public void requestStoragePermissions() {
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.WRITE_EXTERNAL_STORAGE)
                != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(this,
                    new String[]{Manifest.permission.WRITE_EXTERNAL_STORAGE, Manifest.permission.READ_EXTERNAL_STORAGE},
                    1);
        }
    }
}
