package com.mobilebcs.configuration.jms;


import org.apache.activemq.artemis.jms.client.ActiveMQConnectionFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.jms.annotation.EnableJms;
import org.springframework.jms.config.DefaultJmsListenerContainerFactory;
import org.springframework.jms.connection.CachingConnectionFactory;
import org.springframework.jms.core.JmsTemplate;
import org.springframework.jms.support.converter.MappingJackson2MessageConverter;
import org.springframework.jms.support.converter.MessageConverter;
import org.springframework.jms.support.converter.MessageType;
import org.springframework.jms.support.destination.DynamicDestinationResolver;

import javax.jms.ConnectionFactory;
import javax.jms.JMSException;
import javax.jms.Session;

@EnableJms
@Configuration
@EnableConfigurationProperties(JmsProperties.class)
public class JmsAutoConfiguration {
    private final JmsProperties jmsProperties;


    public JmsAutoConfiguration(JmsProperties jmsProperties) {
        this.jmsProperties = jmsProperties;
    }

    @Bean
    public ConnectionFactory connectionFactory() throws JMSException {
        var activeMQConnectionFactory = new ActiveMQConnectionFactory();
        activeMQConnectionFactory.setBrokerURL(jmsProperties.getBrokerUrl());
        activeMQConnectionFactory.setUser(jmsProperties.getUsername());
        activeMQConnectionFactory.setPassword(jmsProperties.getPassword());
        return new CachingConnectionFactory(activeMQConnectionFactory);
    }


    @Bean // Serialize message content to json using TextMessage
    public MessageConverter jacksonJmsMessageConverter() {
        MappingJackson2MessageConverter converter = new MappingJackson2MessageConverter();
        converter.setTargetType(MessageType.TEXT);
        converter.setTypeIdPropertyName("_type");
        return converter;
    }

    @Bean
    public JmsTemplate jmsTemplate(ConnectionFactory connectionFactory, MessageConverter jmsMessageConverter, @Value("${activemq.receive-timeout}") int receiveTimeout) throws JMSException {
        var jmsTemplate = new JmsTemplate(connectionFactory);
        jmsTemplate.setMessageConverter(jmsMessageConverter);
        jmsTemplate.setSessionAcknowledgeMode(Session.CLIENT_ACKNOWLEDGE);
        jmsTemplate.setReceiveTimeout(receiveTimeout);

        return jmsTemplate;
    }

    @Bean
    public JmsTemplate listenerQueueJmsTemplate(ConnectionFactory connectionFactory, MessageConverter jmsMessageConverter, @Value("${activemq.receive-timeout}") int receiveTimeout) throws JMSException {
        var jmsTemplate = new JmsTemplate(connectionFactory);
        jmsTemplate.setMessageConverter(jmsMessageConverter);
        jmsTemplate.setSessionAcknowledgeMode(Session.CLIENT_ACKNOWLEDGE);
        jmsTemplate.setReceiveTimeout(receiveTimeout);

        return jmsTemplate;
    }

    @Bean
    public DefaultJmsListenerContainerFactory jmsListenerContainerFactory(ConnectionFactory connectionFactory, MessageConverter jmsMessageConverter) {

        var factory = new DefaultJmsListenerContainerFactory();
        factory.setConnectionFactory(connectionFactory);
        factory.setDestinationResolver(new DynamicDestinationResolver());
        factory.setConcurrency("1");
        factory.setSessionAcknowledgeMode(Session.CLIENT_ACKNOWLEDGE);
        factory.setMessageConverter(jmsMessageConverter);

        return factory;
    }

}


