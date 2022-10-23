package com.mobilebcs.domain.user;

import com.mobilebcs.controller.user.UserRequest;
import com.mobilebcs.controller.user.UserType;
import com.mobilebcs.domain.exception.InvalidRequestExeption;
import com.mobilebcs.domain.exception.DuplicatedUsernameException;
import org.springframework.stereotype.Service;

import java.sql.SQLException;

@Service
public class UserCreatorService {

    private final UserRepository userRepository;

    public UserCreatorService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    public void create(UserRequest userRequest) throws SQLException, DuplicatedUsernameException, InvalidRequestExeption {
        UserType userType = UserType.valueFrom(userRequest.getUserType());
        if(userType==null){
            throw new InvalidRequestExeption("El tipo de usuario es incorrecto");
        }
        userRepository.add(new UserEntity(userRequest.userName,userType.name()));
    }
}
