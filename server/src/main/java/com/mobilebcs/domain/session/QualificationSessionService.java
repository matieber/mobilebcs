package com.mobilebcs.domain.session;

import com.mobilebcs.domain.exception.DuplicatedSessionForLocationException;
import com.mobilebcs.domain.exception.InvalidLocalizationException;
import com.mobilebcs.domain.user.UserRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.stereotype.Component;

import java.sql.SQLException;
import java.util.HashMap;
import java.util.Objects;

@Component
public class QualificationSessionService {

    private static final Logger LOG = LoggerFactory.getLogger(UserRepository.class);
    private final NamedParameterJdbcTemplate namedParameterJdbcTemplate;

    public static final String SELECT_LOCATION = "SELECT ID FROM LOCATION WHERE CODE = :locationCode";
    private final static String INSERT_QUALIFICATION_SESSION = "INSERT INTO `QUALIFICATION_SESSION`(LOCATION_ID) VALUES (:locationId)";

    private final static String INSERT_LOCATION_QUALIFICATION_SESSION ="INSERT INTO `LOCATION_QUALIFICATION_SESSION`(QUALIFICATION_SESSION_ID,LOCATION_ID) VALUES(:qualificationSessionId," +
            "(" + SELECT_LOCATION + "))";

    public QualificationSessionService(NamedParameterJdbcTemplate namedParameterJdbcTemplate) {
        this.namedParameterJdbcTemplate = namedParameterJdbcTemplate;
    }

    public long startNewSession(String locationCode) throws SQLException, DuplicatedSessionForLocationException, InvalidLocalizationException {
        int locationId=getLocalizationId(locationCode);
        long qualificationSessionId = createQualificationSession(locationId);
        validateUniqueSessionForLocation(locationCode,qualificationSessionId);
        return qualificationSessionId;
    }

    private Integer getLocalizationId(String locationCode) throws InvalidLocalizationException {
        HashMap<String, Object> paramMap = new HashMap<>();
        paramMap.put("locationCode",locationCode);
        try {
            return namedParameterJdbcTemplate.queryForObject(SELECT_LOCATION, paramMap, Integer.class);
        }catch (EmptyResultDataAccessException e) {
            throw new InvalidLocalizationException("Localización es inválida");
        }

    }

    private long createQualificationSession(int locationId) throws SQLException {
        MapSqlParameterSource paramMap = new MapSqlParameterSource();
        paramMap.addValue("locationId", locationId);


            GeneratedKeyHolder holder = new GeneratedKeyHolder();
            int inserted = namedParameterJdbcTemplate.update(INSERT_QUALIFICATION_SESSION, paramMap,holder);
            if(inserted==0){
                throw new SQLException("Error creando sesión");
            }
            return Objects.requireNonNull(holder.getKey()).longValue();

    }

    private void validateUniqueSessionForLocation(String locationCode, long qualificationSessionId) throws SQLException, DuplicatedSessionForLocationException {
        MapSqlParameterSource paramMap = new MapSqlParameterSource();
        paramMap.addValue("locationCode", locationCode);
        paramMap.addValue("qualificationSessionId", qualificationSessionId);

        try {
            int inserted = namedParameterJdbcTemplate.update(INSERT_LOCATION_QUALIFICATION_SESSION, paramMap);
            if (inserted == 0) {
                throw new SQLException("Error creado sesión");
            }
        }catch (DuplicateKeyException exception){
            if(exception.getLocalizedMessage().contains("LOCATION_QUALIFICATION_SESSION.PRIMARY")) {
                String cause = "Ya existe sessión en la locación con código "+locationCode;
                LOG.error("Error validando sesión en locación con código "+locationCode+": "+cause);
                throw new DuplicatedSessionForLocationException("Error guardando usuario. Usuario ya existe. ");
            }
            throw exception;
        }

    }

    public void endQualificationSession(String locationCode) throws InvalidLocalizationException, SQLException {

        Integer localizationId = getLocalizationId(locationCode);

        Long qualificationSessionId=getCurrentQualificationSessionInSession(localizationId);
        if(qualificationSessionId!=null) {
            HashMap<String, Object> paramMap = new HashMap<>();
            paramMap.put("qualificationSessionId", qualificationSessionId);
            int deleted=namedParameterJdbcTemplate.update("DELETE FROM USER_LOCATION_QUALIFICATION_SESSION WHERE QUALIFICATION_SESSION_ID = :qualificationSessionId", paramMap);
            if(deleted==0){
                throw new SQLException("Error terminando sesión de calificador");
            }

            deleted=namedParameterJdbcTemplate.update("DELETE FROM LOCATION_QUALIFICATION_SESSION WHERE QUALIFICATION_SESSION_ID = :qualificationSessionId", paramMap);
            if(deleted==0){
                throw new SQLException("Error terminando sesión de calificador");
            }
        }
    }

    private Long getCurrentQualificationSessionInSession(Integer locationId) {
        Long qualificationSessionId;
        try {
            HashMap<String, Object> paramMap = new HashMap<>();
            paramMap.put("locationId",locationId);
            qualificationSessionId= namedParameterJdbcTemplate.queryForObject("SELECT QUALIFICATION_SESSION_ID FROM LOCATION_QUALIFICATION_SESSION where LOCATION_ID = :locationId", paramMap, Long.class);
        }catch(EmptyResultDataAccessException e){
            qualificationSessionId=null;
        }
        return qualificationSessionId;
    }


    public long getQualificationSessionByUser(String name) {
        return 0;
    }


}
