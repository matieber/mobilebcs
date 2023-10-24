package com.mobilebcs.domain.user;

import com.mobilebcs.controller.user.UserResponse;
import com.mobilebcs.domain.exception.UserNonexistentException;
import com.mobilebcs.domain.session.QualificationSessionService;
import com.mobilebcs.domain.session.UserQualificationSessionRepository;
import org.springframework.stereotype.Service;


@Service
public class UserSessionService {


    private final UserQualificationSessionRepository userQualificationSessionRepository;
    private final UserLookupService userLookupService;
    private final QualificationSessionService qualificationSessionService;

    public UserSessionService(UserQualificationSessionRepository userQualificationSessionRepository, UserLookupService userLookupService, QualificationSessionService qualificationSessionService) {
        this.userQualificationSessionRepository = userQualificationSessionRepository;
        this.userLookupService = userLookupService;
        this.qualificationSessionService = qualificationSessionService;
    }

    public UserResponse login(String name) throws UserNonexistentException {
        User user = userLookupService.lookup(name);
        if (user == null) {
            throw new UserNonexistentException("Usuario " + name + " no existe");
        }
        Long qualificationSession = userQualificationSessionRepository.getQualificationSessionByUser(name);
        return new UserResponse(user.getUsername(), user.getUserType(), qualificationSession);
    }


}
