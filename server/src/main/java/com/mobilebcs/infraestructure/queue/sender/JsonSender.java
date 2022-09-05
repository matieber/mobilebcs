package com.mobilebcs.infraestructure.queue.sender;

import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.jms.core.JmsTemplate;
import org.springframework.stereotype.Component;

@Component
public class JsonSender {

    private final JmsTemplate jmsTemplate;

  public JsonSender(JmsTemplate jmsTemplate){
      this.jmsTemplate=jmsTemplate;
  }

   public void send(){
      //msTemplate.send();
   }


}
