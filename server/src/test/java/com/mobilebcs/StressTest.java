package com.mobilebcs;

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

    public static void main(String[] args) {
        try {
            restCaller = new RestCaller(8080, "localhost");
            sendImagesToQueue();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private static void sendImagesToQueue() throws InterruptedException {
        int initial;
        for (int j = 2; j <= 2; j++) { // Adjust the range of `j` as needed
            initial = 15 * j;
            for (int i = 1; i <= 15; i++) {
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
