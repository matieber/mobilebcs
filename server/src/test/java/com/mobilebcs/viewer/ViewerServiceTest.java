package com.mobilebcs.viewer;

import static org.junit.jupiter.api.Assertions.assertNotNull;

import com.mobilebcs.domain.jobnotification.JobNotificationOutput;
import com.mobilebcs.domain.viewer.ViewerInfo;
import com.mobilebcs.domain.viewer.ViewerPerLocation;
import com.mobilebcs.domain.viewer.ViewerService;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.stream.Collectors;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.ArgumentMatcher;
import org.mockito.Captor;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.mockito.internal.verification.Times;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.messaging.simp.SimpMessagingTemplate;
@ExtendWith(MockitoExtension.class)
public class ViewerServiceTest {

    private ViewerService viewerService;

    @Mock
    private SimpMessagingTemplate simpMessagingTemplate;

    @BeforeEach
    public void init(){
        viewerService=new ViewerService(simpMessagingTemplate);
    }

    @Test
    public void testViewerAddAndRemoved() throws InterruptedException {
        UUID session1 = UUID.randomUUID();
        UUID session2 = UUID.randomUUID();
        UUID session3 = UUID.randomUUID();
        UUID session4 = UUID.randomUUID();
        UUID session5 = UUID.randomUUID();
        UUID session6 = UUID.randomUUID();
        UUID session7 = UUID.randomUUID();
        UUID session8 = UUID.randomUUID();
        UUID session9 = UUID.randomUUID();
        String location1 = "LOCATION1";
        String location2 = "LOCATION2";
        String location3 = "LOCATION3";

        ExecutorService executorService = Executors.newFixedThreadPool(9);
        ViewerInfo viewerInfo1=new ViewerInfo(session1.toString(),location1,"NAME1");
        ViewerInfo viewerInfo2=new ViewerInfo(session2.toString(),location1,"NAME2");
        ViewerInfo viewerInfo3=new ViewerInfo(session3.toString(),location2,"NAME3");
        ViewerInfo viewerInfo4=new ViewerInfo(session4.toString(),location2,"NAME4");
        ViewerInfo viewerInfo5=new ViewerInfo(session5.toString(),location3,"NAME5");
        ViewerInfo viewerInfo6=new ViewerInfo(session6.toString(),location3,"NAME6");
        ViewerInfo viewerInfo7=new ViewerInfo(session7.toString(),location1,"NAME7");
        ViewerInfo viewerInfo8=new ViewerInfo(session8.toString(),location2,"NAME8");
        ViewerInfo viewerInfo9=new ViewerInfo(session9.toString(),location3,"NAME9");


        //test add
        executorService.submit(()->viewerService.addViewer(viewerInfo1));
        executorService.submit(()->viewerService.addViewer(viewerInfo2));
        executorService.submit(()->viewerService.addViewer(viewerInfo3));
        executorService.submit(()->viewerService.addViewer(viewerInfo4));
        executorService.submit(()->viewerService.addViewer(viewerInfo5));
        executorService.submit(()->viewerService.addViewer(viewerInfo6));
        executorService.submit(()->viewerService.addViewer(viewerInfo7));
        executorService.submit(()->viewerService.addViewer(viewerInfo8));
        executorService.submit(()->viewerService.addViewer(viewerInfo9));

        Thread.sleep(1000);

        testSend(location1, List.of(viewerInfo1, viewerInfo2, viewerInfo7));
        testSend(location2, List.of(viewerInfo3, viewerInfo4, viewerInfo8));
        testSend(location3, List.of(viewerInfo5, viewerInfo6, viewerInfo9));

        Mockito.reset(simpMessagingTemplate);

        // test removed

        executorService.submit(()->viewerService.removeViewer(viewerInfo1.getSessionId()));
        executorService.submit(()->viewerService.removeViewer(viewerInfo3.getSessionId()));
        executorService.submit(()->viewerService.removeViewer(viewerInfo5.getSessionId()));
        Thread.sleep(1000);

        testSend(location1, List.of(viewerInfo2, viewerInfo7));
        testSend(location2, List.of(viewerInfo4, viewerInfo8));
        testSend(location3, List.of(viewerInfo6, viewerInfo9));

        Mockito.reset(simpMessagingTemplate);

        executorService.submit(()->viewerService.removeViewer(viewerInfo2.getSessionId()));
        executorService.submit(()->viewerService.removeViewer(viewerInfo4.getSessionId()));
        executorService.submit(()->viewerService.removeViewer(viewerInfo6.getSessionId()));
        executorService.submit(()->viewerService.removeViewer(viewerInfo7.getSessionId()));
        executorService.submit(()->viewerService.removeViewer(viewerInfo8.getSessionId()));
        executorService.submit(()->viewerService.removeViewer(viewerInfo9.getSessionId()));
        Thread.sleep(1000);

        ViewerPerLocation set1 = viewerService.getViewerByLocation(location1);
        Assertions.assertNotNull(set1);
        Assertions.assertFalse(set1.send(new JobNotificationOutput(2,new ArrayList<>())));
        ViewerPerLocation set2 = viewerService.getViewerByLocation(location2);
        Assertions.assertNotNull(set2);
        Assertions.assertFalse(set2.send(new JobNotificationOutput(2,new ArrayList<>())));
        ViewerPerLocation set3 = viewerService.getViewerByLocation(location3);
        Assertions.assertNotNull(set3);
        Assertions.assertFalse(set3.send(new JobNotificationOutput(2,new ArrayList<>())));

    }

    private void testSend(String location1, List<ViewerInfo> viewerInfos) throws InterruptedException {
        List<ViewerInfo> expectedLocation1 = viewerInfos;
        ViewerPerLocation set1 = viewerService.getViewerByLocation(location1);
        Mockito.doNothing().when(simpMessagingTemplate).convertAndSend(Mockito.any(),Mockito.any(JobNotificationOutput.class));
        boolean sent = set1.send(new JobNotificationOutput(1, new ArrayList<>()));
        Assertions.assertTrue(sent);
        assertViewers(expectedLocation1);
    }

    private void assertViewers(List<ViewerInfo> expectedLocation) {
        List<String> destinations =
            expectedLocation.stream().map(expectedViewerInfo -> "/topic/notifications/" + expectedViewerInfo.getLocationCode() + "/" + expectedViewerInfo.getName())
                .collect(Collectors.toList());
        for(String destination: destinations){
            Mockito.verify(simpMessagingTemplate).convertAndSend(Mockito.eq(destination),
                Mockito.any(JobNotificationOutput.class));
        }
        Mockito.verifyNoMoreInteractions(simpMessagingTemplate);


    }
}
