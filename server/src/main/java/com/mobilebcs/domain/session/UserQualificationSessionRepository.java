package com.mobilebcs.domain.session;

import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.HashMap;

@Repository
public class UserQualificationSessionRepository {

    private final static String INSERT_USER_QUALIFICATION_SESSION ="INSERT INTO USER_QUALIFICATION_SESSION(USER_ID,QUALIFICATION_SESSION_ID) VALUES((SELECT ID FROM `USER` WHERE USER_NAME = :username),:qualificationSessionId)";
    //public static final String SELECT_LOCATION_ID = "SELECT l.ID FROM LOCATION l INNER JOIN LOCATION_QUALIFICATION_SESSION lqus ON l.ID = lqs.LOCATION_ID WHERE lqus.QUALIFICATION_SESSION_ID = :qualificationSessionId";
    public static final String SELECT_LOCATION_ID="1";
    private final static String USER_LOCATION_QUALIFICATION_SESSION = "INSERT INTO USER_LOCATION_QUALIFICATION_SESSION(USER_ID,QUALIFICATION_SESSION_ID) VALUES((SELECT ID FROM `USER` WHERE USER_NAME = :username),:qualificationSessionId)";

    private final static String USER_LOCATION_QUALIFICATION_SESSION_QUERY= "SELECT QUALIFICATION_SESSION_ID FROM USER_LOCATION_QUALIFICATION_SESSION WHERE USER_NAME = :username";
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

    public Long getQualificationSession(String userName) {
        HashMap<String, Object> paramMap = new HashMap<>();
        paramMap.put("username",userName);
        return jdbcTemplate.queryForObject(USER_LOCATION_QUALIFICATION_SESSION_QUERY, paramMap, Long.class);
    }
}
