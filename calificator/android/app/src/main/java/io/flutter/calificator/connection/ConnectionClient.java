package io.flutter.calificator.connection;


import com.google.gson.JsonObject;

import io.flutter.calificator.benchmark.jsonConfig.BenchmarksResponse;
import io.flutter.calificator.model.UpdateData;
import okhttp3.MultipartBody;
import retrofit2.Call;
import retrofit2.http.Body;
import retrofit2.http.DELETE;
import retrofit2.http.GET;
import retrofit2.http.Headers;
import retrofit2.http.Multipart;
import retrofit2.http.POST;
import retrofit2.http.PUT;
import retrofit2.http.Part;
import retrofit2.http.Path;
import retrofit2.http.Query;

public interface ConnectionClient {

    @GET("{model}")
    Call<BenchmarksResponse> getBenchmarks(@Path("model") String model);


    @GET("{model}")
    Call<JsonObject> startBenchmark(@Path("model") String model, @Query("stage") String stage,  // Call with stage = "postinit"
                                    @Query("requiredBatteryState") String stateOfCharge);

    @Headers({"Content-Type: application/x-www-form-urlencoded; charset=UTF-8"})
    @PUT("{model}")
    Call<JsonObject> putUpdateBatteryState(@Path("model") String model, @Body UpdateData updateData);


    @Multipart
    @POST("{model}")
    Call<JsonObject> postResult(@Path("model") String model, @Query("fileName") String filename, @Part MultipartBody.Part body);


    @DELETE("{model}")
    Call<JsonObject> deleteDevice(@Path("model") String model, @Query("ip") String ipAddr);

    @Headers({"Content-Type: application/x-www-form-urlencoded; charset=UTF-8"})
    @PUT("{model}")
    Call<JsonObject> switchState(@Path("model") String model, @Query("requiredEnergyState") String requiredEnergyState, @Query("slotId") String slotId);

}
