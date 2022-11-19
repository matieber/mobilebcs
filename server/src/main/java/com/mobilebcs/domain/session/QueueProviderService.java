package com.mobilebcs.domain.session;

import com.google.common.collect.Sets;
import com.mobilebcs.domain.exception.UserNonexistentException;
import com.mobilebcs.domain.user.User;
import com.mobilebcs.domain.user.UserLookupService;
import com.mobilebcs.domain.user.UserQueue;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.util.HashSet;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentMap;

@Service
public class QueueProviderService {

    private static final Logger LOG = LoggerFactory.getLogger(QueueProviderService.class);
    private final QualificationSessionService qualificationSessionService;

    private final UserLookupService userLookupService;
    private final UserQualificationSessionRepository userQualificationSessionRepository;
    private final ConcurrentHashMap<Long, ConcurrentHashMap<String, UserQueue>> queueBySession;


    public QueueProviderService(QualificationSessionService qualificationSessionService, UserLookupService userLookupService, UserQualificationSessionRepository userQualificationSessionRepository) {
        this.qualificationSessionService = qualificationSessionService;
        this.userLookupService = userLookupService;
        this.userQualificationSessionRepository = userQualificationSessionRepository;
        queueBySession = new ConcurrentHashMap<>();

    }

    public Set<UserQueue> getQueues(String locationCode) {
        Long qualificationSessionId = userQualificationSessionRepository.getQualificationSessionByLocation(locationCode);
        HashSet<UserQueue> userQueues = new HashSet<>();
        if (qualificationSessionId == null) {
            LOG.warn("There are not qualification sessión active for location code " + locationCode);
        } else {
            ConcurrentMap<String, UserQueue> elements = queueBySession.get(qualificationSessionId);

            if (elements != null) {
                return Sets.newHashSet(elements.values());
            }
        }
        return userQueues;
    }

    public void registerListener(long qualificationSessionId, User user) {
        userQualificationSessionRepository.associate(user.getUsername(), qualificationSessionId);
        queueBySession.putIfAbsent(qualificationSessionId, new ConcurrentHashMap<>());
        String queueName = qualificationSessionId + "-" + user.getUsername();
        UserQueue userQueue = new UserQueue(queueName, user);
        queueBySession.get(qualificationSessionId).put(user.getUsername(), userQueue);

    }

    public UserQueue get(String userName) throws UserNonexistentException {

        Long qualificationSessionId = userQualificationSessionRepository.getQualificationSessionByUser(userName);
        if (qualificationSessionId != null) {
            ConcurrentHashMap<String, UserQueue> userQueues = queueBySession.get(qualificationSessionId);
            if (userQueues != null) {
                UserQueue userQueue = userQueues.get(userName);
                if (userQueue != null) {
                    return userQueue;
                }
            }
        }
        validateUserExistence(userName);
        throw new RuntimeException("Error interno");

    }

    private void validateUserExistence(String userName) throws UserNonexistentException {
        User user = userLookupService.lookup(userName);
        if (user == null) {
            throw new UserNonexistentException("Usuario " + userName + " no existe");
        }
    }
}
