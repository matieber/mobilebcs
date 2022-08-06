package com.mobilebcs.domain;

import com.mobilebcs.controller.user.User;
import org.springframework.stereotype.Service;

@Service
public class UserLookupService {
    public User lookup(String name) {
        User user = null;
        if(name.equals("calificator1")||name.equals("calificator2")||name.equals("calificator3")) {
            user = new User(name);
        }
        return user;
    }
}
