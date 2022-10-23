package com.mobilebcs.domain.user;

import com.mobilebcs.domain.exception.DuplicatedUsernameException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Component;

import java.sql.SQLException;

@Component
public class UserRepository {

    private static final Logger LOG = LoggerFactory.getLogger(UserRepository.class);

    private static final String INSERT_USER_QUERY = "INSERT INTO `USER`(USER_NAME,TYPE) VALUES(:userName,:type)";
    private static final String USER_QUERY = "SELECT USER_NAME, TYPE FROM `USER` WHERE USER_NAME = :userName";


    private final NamedParameterJdbcTemplate namedParameterJdbcTemplate;

    public UserRepository(NamedParameterJdbcTemplate namedParameterJdbcTemplate) {
        this.namedParameterJdbcTemplate = namedParameterJdbcTemplate;
    }

    public UserEntity get(String name) {
        MapSqlParameterSource paramMap = new MapSqlParameterSource();
        paramMap.addValue("userName", name);
        UserEntity user=null;
        try {
            user = namedParameterJdbcTemplate.queryForObject(USER_QUERY, paramMap, new BeanPropertyRowMapper<>(UserEntity.class));
        }catch (EmptyResultDataAccessException exception){

        }
        return user;

    }

    public void add(UserEntity user) throws SQLException, DuplicatedUsernameException {
        MapSqlParameterSource paramMap = new MapSqlParameterSource();
        paramMap.addValue("userName", user.getUserName());
        paramMap.addValue("type", user.getType());

        try {
            int inserted = namedParameterJdbcTemplate.update(INSERT_USER_QUERY, paramMap);
            if(inserted==0){
                throw new SQLException("Error insertando set");
            }
        }catch (DuplicateKeyException exception){
        if(exception.getLocalizedMessage().contains("uk_USER_USER_NAME")) {
            String cause = "Ya existe usuario con el nombre de usuario: "+user.getUserName();
            LOG.error("Error guardando usuario: "+cause);
            throw new DuplicatedUsernameException("Error guardando usuario. Usuario ya existe. ");
        }
        throw exception;
    }

    }
}
