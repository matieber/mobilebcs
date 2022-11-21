package com.mobilebcs.domain.session;

import com.mobilebcs.controller.user.UserType;
import com.mobilebcs.domain.user.User;
import com.mobilebcs.domain.user.UserQueue;
import org.springframework.beans.factory.config.ConfigurableBeanFactory;
import org.springframework.context.annotation.Scope;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@Scope(value = ConfigurableBeanFactory.SCOPE_SINGLETON)
public class QueueSessionService {


    private final QueueRepository queueRepository;


    public QueueSessionService(QueueRepository queueRepository) {
        this.queueRepository = queueRepository;

    }

    private UserQueue createUserQueue(UserQueueEntity userQueue) {
        UserType userType = UserType.valueOf(userQueue.getType());
        String username = userQueue.getUserName();
        User user = new User(username, userType);
        String queueName = QueueNameBuilder.createQueueName(userQueue.getQualificationSessionId(), username);
        return new UserQueue(queueName, user);
    }


    public Set<UserQueue> getQueues(Long qualificationSessionId) {
        List<UserQueueEntity> userQueueEntities = queueRepository.getActiveUserInSessionBy(qualificationSessionId);
        return userQueueEntities.stream().map(this::createUserQueue).collect(Collectors.toSet());
    }

    public UserQueue getQueues(Long qualificationSessionId, String userName) {
        UserQueueEntity userQueueEntity = queueRepository.getActiveUserInSessionBy(qualificationSessionId, userName);
        return createUserQueue(userQueueEntity);
    }

}
