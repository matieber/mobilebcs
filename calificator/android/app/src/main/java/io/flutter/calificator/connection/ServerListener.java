package io.flutter.calificator.connection;

import io.flutter.calificator.benchmark.jsonConfig.BenchmarkData;

public interface ServerListener {

    void onSuccessUpdateBatteryState();

    void onFailureUpdateBatteryState();

    void onSuccessGetBenchmarks(String jobId, BenchmarkData benchmarkData);

    void onFailureGetBenchmarks();

    void onSuccessPostResult();

    void onFailurePostResult();


    void onSuccessDeviceRegistration();

    void onFailureDeviceRegistration();

    void onFailureDeleteDevice();

    void onSuccessDeleteDevice();

    void onSuccessSwitchState(String nextState, String preparingStage);

    void onFailureSwitchState(String nextState, String preparingStage);

    void onUserInputRequired();
}
