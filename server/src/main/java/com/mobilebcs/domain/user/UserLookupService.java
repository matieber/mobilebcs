package com.mobilebcs.domain.user;

import com.mobilebcs.controller.user.UserType;
import com.mobilebcs.domain.exception.UserNonexistentException;
import org.springframework.stereotype.Service;

@Service
public class UserLookupService {

    private final UserRepository userRepository;

    public UserLookupService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    public User lookup(String name) throws UserNonexistentException {
        UserEntity user = userRepository.get(name);
        if(user==null){
            throw new UserNonexistentException("Usuario "+name+" no existe");
        }
        return new User(user.getUserName(),UserType.valueFrom(user.getType()));
    }
}
