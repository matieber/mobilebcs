package com.mobilebcs.domain;

import com.mobilebcs.controller.user.User;
import com.mobilebcs.controller.user.UserType;
import org.springframework.stereotype.Service;

import javax.sql.DataSource;

@Service
public class UserLookupService {

    private DataSource dataSource;

    public UserLookupService(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    public User lookup(String name) {
        User user = null;
        if(name.equals("qualifier1")||name.equals("qualifier2")||name.equals("qualifier3")) {
            user = new User(name, UserType.QUALIFIER);
        }
        return user;
    }
}
