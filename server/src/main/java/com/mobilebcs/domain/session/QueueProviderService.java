package com.mobilebcs.domain.session;

import com.google.common.collect.Sets;
import com.mobilebcs.domain.exception.UserNonexistentException;
import com.mobilebcs.domain.user.User;
import com.mobilebcs.domain.user.UserLookupService;
import com.mobilebcs.domain.user.UserQueue;
import org.apache.activemq.artemis.utils.collections.ConcurrentHashSet;
import org.springframework.stereotype.Service;

import java.util.HashSet;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class QueueProviderService {
    private final QualificationSessionService qualificationSessionService;

    private final UserLookupService userLookupService;
    private final UserQualificationSessionRepository userQualificationSessionRepository;
    private final ConcurrentHashMap<Long,ConcurrentHashSet<UserQueue>> queueBySession;


    public QueueProviderService(QualificationSessionService qualificationSessionService, UserLookupService userLookupService, UserQualificationSessionRepository userQualificationSessionRepository){
        this.qualificationSessionService = qualificationSessionService;
        this.userLookupService = userLookupService;
        this.userQualificationSessionRepository = userQualificationSessionRepository;
        queueBySession = new ConcurrentHashMap<>();

    }

    public Set<UserQueue> getQueues(String locationCode){
        ConcurrentHashSet<UserQueue> elements = queueBySession.get(locationCode);
        HashSet<UserQueue> userQueues = new HashSet<>();
        if(elements!=null){
            return Sets.newHashSet(elements);
        }
        return userQueues;
    }

    public void registerListener(long qualificationSessionId, User user) {
        userQualificationSessionRepository.associate(user.getUsername(),qualificationSessionId);
        queueBySession.putIfAbsent(qualificationSessionId, new ConcurrentHashSet<>());
        String queueName = qualificationSessionId +"-"+user.getUsername();
        UserQueue userQueue = new UserQueue(queueName, user);
        queueBySession.get(qualificationSessionId).add(userQueue);

    }

    public UserQueue get(String userName) throws UserNonexistentException {
        User user = userLookupService.lookup(userName);
        Long qualificationSessionId=userQualificationSessionRepository.getQualificationSession(userName);
        if(qualificationSessionId!=null){
            String queueName="";
            return new UserQueue(queueName,user);
        }
        return null;

    }
}
