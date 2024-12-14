package com.mobilebcs;

import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.Map;
public class StressTest {


    private static final String LOCATION_CODE = "DEFAULT";
    private static final Map<Integer, String> MAP = new HashMap<>();
    private static RestCaller restCaller;

    static {
        MAP.put(1, "UHSJQ3");
        MAP.put(2, "GSVQMB");
        MAP.put(3, "9ZF1TV");
        MAP.put(4, "GG8CWT");
        MAP.put(5, "TEURMB");
        MAP.put(6, "BYHRFV");
        MAP.put(7, "AJ2RIR");
        MAP.put(8, "DT4NWA");
        MAP.put(9, "IFFVM7");
        MAP.put(10, "7749T6");
        MAP.put(11, "RW674H");
        MAP.put(12, "RSVZ1B");
        MAP.put(13, "ZHBMMB");
        MAP.put(14, "MQ8ABZ");
        MAP.put(15, "7PSFVM");
    }

    @BeforeAll
    public static void setup() {
        String ip = System.getProperty("remoteIp", "localhost");
        restCaller = new RestCaller(8080, ip);
    }


    @Test
    public void sendImagesToQueue() throws InterruptedException {
        int initial;
        for (int j = 0; j < 146; j++) {
            initial = 12 * j;
            for (int i = 1; i <= 12; i++) {
                DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss.SSS");
                System.out.println(LocalDateTime.now().format(dtf) +
                        " Sending image " + (initial + i) + " to queue " + MAP.get(i));

                try {
                    restCaller.sendRealImage(i, LOCATION_CODE, MAP.get(i), initial + i);
                } catch (Exception e) {
                    System.err.println("Error sending image " + (initial + i) + ": " + e.getMessage());
                }
                Thread.sleep(1000); // Pause between sends
            }
            Thread.sleep(10000); // Pause after processing a batch
        }
    }
}
