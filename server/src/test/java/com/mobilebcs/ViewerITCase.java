package com.mobilebcs;

import com.mobilebcs.configuration.ClientJobNotificationOutputStompHandler;
import com.mobilebcs.configuration.ClientScoreJobNotificationStompHandler;
import com.mobilebcs.controller.user.UserType;
import com.mobilebcs.domain.jobnotification.JobNotificationOutput;
import com.mobilebcs.domain.jobnotification.ScoreJobNotification;
import java.util.ArrayList;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;
import org.apache.commons.io.FileUtils;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Captor;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.messaging.converter.MappingJackson2MessageConverter;
import org.springframework.messaging.simp.stomp.StompSession;
import org.springframework.messaging.simp.stomp.StompSessionHandler;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.util.concurrent.ListenableFuture;
import org.springframework.web.socket.client.WebSocketClient;
import org.springframework.web.socket.messaging.WebSocketStompClient;

import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;
import java.util.List;
import java.util.UUID;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;

import static org.mockito.Mockito.timeout;


@ActiveProfiles("test")
@SpringBootTest(classes = {ServerApp.class},webEnvironment = SpringBootTest.WebEnvironment.DEFINED_PORT)
@ExtendWith(MockitoExtension.class)
public class ViewerITCase extends AbstractITCase {


    private static final String LOCATION_CODE = "DEFAULT";


    @LocalServerPort
    private int port;

    private RestCaller restCaller;

    @Value("${images.path}")
    private String imagePath;


    @Autowired
    private WebSocketClient webSocketClient;

    @Mock
    private StompSessionHandler stompSessionHandler;
    @Mock
    private StompSessionHandler stompSessionHandler2;
    @Captor
    private ArgumentCaptor<Object> objectArgumentCaptor;
    @Captor
    private ArgumentCaptor<Object> objectArgumentCaptor2;
    @Captor
    private ArgumentCaptor<Object> objectArgumentCaptor3;
    @BeforeEach
    public void init() throws IOException, ExecutionException, InterruptedException, TimeoutException {


        FileUtils.deleteDirectory(new File(Paths.get(imagePath).toString()));
        restCaller = new RestCaller(port);

    }


    public StompSession clientStompSession(
            WebSocketClient webSocketClient,
            Integer port
    ) throws InterruptedException, ExecutionException, TimeoutException {
        final WebSocketStompClient stompClient = new WebSocketStompClient(webSocketClient);
        stompClient.setMessageConverter(new MappingJackson2MessageConverter());
        ListenableFuture<StompSession> connect = stompClient.connect("ws://localhost:8080/nextjob", Mockito.mock(ClientJobNotificationOutputStompHandler.class));
        return connect.get(60, TimeUnit.SECONDS);
    }

    @Test
    public void predictAndSent() throws IOException, InterruptedException, ExecutionException, TimeoutException {
        Mockito.doNothing().when(stompSessionHandler).handleFrame(Mockito.any(),objectArgumentCaptor.capture());
        Mockito.doNothing().when(stompSessionHandler2).handleFrame(Mockito.any(),objectArgumentCaptor2.capture());
        List<SubscribedViewer> viewers = getSubscribedViewer();
        restCaller.sendImage(1, LOCATION_CODE);

        Mockito.verify(stompSessionHandler,timeout(10000L).times(1)).handleFrame(Mockito.any(),Mockito.any(JobNotificationOutput.class));
        Mockito.verify(stompSessionHandler2,timeout(10000L).times(1)).handleFrame(Mockito.any(),Mockito.any(JobNotificationOutput.class));

        Thread.sleep(1000);
        Optional<JobNotificationOutput> jobNotificationOutput1 = objectArgumentCaptor.getAllValues().stream().filter(object -> object instanceof JobNotificationOutput).map(o->(JobNotificationOutput)o).findAny();
        Optional<JobNotificationOutput> jobNotificationOutput2 = objectArgumentCaptor2.getAllValues().stream().filter(object -> object instanceof JobNotificationOutput).map(o->(JobNotificationOutput)o).findAny();

        Assertions.assertTrue(jobNotificationOutput1.isPresent());
        Assertions.assertTrue(jobNotificationOutput2.isPresent());
        Assertions.assertEquals(jobNotificationOutput1.get().getPredictor(),jobNotificationOutput2.get().getPredictor());
        String predictor = jobNotificationOutput1.get().getPredictor();

        if(viewers.get(0).viewer.equals(predictor)){
            Mockito.verify(stompSessionHandler2,Mockito.times(1)).handleFrame(
                Mockito.any(),Mockito.any(ScoreJobNotification.class)
            );
            validateScore(objectArgumentCaptor2);
        }else{
            Assertions.assertEquals(viewers.get(1).viewer,predictor);
            Mockito.verify(stompSessionHandler,Mockito.times(1)).handleFrame(
                Mockito.any(),Mockito.any(ScoreJobNotification.class)
            );
            validateScore(objectArgumentCaptor);

        }
        Mockito.verifyNoMoreInteractions(stompSessionHandler,stompSessionHandler2);

        viewers.get(0).stompSession.disconnect();
        viewers.get(1).stompSession.disconnect();

        restCaller.endSession(LOCATION_CODE);


    }

    private void validateScore(ArgumentCaptor<Object> argumentCaptor) {
        Optional<ScoreJobNotification> scoreJobNotification = argumentCaptor.getAllValues().stream().filter(object -> object instanceof ScoreJobNotification).map(o->(ScoreJobNotification)o).findAny();
        Assertions.assertTrue(scoreJobNotification.isPresent());
        Assertions.assertEquals(3,scoreJobNotification.get().getScore());
        Assertions.assertEquals(LOCATION_CODE,scoreJobNotification.get().getLocation());
    }

