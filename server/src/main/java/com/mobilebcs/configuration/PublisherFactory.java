package com.mobilebcs.configuration;

import com.mobilebcs.controller.user.User;
import org.reactivestreams.Publisher;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.integration.dsl.IntegrationFlows;
import org.springframework.integration.dsl.MessageChannels;
import org.springframework.integration.jms.dsl.Jms;
import org.springframework.jms.listener.DefaultMessageListenerContainer;
import org.springframework.messaging.Message;
import org.springframework.stereotype.Component;

import javax.jms.ConnectionFactory;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Component
public class PublisherFactory {


    private final ConnectionFactory connectionFactory;
    private final String topicName;
    private final Map<String,Publisher<Message<String>>> publishers;

    public PublisherFactory(ConnectionFactory connectionFactory,@Value("${topic.name}") String topicName,@Qualifier("publishers") Map<String,Publisher<Message<String>>> publishers) {
        this.publishers =publishers;
        this.connectionFactory=connectionFactory;
        this.topicName=topicName;
    }

    public Publisher<Message<String>> getPublisherBy(String name){
        return publishers.get(name);
    }

    public void addPublisher(User user){
      //TODO: No se agrega el usuario porque los publisher están definidos desde el start up

    }

    public Publisher<Message<String>> buildPublisher( String name) {
        return IntegrationFlows
                .from(Jms.messageDrivenChannelAdapter(container(connectionFactory, name)))
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
        container.setDestinationName(topicName);
        container.setConnectionFactory(connectionFactory);
        return container;
    }

}
