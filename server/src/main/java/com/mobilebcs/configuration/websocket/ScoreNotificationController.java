package com.mobilebcs.configuration.websocket;

import com.mobilebcs.domain.exception.InvalidLocalizationException;
import com.mobilebcs.domain.predictions.ScorePredictionService;
import com.mobilebcs.domain.jobnotification.ScoreJobNotification;
import com.mobilebcs.domain.viewer.ViewerService;
import java.sql.SQLException;
import org.springframework.messaging.handler.annotation.MessageMapping;

import org.springframework.stereotype.Component;
import org.springframework.stereotype.Controller;

@Controller
@Component
public class ScoreNotificationController {


    private final ViewerService viewerService;
    public final ScorePredictionService scorePredictionService;

    public ScoreNotificationController(ViewerService viewerService, ScorePredictionService scorePredictionService) {
        this.viewerService = viewerService;
        this.scorePredictionService = scorePredictionService;
    }



    @MessageMapping("/score")
    public void webSocketMessage(ScoreJobNotification scoreJobNotification) throws SQLException, InvalidLocalizationException {
        System.out.println(scoreJobNotification.toString());
        scorePredictionService.saveScore(scoreJobNotification.getSetCode(),scoreJobNotification.getScore(),scoreJobNotification.getLocation());
        viewerService.sendScore(scoreJobNotification);

    }

}