    @Test
    public void testViewer() throws IOException, InterruptedException, ExecutionException, TimeoutException {

        Mockito.doNothing().when(stompSessionHandler).handleFrame(Mockito.any(),objectArgumentCaptor.capture());
        Mockito.doNothing().when(stompSessionHandler2).handleFrame(Mockito.any(),objectArgumentCaptor2.capture());
        List<SubscribedViewer> viewers = getSubscribedViewer();

        Thread.sleep(1000);
        for (int position = 1; position <= 10; position++) {
            restCaller.sendImage(position, LOCATION_CODE);
        }


        Mockito.verify(stompSessionHandler,timeout(10000L).times(10)).handleFrame(Mockito.any(),Mockito.any(JobNotificationOutput.class));
        Mockito.verify(stompSessionHandler2,timeout(10000L).times(10)).handleFrame(Mockito.any(),Mockito.any(JobNotificationOutput.class));
        Mockito.verify(stompSessionHandler,timeout(10000L).times(5)).handleFrame(Mockito.any(),Mockito.any(ScoreJobNotification.class));
        Mockito.verify(stompSessionHandler2,timeout(10000L).times(5)).handleFrame(Mockito.any(),Mockito.any(ScoreJobNotification.class));


        testNotification(objectArgumentCaptor,2, 10, 1, viewers.get(0).viewer);
        testNotification(objectArgumentCaptor2,2, 10, 1, viewers.get(1).viewer);
        viewers.get(0).subscribe.unsubscribe();
        viewers.get(0).subscribeScore.unsubscribe();
        Thread.sleep(1000);
        restCaller.sendImage(11, LOCATION_CODE);

        Mockito.reset(stompSessionHandler2);
        Mockito.verify(stompSessionHandler2,timeout(10000L).times(1)).handleFrame(Mockito.any(),objectArgumentCaptor3.capture());
        testNotification(objectArgumentCaptor3,1, 1, 11, viewers.get(1).viewer);
        viewers.get(0).stompSession.disconnect();
        viewers.get(1).stompSession.disconnect();
        restCaller.endSession(LOCATION_CODE);
        Mockito.verifyNoMoreInteractions(stompSessionHandler);
    }

    private List<SubscribedViewer> getSubscribedViewer() throws ExecutionException, InterruptedException, TimeoutException {
        String qualifier = "qualifier1" + UUID.randomUUID();
        restCaller.createUser(qualifier, UserType.QUALIFIER);
        long qualificationSession = restCaller.joinQualificationSession(qualifier, null, LOCATION_CODE);

        SubscribedViewer viewers1 = getViewer("viewer1", stompSessionHandler);

        SubscribedViewer viewers2 = getViewer("viewer2", stompSessionHandler2);
        return List.of(viewers1,viewers2);
    }

    private SubscribedViewer getViewer(String viewer, StompSessionHandler stompSessionHandler) throws ExecutionException, InterruptedException, TimeoutException {
        viewer = viewer + UUID.randomUUID();
        restCaller.createUser(viewer, UserType.VIEWER);
        StompSession stompSession = clientStompSession(webSocketClient, port);
        ClientJobNotificationOutputStompHandler
            clientJobNotificationOutputStompHandler = new ClientJobNotificationOutputStompHandler(stompSessionHandler, stompSession, LOCATION_CODE, viewer);
        ClientScoreJobNotificationStompHandler clientScoreJobNotificationOutputStompHandler = new ClientScoreJobNotificationStompHandler(stompSessionHandler);
        StompSession.Subscription subscribe = stompSession.subscribe("/topic/notifications/" + LOCATION_CODE + "/" + viewer, clientJobNotificationOutputStompHandler);
        StompSession.Subscription subscribeScore = stompSession.subscribe("/topic/notifications/score/" + LOCATION_CODE + "/" + viewer,
            clientScoreJobNotificationOutputStompHandler);
        SubscribedViewer viewers1 = new SubscribedViewer(subscribe, viewer, subscribeScore,stompSession);
        return viewers1;
    }

    private static class SubscribedViewer {
        public final StompSession.Subscription subscribe;
        public final String viewer;
        public final StompSession.Subscription subscribeScore;
        public final StompSession stompSession;

        public SubscribedViewer(StompSession.Subscription subscribe, String viewer, StompSession.Subscription subscribeScore, StompSession stompSession) {
            this.subscribe = subscribe;
            this.viewer = viewer;
            this.subscribeScore = subscribeScore;
            this.stompSession=stompSession;
        }
    }

    private void testNotification(ArgumentCaptor<Object> argumentCaptor, int amountViewer, int imageSize, int startedIndex, String viewer) {
        List<JobNotificationOutput> allValues = argumentCaptor.getAllValues().stream().filter(o->o instanceof JobNotificationOutput).map(o->(JobNotificationOutput)o).collect(Collectors.toList());
        Assertions.assertEquals(imageSize,allValues.size());

        int amountOfPredictions=0;
        for (JobNotificationOutput actualJobNotificationOutput : allValues) {
            Assertions.assertNotNull(actualJobNotificationOutput);
            if(actualJobNotificationOutput.getPredictor().equals(viewer)){
                amountOfPredictions++;
            }
            Assertions.assertEquals(startedIndex,actualJobNotificationOutput.getPosition());
            startedIndex++;
        }
        if(allValues.size()>1){
            Assertions.assertEquals(allValues.size() / amountViewer, amountOfPredictions);
        }
    }


}
