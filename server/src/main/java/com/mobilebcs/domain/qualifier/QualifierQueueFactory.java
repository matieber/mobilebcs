package com.mobilebcs.domain.qualifier;


import com.mobilebcs.controller.user.UserType;
import com.mobilebcs.domain.exception.InvalidOperationException;
import com.mobilebcs.domain.exception.UserNonexistentException;
import com.mobilebcs.domain.images.ImagesListener;
import com.mobilebcs.domain.session.QueueProviderService;
import com.mobilebcs.domain.user.User;
import com.mobilebcs.domain.user.UserLookupService;
import com.mobilebcs.domain.user.UserQueue;
import org.springframework.stereotype.Component;


@Component
public class QualifierQueueFactory {


    private final UserLookupService userLookupService;

    private final ImagesListener imagesListener;


    private final QueueProviderService queueProviderService;

    public QualifierQueueFactory(UserLookupService userLookupService, ImagesListener imagesListener, QueueProviderService queueProviderService) {
        this.userLookupService = userLookupService;
        this.imagesListener = imagesListener;

        this.queueProviderService = queueProviderService;
    }


    public User addQualifier(String userName, long qualificationSession) throws UserNonexistentException, InvalidOperationException {
        User user = userLookupService.lookup(userName);
        if (user == null) {
            throw new UserNonexistentException("Usuario con nombre " + userName + " no existe");
        }
        if (!UserType.QUALIFIER.equals(user.getUserType())) {
            throw new InvalidOperationException("El usuario " + userName + " debe ser calificador para poder calificar");
        }

        queueProviderService.registerListener(qualificationSession, user);
        return user;
    }

    public UserQueue getQueue(String userName) throws UserNonexistentException, InvalidOperationException {
        User user = userLookupService.lookup(userName);
        if (user == null) {
            throw new UserNonexistentException("Usuario " + userName + " no existe");
        }
        if (!UserType.QUALIFIER.equals(user.getUserType())) {
            throw new InvalidOperationException("El usuario " + userName + " debe ser calificador para poder calificar");
        }
        UserQueue userQueue = queueProviderService.get(userName);
        if (userQueue == null) {
            throw new InvalidOperationException("Usuario con nombre " + userName + " no pertenece a ninguna sesión de calificación");
        }
        return userQueue;
    }


}
