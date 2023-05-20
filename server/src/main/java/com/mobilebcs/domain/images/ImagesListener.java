package com.mobilebcs.domain.images;

import com.mobilebcs.domain.jobnotification.JobNotificationOutput;
import com.mobilebcs.domain.qualifier.NextCaravanMessage;
import com.mobilebcs.domain.session.QueueProviderService;
import com.mobilebcs.domain.user.UserQueue;
import com.mobilebcs.domain.viewer.ViewerInfo;
import com.mobilebcs.domain.viewer.ViewerPerLocation;
import com.mobilebcs.domain.viewer.ViewerService;
import java.util.Iterator;
import java.util.Queue;
import org.springframework.jms.annotation.JmsListener;
import org.springframework.jms.core.JmsTemplate;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Component;

import javax.jms.JMSException;
import javax.jms.Message;
import java.time.Instant;
import java.util.Set;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.TimeoutException;

@Component
public class ImagesListener {

    private final JmsTemplate jmsTemplate;

    private final QueueProviderService queueProviderService;


    private final ViewerService viewerService;

    public ImagesListener(JmsTemplate jmsTemplate, QueueProviderService queueProviderService, ViewerService viewerService) {
        this.jmsTemplate = jmsTemplate;
        this.queueProviderService = queueProviderService;
        this.viewerService = viewerService;
    }

    @JmsListener(id="image-listener",destination = "${images.queue.name}", containerFactory = "jmsListenerContainerFactory", concurrency = "1")
    public void listener(Message message) throws JMSException, InterruptedException {
        NextCaravanMessage nextCaravanMessage = (NextCaravanMessage) jmsTemplate.getMessageConverter().fromMessage(message);
        sentJobToQualifier(nextCaravanMessage);
        sentJobToViewers(nextCaravanMessage);
        message.acknowledge();
    }

    private void sentJobToViewers(NextCaravanMessage nextCaravanMessage) throws InterruptedException {
        String locationCode = nextCaravanMessage.getLocationCode();

        JobNotificationOutput jobNotificationOutput = new JobNotificationOutput(nextCaravanMessage.getPosition(),nextCaravanMessage.getImages());

        sendToViewer(locationCode, jobNotificationOutput);

    }

    private void sendToViewer(String locationCode, JobNotificationOutput jobNotificationOutput) throws InterruptedException {
        ViewerPerLocation viewerByLocation = viewerService.getViewerByLocation(locationCode);
        if(viewerByLocation!=null) {
            viewerByLocation.send(jobNotificationOutput);
        }
    }


    private void sentJobToQualifier(NextCaravanMessage nextCaravanMessage) {
        Set<UserQueue> queues = queueProviderService.getQueues(nextCaravanMessage.getLocationCode());
        for (UserQueue userQueue : queues) {
            String queueName = userQueue.getQueueName();
            jmsTemplate.convertAndSend(queueName, nextCaravanMessage);
        }
    }


}
