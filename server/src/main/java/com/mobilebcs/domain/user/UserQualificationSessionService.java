package com.mobilebcs.domain.user;

import com.mobilebcs.controller.user.UserResponse;
import com.mobilebcs.domain.exception.DuplicatedSessionForLocationException;
import com.mobilebcs.domain.exception.InvalidLocalizationException;
import com.mobilebcs.domain.exception.InvalidOperationException;
import com.mobilebcs.domain.exception.UserNonexistentException;
import com.mobilebcs.domain.qualifier.QualifierQueueFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.sql.SQLException;


@Service
public class UserQualificationSessionService {


    private final QualifierQueueFactory publisherFactory;

    private final com.mobilebcs.domain.session.QualificationSessionService qualificationSessionService;

    public UserQualificationSessionService(QualifierQueueFactory publisherFactory, com.mobilebcs.domain.session.QualificationSessionService qualificationSessionService) {
        this.publisherFactory = publisherFactory;
        this.qualificationSessionService = qualificationSessionService;
    }

    @Transactional(rollbackFor = Exception.class)
    public UserResponse startQualificationSession(String username, String locationCode) throws UserNonexistentException, InvalidOperationException, SQLException, DuplicatedSessionForLocationException, InvalidLocalizationException {

        long qualificationSession = qualificationSessionService.startNewSession(locationCode);

        User user = publisherFactory.addQualifier(username, qualificationSession);
        return new UserResponse(user.getUsername(), user.getUserType(), qualificationSession);
    }

    public UserResponse joinQualificationSession(String name, Long qualificationSession) throws UserNonexistentException, InvalidOperationException {

        User user = publisherFactory.addQualifier(name, qualificationSession);
        return new UserResponse(user.getUsername(), user.getUserType(), qualificationSession);
    }

    public void endQualificationSession(String locationCode) throws InvalidLocalizationException, SQLException {
        qualificationSessionService.endQualificationSession(locationCode);
    }
}
