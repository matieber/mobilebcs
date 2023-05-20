package com.mobilebcs.domain.viewer;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import com.mobilebcs.domain.jobnotification.ScoreJobNotification;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;

@Service
public class ViewerService  {

    private Map<String, ViewerPerLocation> mapByLocationCode;
    private Map<String, ViewerInfo> mapBySessionId;

    private final SimpMessagingTemplate simpMessagingTemplate;

    public ViewerService(SimpMessagingTemplate simpMessagingTemplate){
        this.simpMessagingTemplate = simpMessagingTemplate;
        mapByLocationCode =new ConcurrentHashMap<>();
        mapBySessionId=new ConcurrentHashMap<>();
    }


    public void addViewer(ViewerInfo viewerInfo) {
        mapByLocationCode.putIfAbsent(viewerInfo.getLocationCode(), new ViewerPerLocation(simpMessagingTemplate,viewerInfo.getLocationCode(),2));
        mapByLocationCode.get(viewerInfo.getLocationCode()).add(viewerInfo);
        mapBySessionId.put(viewerInfo.getSessionId(), viewerInfo);
    }

    public void removeViewer(String sessionId){
        ViewerInfo remove = mapBySessionId.remove(sessionId);
        if(remove!=null) {
            ViewerPerLocation viewerInfos = mapByLocationCode.get(remove.getLocationCode());
            if (viewerInfos != null) {
                viewerInfos.remove(sessionId);
            }
        }
    }

    public ViewerPerLocation getViewerByLocation(String locationCode){
        return mapByLocationCode.get(locationCode);
    }

    public void sendScore(ScoreJobNotification scoreJobNotification) {
        ViewerPerLocation viewerPerLocation = mapByLocationCode.get(scoreJobNotification.getLocation());
        viewerPerLocation.sendScore(scoreJobNotification);
    }
}
