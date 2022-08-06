package com.mobilebcs.domain;

import com.mobilebcs.configuration.PublisherFactory;
import com.mobilebcs.controller.user.User;
import org.springframework.stereotype.Service;

@Service
public class UserStarterService {

    private final UserLookupService userLookupService;
    private final PublisherFactory publisherFactory;

    public UserStarterService(UserLookupService userLookupService, PublisherFactory publisherFactory) {
        this.userLookupService = userLookupService;
        this.publisherFactory = publisherFactory;
    }

    public User startUserSession(String name) throws UserNonexistentException {
        User user=userLookupService.lookup(name);
        if(user!=null){
            publisherFactory.addPublisher(user);
        }else{
            throw new UserNonexistentException("Usuario con nombre "+name+" no existe");
        }
        return user;
    }
}
