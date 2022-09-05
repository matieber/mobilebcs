package com.mobilebcs.configuration;

import com.mobilebcs.domain.NextCaravanMessage;
import org.apache.activemq.artemis.utils.collections.ConcurrentHashSet;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.jms.annotation.JmsListener;
import org.springframework.jms.config.DefaultJmsListenerContainerFactory;
import org.springframework.jms.core.JmsTemplate;
import org.springframework.jms.support.destination.DynamicDestinationResolver;
import org.springframework.stereotype.Component;

import javax.jms.ConnectionFactory;
import javax.jms.JMSException;
import javax.jms.Message;

@Component
public class ImagesListener {


    private final JmsTemplate jmsTemplate;

    private final ConcurrentHashSet<String> queues;


    public ImagesListener(JmsProperties jmsProperties, JmsTemplate jmsTemplate) {
        this.jmsTemplate=jmsTemplate;
        queues=new ConcurrentHashSet<>();
    }

    @JmsListener(destination = "${images.queue.name}", containerFactory="jmsListenerContainerFactory" )
    public void listener(Message message) throws JMSException {
        if(!queues.isEmpty()) {
            for(String queueName:queues) {
                try {
                    NextCaravanMessage nextCaravanMessage = (NextCaravanMessage) jmsTemplate.getMessageConverter().fromMessage(message);
                    jmsTemplate.convertAndSend(queueName, nextCaravanMessage);
                } catch (JMSException e) {
                    throw new RuntimeException(e);
                }
            }
            message.acknowledge();
        }
    }


    public void registerListener(String queueName) throws JMSException {
        queues.add(queueName);
    }


    private DefaultJmsListenerContainerFactory mqJmsListenerContainerFactory(ConnectionFactory connectionFactory) throws JMSException {
        DefaultJmsListenerContainerFactory factory = new DefaultJmsListenerContainerFactory();
        factory.setConnectionFactory(connectionFactory);
        factory.setDestinationResolver(new DynamicDestinationResolver());
        factory.setSubscriptionDurable(true);
        factory.setAutoStartup(true);
        factory.setConcurrency("1");
        return factory;
    }

}
