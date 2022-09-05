package com.mobilebcs.domain;

import com.mobilebcs.configuration.ImagesListener;
import com.mobilebcs.controller.user.User;
import com.mobilebcs.controller.user.UserType;
import org.springframework.stereotype.Component;

import javax.jms.JMSException;
import java.util.HashMap;
import java.util.Map;

@Component
public class QualifierQueueFactory {


    public static final String QUALIFIER_QUEUE_PREFIX = "QUALIFIER-QUEUE-";
    private final Map<String,String> queueByQualifier;

    private final UserLookupService userLookupService;

    private final ImagesListener imagesListener;

    public QualifierQueueFactory(UserLookupService userLookupService, ImagesListener imagesListener) {
        this.userLookupService = userLookupService;
        this.imagesListener = imagesListener;
        queueByQualifier =new HashMap<>();
    }


    public User addQualifier(String userName) throws UserNonexistentException, InvalidOperationException, JMSException {
        User user = userLookupService.lookup(userName);
        if(user==null){
            throw new UserNonexistentException("Usuario con nombre "+userName+" no existe");
        }
        if(!UserType.QUALIFIER.equals(user.getUserType())){
            throw new InvalidOperationException("El usuario "+userName+" debe ser calificador para poder calificar");
        }
        String queue = QUALIFIER_QUEUE_PREFIX + user.getUsername();
        queueByQualifier.put(user.getUsername(), queue);
        imagesListener.registerListener(queue);
        return user;
    }

    public UserQueue getQueue(String userName) throws UserNonexistentException, InvalidOperationException {
        User user = userLookupService.lookup(userName);
        if(user==null){
            throw new UserNonexistentException("Usuario con nombre "+userName+" no existe");
        }
        if(!UserType.QUALIFIER.equals(user.getUserType())){
            throw new InvalidOperationException("El usuario "+userName+" debe ser calificador para poder calificar");
        }
        String queueName = queueByQualifier.get(userName);
        UserQueue userQueue=null;
        if(queueName!=null){
            userQueue = new UserQueue(queueName, user);
        }else{
            throw new InvalidOperationException("Usuario con nombre "+userName+" no ha iniciado sesión");
        }
        return userQueue;
    }



}
