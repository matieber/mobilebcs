package com.mobilebcs.domain.viewer;

import com.mobilebcs.domain.jobnotification.JobNotificationOutput;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.TimeUnit;
import javax.validation.Valid;
import javax.validation.constraints.NotNull;

import com.mobilebcs.domain.jobnotification.ScoreJobNotification;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.messaging.simp.SimpMessagingTemplate;

@Valid
public class ViewerPerLocation {

    private final LinkedBlockingQueue<ViewerInfo> set;
    private final Map<String,ViewerInfo> map;
    private final String locationCode;
    private final SimpMessagingTemplate simpMessagingTemplate;
    private int pollTimeoutSeconds;

    public ViewerPerLocation(SimpMessagingTemplate simpMessagingTemplate, String locationCode, @Value("${nextviewer.poll.senconds.timeout:2}") int pollTimeoutSeconds) {
        this.simpMessagingTemplate=simpMessagingTemplate;
        this.locationCode=locationCode;
        this.set = new LinkedBlockingQueue<>();
        this.pollTimeoutSeconds=pollTimeoutSeconds;
        map=new ConcurrentHashMap<>();
    }

    public void add(@NotNull ViewerInfo viewerInfo){
        ViewerInfo oldValue = map.put(viewerInfo.getSessionId(), viewerInfo);
        boolean isNewViewer = oldValue == null;
        if(isNewViewer){
            set.add(viewerInfo);
        }
    }

    public void remove(@NotNull String sessionId){
        boolean removedFromSet = set.removeIf(viewerInfo ->
            sessionId.equals(viewerInfo.getSessionId()));
        ViewerInfo removedFromMap = map.remove(sessionId);
        System.out.println("removed from set "+removedFromSet+ " and removed from map "+removedFromMap);
    }

    public boolean send(JobNotificationOutput jobNotificationOutput) throws InterruptedException {
        boolean sent=false;
            ViewerInfo predictedJob = set.poll(pollTimeoutSeconds, TimeUnit.SECONDS);
            if(predictedJob!=null) {
                set.add(predictedJob);
                jobNotificationOutput.setPredictor(predictedJob.getName());
                System.out.println("sending to predict "+predictedJob.getName());
                this.simpMessagingTemplate.convertAndSend("/topic/notifications/" + locationCode + "/" + predictedJob.getName(), jobNotificationOutput);;
                sent=true;
                for(ViewerInfo viewerInfo:map.values()){
                    if(!viewerInfo.getSessionId().equals(predictedJob.getSessionId())){
                        System.out.println("sending to not predict "+ viewerInfo.getName());
                        this.simpMessagingTemplate.convertAndSend("/topic/notifications/" + locationCode + "/" + viewerInfo.getName(), jobNotificationOutput);
                    }
                }
            }
        return sent;
    }

    public void sendScore(ScoreJobNotification scoreJobNotification) {
        for(ViewerInfo viewerInfo:map.values()){
            if(!viewerInfo.getName().equals(scoreJobNotification.getPredictor())){
                this.simpMessagingTemplate.convertAndSend("/topic/notifications/score/" + locationCode + "/" + viewerInfo.getName(), scoreJobNotification);
            }
        }
    }
}
