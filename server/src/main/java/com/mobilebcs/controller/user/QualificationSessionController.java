package com.mobilebcs.controller.user;

import com.mobilebcs.domain.exception.DuplicatedSessionForLocationException;
import com.mobilebcs.domain.exception.InvalidLocalizationException;
import com.mobilebcs.domain.exception.InvalidOperationException;
import com.mobilebcs.domain.exception.UserNonexistentException;
import com.mobilebcs.domain.user.UserCreatorService;
import com.mobilebcs.domain.user.UserQualificationSessionService;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.sql.SQLException;


@RestController
@RequestMapping("/location")
public class QualificationSessionController {

    private final UserQualificationSessionService startUserSession;

    public QualificationSessionController(UserQualificationSessionService startUserSession) {
        this.startUserSession = startUserSession;

    }

    @PostMapping(value = "/{locationCode}/user/{name}/qualificationSession", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<UserResponse> startQualificationSession(@PathVariable("name") String name,@PathVariable("locationCode") String locationCode) throws UserNonexistentException, InvalidOperationException, SQLException, DuplicatedSessionForLocationException, InvalidLocalizationException {
        UserResponse userResponse= startUserSession.startQualificationSession(name,locationCode);
        return ResponseEntity.ok(userResponse);
    }

    @DeleteMapping(value = "/{locationCode}/qualificationSession", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<Void> endQualificationSession(@PathVariable(name = "locationCode") String locationCode) throws InvalidLocalizationException, SQLException {
        startUserSession.endQualificationSession(locationCode);
        return ResponseEntity.noContent().build();
    }

    @PutMapping(value = "/{locationCode}/user/{name}/qualificationSession/{qualificationSession}", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<UserResponse> joinQualificationSession(@PathVariable("name") String name, @PathVariable(name = "qualificationSession") long qualificationSession) throws UserNonexistentException, InvalidOperationException {
        UserResponse userResponse= startUserSession.joinQualificationSession(name,qualificationSession);
        return ResponseEntity.ok(userResponse);
    }


}
