package com.mobilebcs.domain.images;

import com.mobilebcs.domain.jobnotification.JobNotificationOutput;
import com.mobilebcs.domain.qualifier.NextCaravanMessage;
import com.mobilebcs.domain.session.QueueProviderService;
import com.mobilebcs.domain.user.UserQueue;
import com.mobilebcs.domain.user.UserRepository;
import com.mobilebcs.domain.viewer.ViewerPerLocation;
import com.mobilebcs.domain.viewer.ViewerService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.jms.annotation.JmsListener;
import org.springframework.jms.core.JmsTemplate;
import org.springframework.stereotype.Component;

import javax.jms.JMSException;
import javax.jms.Message;
import java.time.Instant;
import java.time.LocalDateTime;
import java.util.Set;

@Component
public class ImagesListener {

    private final JmsTemplate jmsTemplate;

    private final QueueProviderService queueProviderService;
    private static final Logger LOG = LoggerFactory.getLogger(ImagesListener.class);


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

        JobNotificationOutput jobNotificationOutput = new JobNotificationOutput(nextCaravanMessage.getSetCode(),nextCaravanMessage.getPosition(),nextCaravanMessage.getImages(),
                nextCaravanMessage.getIdentification());

        sendToViewer(locationCode, jobNotificationOutput);

    }

    private void sendToViewer(String locationCode, JobNotificationOutput jobNotificationOutput) throws InterruptedException {
        ViewerPerLocation viewerByLocation = viewerService.getViewerByLocation(locationCode);
        if(viewerByLocation!=null) {


            jobNotificationOutput.setStartTime(Instant.now());
            LOG.info("Envio al observador: ",jobNotificationOutput.getStartTime().toString());
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
