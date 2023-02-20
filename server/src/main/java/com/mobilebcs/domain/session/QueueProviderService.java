package com.mobilebcs.domain.session;

import com.mobilebcs.domain.exception.UserNonexistentException;
import com.mobilebcs.domain.user.User;
import com.mobilebcs.domain.user.UserLookupService;
import com.mobilebcs.domain.user.UserQueue;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.util.HashSet;
import java.util.Set;

@Service
public class QueueProviderService {

    private static final Logger LOG = LoggerFactory.getLogger(QueueProviderService.class);
    private final QualificationSessionService qualificationSessionService;

    private final UserLookupService userLookupService;
    private final UserQualificationSessionRepository userQualificationSessionRepository;

    private final QueueSessionService queueSessionService;


    public QueueProviderService(QualificationSessionService qualificationSessionService, UserLookupService userLookupService, UserQualificationSessionRepository userQualificationSessionRepository, QueueSessionService queueSessionService) {
        this.qualificationSessionService = qualificationSessionService;
        this.userLookupService = userLookupService;
        this.userQualificationSessionRepository = userQualificationSessionRepository;
        this.queueSessionService = queueSessionService;
    }

    public Set<UserQueue> getQueues(String locationCode) {
        Long qualificationSessionId = userQualificationSessionRepository.getQualificationSessionByLocation(locationCode);
        HashSet<UserQueue> userQueues = new HashSet<>();
        if (qualificationSessionId == null) {
            LOG.warn("There are not qualification sesión active for location code " + locationCode);
        } else {
            return queueSessionService.getQueues(qualificationSessionId);


        }
        return userQueues;
    }

    public void registerListener(long qualificationSessionId, User user) {
        userQualificationSessionRepository.associate(user.getUsername(), qualificationSessionId);
    }

    public UserQueue get(String userName) throws UserNonexistentException {

        Long qualificationSessionId = userQualificationSessionRepository.getQualificationSessionByUser(userName);
        if (qualificationSessionId != null) {
            return queueSessionService.getQueues(qualificationSessionId, userName);

        }
        validateUserExistence(userName);
        throw new RuntimeException("Usuario no está asociado a ninguna sesión de calificación");

    }

    private void validateUserExistence(String userName) throws UserNonexistentException {
        User user = userLookupService.lookup(userName);
        if (user == null) {
            throw new UserNonexistentException("Usuario " + userName + " no existe");
        }
    }

    public Long getQualificationSession(String locationCode) {
        return userQualificationSessionRepository.getQualificationSessionByLocation(locationCode);
    }
}
