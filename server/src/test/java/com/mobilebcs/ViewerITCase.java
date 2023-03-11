package com.mobilebcs;

import com.mobilebcs.configuration.ClientSocketStompSessionHandler;
import com.mobilebcs.controller.user.UserType;
import com.mobilebcs.domain.jobnotification.JobNotificationOutput;
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
import org.springframework.lang.Nullable;
import org.springframework.messaging.converter.MappingJackson2MessageConverter;
import org.springframework.messaging.simp.stomp.StompHeaders;
import org.springframework.messaging.simp.stomp.StompSession;
import org.springframework.messaging.simp.stomp.StompSessionHandler;
import org.springframework.messaging.simp.stomp.StompSessionHandlerAdapter;
import org.springframework.test.annotation.DirtiesContext;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.util.concurrent.ListenableFuture;
import org.springframework.web.socket.client.WebSocketClient;
import org.springframework.web.socket.messaging.WebSocketStompClient;

import java.io.File;
import java.io.IOException;
import java.lang.reflect.Type;
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


    private StompSession stompSession;

    @Autowired
    private WebSocketClient webSocketClient;

    @Mock
    private StompSessionHandler stompSessionHandler;

    @Captor
    private ArgumentCaptor<Object> objectArgumentCaptor;

    private ClientSocketStompSessionHandler clientSocketStompSessionHandler;
    @BeforeEach
    public void init() throws IOException, ExecutionException, InterruptedException, TimeoutException {


        FileUtils.deleteDirectory(new File(Paths.get(imagePath).toString()));
        restCaller = new RestCaller(port);
        clientSocketStompSessionHandler = new ClientSocketStompSessionHandler(stompSessionHandler);
                stompSession = clientStompSession( webSocketClient, port);
    }


    public StompSession clientStompSession(
            WebSocketClient webSocketClient,
            Integer port
    ) throws InterruptedException, ExecutionException, TimeoutException {
        final WebSocketStompClient stompClient = new WebSocketStompClient(webSocketClient);
        stompClient.setMessageConverter(new MappingJackson2MessageConverter());
        ListenableFuture<StompSession> connect = stompClient.connect("ws://localhost:8080/nextjob", clientSocketStompSessionHandler);
        return connect.get(60, TimeUnit.SECONDS);
    }

    @Test
    public void testViewer() throws IOException, InterruptedException {


        String name1 = "qualifier1" + UUID.randomUUID();
        restCaller.createUser(name1, UserType.QUALIFIER);

        long qualificationSession = restCaller.joinQualificationSession(name1, null, LOCATION_CODE);


        //StompSession.Subscription subscribe = stompSession.subscribe("/topic/notifications/" + qualificationSession, clientSocketStompSessionHandler);
        StompSession.Subscription subscribe = stompSession.subscribe("/topic/notifications/"+LOCATION_CODE, clientSocketStompSessionHandler);

        for (int position = 1; position <= 10; position++) {
            restCaller.sendImage(position, LOCATION_CODE);
        }


        Mockito.verify(stompSessionHandler,timeout(10000L).times(10)).handleFrame(Mockito.any(),objectArgumentCaptor.capture());

        List<Object> allValues = objectArgumentCaptor.getAllValues();
        Assertions.assertEquals(10,allValues.size());
        int index=1;
        for (Object value : allValues) {
            Assertions.assertNotNull(value);
            JobNotificationOutput jobNotificationOutput= (JobNotificationOutput) value;
            Assertions.assertEquals(index,jobNotificationOutput.getPosition());
            index++;
        }
        subscribe.unsubscribe();
        restCaller.endSession(LOCATION_CODE);
    }



}
