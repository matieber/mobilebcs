package com.mobilebcs.domain;

import com.mobilebcs.controller.user.User;
import org.springframework.stereotype.Repository;

import javax.sql.DataSource;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

public class UserRepository {

    private final Map<String,User> users=new ConcurrentHashMap<>();


    public User get(String name) {
        return users.get(name);
    }

    public void add(User user) {
        users.put(user.getUsername(),user);
    }
}
