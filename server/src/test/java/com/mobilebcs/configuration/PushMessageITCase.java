package com.mobilebcs.configuration;

import com.mobilebcs.domain.NextCaravanMessage;
import org.apache.activemq.artemis.jms.client.ActiveMQConnectionFactory;
import org.junit.jupiter.api.Disabled;
import org.junit.jupiter.api.Test;
import org.springframework.jms.connection.CachingConnectionFactory;
import org.springframework.jms.core.JmsTemplate;
import org.springframework.jms.support.converter.MappingJackson2MessageConverter;
import org.springframework.jms.support.converter.MessageType;

import javax.jms.JMSException;

@Disabled
public class PushMessageITCase {


    @Test
    public void testTopicSubsriptionName() throws InterruptedException, JMSException {
        Integer position1 = 1;
        JmsTemplate jmsTemplate= create();
        jmsTemplate.convertAndSend("image.topic",new NextCaravanMessage(position1));
        Integer position2 = 2;
        jmsTemplate.convertAndSend("image.topic",new NextCaravanMessage(position2));


    }


    private JmsTemplate create() throws JMSException {
            var activeMQConnectionFactory = new ActiveMQConnectionFactory();
            activeMQConnectionFactory.setBrokerURL("tcp://localhost:61616");
            activeMQConnectionFactory.setUser("admin");
            activeMQConnectionFactory.setPassword("admin");

        JmsTemplate jmsTemplate = new JmsTemplate(new CachingConnectionFactory(activeMQConnectionFactory));

        jmsTemplate.setPubSubDomain(true);

        MappingJackson2MessageConverter converter = new MappingJackson2MessageConverter();
        converter.setTargetType(MessageType.TEXT);
        converter.setTypeIdPropertyName("_type");

        jmsTemplate.setMessageConverter(converter);
        return jmsTemplate;
    }


}
