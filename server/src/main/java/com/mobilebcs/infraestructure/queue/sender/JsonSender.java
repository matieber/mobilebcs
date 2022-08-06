package com.mobilebcs.infraestructure.queue.sender;

import org.springframework.jms.core.JmsTemplate;
import org.springframework.stereotype.Component;

@Component
public class JsonSender {

    private JmsTemplate jmsTemplate;

  public JsonSender(JmsTemplate jmsTemplate){
      this.jmsTemplate=jmsTemplate;
  }

   public void send(){
      //msTemplate.send();
   }


}
