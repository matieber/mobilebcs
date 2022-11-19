package com.mobilebcs.domain.session;

import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.HashMap;

@Repository
public class UserQualificationSessionRepository {

    private final static String INSERT_USER_QUALIFICATION_SESSION = "INSERT INTO USER_QUALIFICATION_SESSION(USER_ID,QUALIFICATION_SESSION_ID) VALUES((SELECT ID FROM `USER` WHERE USER_NAME = :username),:qualificationSessionId)";

    private final static String USER_LOCATION_QUALIFICATION_SESSION = "INSERT INTO USER_LOCATION_QUALIFICATION_SESSION(USER_ID,QUALIFICATION_SESSION_ID) VALUES((SELECT ID FROM `USER` WHERE USER_NAME = :username),:qualificationSessionId)";

    private final static String USER_LOCATION_QUALIFICATION_SESSION_QUERY_BY_USER = "SELECT QUALIFICATION_SESSION_ID FROM USER_LOCATION_QUALIFICATION_SESSION ulqs INNER JOIN `USER` u ON u.ID = ulqs.USER_ID WHERE u.USER_NAME = :username";
    private final static String LOCATION_QUALIFICATION_SESSION_QUERY_BY_LOCATION = "SELECT QUALIFICATION_SESSION_ID FROM LOCATION_QUALIFICATION_SESSION lqs INNER JOIN `LOCATION` l ON l.ID = lqs.LOCATION_ID WHERE l.CODE = :locationCode";
    private final NamedParameterJdbcTemplate jdbcTemplate;


    public UserQualificationSessionRepository(NamedParameterJdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public void associate(String username, long qualificationSessionId) {

        associateUserQualificationSession(username, qualificationSessionId);
        associateLocationUserQualificationSession(username, qualificationSessionId);
    }

    private void associateUserQualificationSession(String username, long qualificationSessionId) {
        HashMap<String, Object> paramMap = new HashMap<>();
        paramMap.put("username", username);
        paramMap.put("qualificationSessionId", qualificationSessionId);
        jdbcTemplate.update(INSERT_USER_QUALIFICATION_SESSION, paramMap);
    }

    private void associateLocationUserQualificationSession(String username, long qualificationSessionId) {
        HashMap<String, Object> paramMap = new HashMap<>();
        paramMap.put("username", username);
        paramMap.put("qualificationSessionId", qualificationSessionId);
        jdbcTemplate.update(USER_LOCATION_QUALIFICATION_SESSION, paramMap);
    }

    public Long getQualificationSessionByUser(String userName) {
        HashMap<String, Object> paramMap = new HashMap<>();
        paramMap.put("username", userName);
        Long id;
        try {
            id = jdbcTemplate.queryForObject(USER_LOCATION_QUALIFICATION_SESSION_QUERY_BY_USER, paramMap, Long.class);
        } catch (EmptyResultDataAccessException e) {
            id = null;
        }
        return id;
    }

    public Long getQualificationSessionByLocation(String locationCode) {
        HashMap<String, Object> paramMap = new HashMap<>();
        paramMap.put("locationCode", locationCode);
        Long qualificationSessionId;
        try {
            qualificationSessionId = jdbcTemplate.queryForObject(LOCATION_QUALIFICATION_SESSION_QUERY_BY_LOCATION, paramMap, Long.class);
        } catch (EmptyResultDataAccessException e) {
            qualificationSessionId = null;
        }
        return qualificationSessionId;
    }
}
