package com.mobilebcs.domain.user;

import com.mobilebcs.controller.user.UserResponse;
import com.mobilebcs.controller.user.UserType;
import com.mobilebcs.domain.exception.DuplicatedSessionForLocationException;
import com.mobilebcs.domain.exception.InvalidLocalizationException;
import com.mobilebcs.domain.exception.InvalidOperationException;
import com.mobilebcs.domain.exception.SessionNotStartedException;
import com.mobilebcs.domain.exception.UserNonexistentException;
import com.mobilebcs.domain.qualifier.QualifierQueueFactory;
import com.mobilebcs.domain.session.QualificationSessionService;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.sql.SQLException;
import java.util.HashMap;


@Service
public class UserQualificationSessionService {

    private static final String SELECT = "SELECT QUALIFICATION_SESSION_ID FROM USER_LOCATION_QUALIFICATION_SESSION WHERE USER_ID = :userId";

    private final QualifierQueueFactory publisherFactory;

    private final QualificationSessionService qualificationSessionService;

    private final UserRepository userRepository;;

    private final NamedParameterJdbcTemplate namedParameterJdbcTemplate;

    public UserQualificationSessionService(QualifierQueueFactory publisherFactory, QualificationSessionService qualificationSessionService, UserRepository userRepository, NamedParameterJdbcTemplate namedParameterJdbcTemplate) {
        this.publisherFactory = publisherFactory;
        this.qualificationSessionService = qualificationSessionService;
        this.userRepository = userRepository;
        this.namedParameterJdbcTemplate = namedParameterJdbcTemplate;
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

    public void endQualificationSession(String locationCode) throws InvalidLocalizationException, SQLException, SessionNotStartedException {
        qualificationSessionService.endQualificationSession(locationCode);
    }

    public UserQualificationSession getQualificationSessionByUser(String name) throws UserNonexistentException, InvalidOperationException {
        UserEntity user = userRepository.get(name);
        if (user == null) {
            throw new UserNonexistentException("Usuario " + name + " no existe");
        }
        if (!UserType.QUALIFIER.name().equals(user.getType())) {
            throw new InvalidOperationException("El usuario " + name + " debe ser calificador para poder calificar");
        }

        HashMap<String, Object> paramMap = new HashMap<>();
        paramMap.put("userId", user.getId());
        Long qualificationSessionId = namedParameterJdbcTemplate.queryForObject(SELECT, paramMap, Long.class);
        if(qualificationSessionId==null){
            throw new InvalidOperationException("El usuario "+qualificationSessionId+" no está asignado a una sesión de calificación o la misma no está activa");
        }
        return new UserQualificationSession(user.getId(),qualificationSessionId);

    }
}
