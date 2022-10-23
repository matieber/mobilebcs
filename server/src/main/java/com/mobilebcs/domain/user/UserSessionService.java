package com.mobilebcs.domain.user;

import com.mobilebcs.controller.user.UserRequest;
import com.mobilebcs.controller.user.UserResponse;
import com.mobilebcs.domain.exception.InvalidOperationException;
import com.mobilebcs.domain.exception.UserNonexistentException;
import com.mobilebcs.domain.session.QualificationSessionService;
import org.springframework.stereotype.Service;



@Service
public class UserSessionService {


    private final UserLookupService userLookupService;
    private final QualificationSessionService qualificationSessionService;

    public UserSessionService(UserLookupService userLookupService, QualificationSessionService qualificationSessionService) {
        this.userLookupService = userLookupService;
        this.qualificationSessionService = qualificationSessionService;
    }

    public UserResponse starUserSession(String name) throws UserNonexistentException {
        User user = userLookupService.lookup(name);

        long qualificationSession=qualificationSessionService.getQualificationSessionByUser(name);
        return new UserResponse(user.getUsername(),user.getUserType(),qualificationSession);
    }


}
