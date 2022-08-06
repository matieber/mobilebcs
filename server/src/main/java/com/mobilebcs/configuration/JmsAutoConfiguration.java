package com.mobilebcs.configuration;


import org.apache.activemq.artemis.jms.client.ActiveMQConnectionFactory;
import org.reactivestreams.Publisher;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.integration.dsl.IntegrationFlows;
import org.springframework.integration.dsl.MessageChannels;
import org.springframework.integration.jms.dsl.Jms;
import org.springframework.jms.annotation.EnableJms;
import org.springframework.jms.connection.CachingConnectionFactory;
import org.springframework.jms.listener.DefaultMessageListenerContainer;
import org.springframework.jms.support.converter.MappingJackson2MessageConverter;
import org.springframework.jms.support.converter.MessageConverter;
import org.springframework.jms.support.converter.MessageType;
import org.springframework.messaging.Message;

import javax.jms.ConnectionFactory;
import javax.jms.JMSException;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

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


	@Bean
	public Map<String,Publisher<Message<String>>> publishers(Publisher<Message<String>> jmsReactiveSource1,
	Publisher<Message<String>> jmsReactiveSource2, Publisher<Message<String>> jmsReactiveSource3){

		return new ConcurrentHashMap<>(Map.of("calificator1", jmsReactiveSource1, "calificator2", jmsReactiveSource2,
				"calificator3", jmsReactiveSource3));
	}
	@Bean
	public Publisher<Message<String>> jmsReactiveSource1(ConnectionFactory connectionFactory) {
		return IntegrationFlows
				.from(Jms.messageDrivenChannelAdapter(container(connectionFactory, "calificator1")))
				.channel(MessageChannels.queue())
				.log()
				.toReactivePublisher();
	}

	@Bean
	public Publisher<Message<String>> jmsReactiveSource3(ConnectionFactory connectionFactory) {
		return IntegrationFlows
				.from(Jms.messageDrivenChannelAdapter(container(connectionFactory, "calificator3")))
				.channel(MessageChannels.queue())
				.log()
				.toReactivePublisher();
	}

	@Bean
	public Publisher<Message<String>> jmsReactiveSource2(ConnectionFactory connectionFactory) {
		return IntegrationFlows
				.from(Jms.messageDrivenChannelAdapter(container(connectionFactory, "calificator2")))
				.channel(MessageChannels.queue())
				.log()
				.toReactivePublisher();
	}

	private DefaultMessageListenerContainer container(ConnectionFactory connectionFactory, String name) {
		DefaultMessageListenerContainer container = new DefaultMessageListenerContainer();
		container.setPubSubDomain(true);
		container.setSubscriptionName(name);
		container.setSubscriptionShared(true);
		container.setSubscriptionDurable(true);
		container.setDestinationName("image.topic");
		container.setConnectionFactory(connectionFactory);
		return container;
	}

	@Bean // Serialize message content to json using TextMessage
	public MessageConverter jacksonJmsMessageConverter() {
		MappingJackson2MessageConverter converter = new MappingJackson2MessageConverter();
		converter.setTargetType(MessageType.TEXT);
		converter.setTypeIdPropertyName("_type");
		return converter;
	}


}


