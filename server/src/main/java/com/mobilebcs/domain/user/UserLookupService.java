package com.mobilebcs.domain.user;

import com.mobilebcs.controller.user.UserType;
import org.springframework.stereotype.Service;

@Service
public class UserLookupService {

    private final UserRepository userRepository;

    public UserLookupService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    public User lookup(String name) {
        UserEntity user = userRepository.get(name);
        if (user != null) {
            return new User(user.getUserName(), UserType.valueFrom(user.getType()));
        } else {
            return null;
        }
    }
}
