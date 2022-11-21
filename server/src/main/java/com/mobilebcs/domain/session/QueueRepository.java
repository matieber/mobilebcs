package com.mobilebcs.domain.session;

import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.HashMap;
import java.util.List;

@Repository
public class QueueRepository {

    public static final String SELECT_USER_BY_SESSION_BY_SESSION_ID = "SELECT ulqs.QUALIFICATION_SESSION_ID, u.USER_NAME, u.TYPE from USER_LOCATION_QUALIFICATION_SESSION ulqs INNER JOIN `USER` u ON u.ID = ulqs.USER_ID WHERE ulqs.QUALIFICATION_SESSION_ID = :qualificationSessionId";
    public static final String SELECT_USER_BY_SESSION_BY_SESSION_ID_USER_NAME = "SELECT ulqs.QUALIFICATION_SESSION_ID, u.USER_NAME, u.TYPE from USER_LOCATION_QUALIFICATION_SESSION ulqs INNER JOIN `USER` u ON u.ID = ulqs.USER_ID WHERE ulqs.QUALIFICATION_SESSION_ID = :qualificationSessionId AND u.USER_NAME = :userName";
    private final NamedParameterJdbcTemplate jdbcTemplate;

    public QueueRepository(NamedParameterJdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }


    public List<UserQueueEntity> getActiveUserInSessionBy(Long qualificationSessionId) {
        HashMap<String, Object> paramMap = new HashMap<>();
        paramMap.put("qualificationSessionId", qualificationSessionId);
        return jdbcTemplate.query(SELECT_USER_BY_SESSION_BY_SESSION_ID, paramMap, new BeanPropertyRowMapper<>(UserQueueEntity.class));
    }

    public UserQueueEntity getActiveUserInSessionBy(Long qualificationSessionId, String userName) {
        HashMap<String, Object> paramMap = new HashMap<>();
        paramMap.put("qualificationSessionId", qualificationSessionId);
        paramMap.put("userName", userName);
        return jdbcTemplate.queryForObject(SELECT_USER_BY_SESSION_BY_SESSION_ID_USER_NAME, paramMap, new BeanPropertyRowMapper<>(UserQueueEntity.class));
    }
}
