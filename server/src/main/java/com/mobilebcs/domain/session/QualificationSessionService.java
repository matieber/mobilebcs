package com.mobilebcs.domain.session;

import com.mobilebcs.domain.exception.DuplicatedSessionForLocationException;
import com.mobilebcs.domain.exception.InvalidLocalizationException;
import com.mobilebcs.domain.exception.SessionNotStartedException;
import com.mobilebcs.domain.predictions.UpdateQualificationSessionInPredictionService;
import com.mobilebcs.domain.user.UserRepository;
import java.sql.Timestamp;
import java.time.Instant;
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
    private final UpdateQualificationSessionInPredictionService updateQualificationSessionInPredictionService;

    private static final String SELECT_LOCATION = "SELECT ID FROM LOCATION l WHERE l.CODE = :locationCode";
    private final static String INSERT_QUALIFICATION_SESSION = "INSERT INTO `QUALIFICATION_SESSION`(LOCATION_ID) VALUES (:locationId)";

    private final static String INSERT_LOCATION_QUALIFICATION_SESSION = "INSERT INTO `LOCATION_QUALIFICATION_SESSION`(QUALIFICATION_SESSION_ID,LOCATION_ID) VALUES(:qualificationSessionId," +
            "(" + SELECT_LOCATION + "))";

    private static final String UPDATE_END_DATE_QUALIFICATION_SESSION =
        "UPDATE QUALIFICATION_SESSION ps SET END_DATE = :endDate WHERE ID = :qualificationSessionId ";


    public QualificationSessionService(NamedParameterJdbcTemplate namedParameterJdbcTemplate,
                                       UpdateQualificationSessionInPredictionService updateQualificationSessionInPredictionService) {
        this.namedParameterJdbcTemplate = namedParameterJdbcTemplate;
        this.updateQualificationSessionInPredictionService = updateQualificationSessionInPredictionService;
    }

    public long startNewSession(String locationCode) throws SQLException, DuplicatedSessionForLocationException, InvalidLocalizationException {
        int locationId = getLocationId(locationCode);
        long qualificationSessionId = createQualificationSession(locationId);
        validateUniqueSessionForLocation(locationCode, qualificationSessionId);
        updateQualificationSessionInPredictionService.setQualificationSessionId(qualificationSessionId,locationId);
        return qualificationSessionId;
    }

    public void endQualificationSession(String locationCode) throws InvalidLocalizationException, SQLException, SessionNotStartedException {

        Integer locationId = getLocationId(locationCode);

        Long qualificationSessionId = getCurrentQualificationSessionInSession(locationId);

        if (qualificationSessionId != null) {
            updateQualificationSessionInPredictionService.setQualificationSessionId(qualificationSessionId,locationId);
             deleteUserLocationQualificationSession(qualificationSessionId);
            deleteLocationQualificationSession(qualificationSessionId);

            insertImageSetQualification(qualificationSessionId,locationId);
            deleteImageSetLocation(locationId);
            updateEndDate(qualificationSessionId);

        } else {
            throw new SessionNotStartedException("No existe sesión de calificación iniciada en la locación dada");
        }

    }

    private void insertImageSetQualification(Long qualificationSessionId, Integer locationId) {
        HashMap<String, Object> paramMap = new HashMap<>();
        paramMap.put("locationId", locationId);
        paramMap.put("qualificationSessionId",qualificationSessionId);
        namedParameterJdbcTemplate.update("INSERT INTO IMAGE_SET_QUALIFICATION_SESSION (IMAGE_SET_ID, QUALIFICATION_SESSION_ID) SELECT IMAGE_SET_ID, :qualificationSessionId FROM IMAGE_SET_LOCATION WHERE LOCATION_ID = :locationId", paramMap);
    }

    private void deleteImageSetLocation(Integer locationId) {
        HashMap<String, Object> paramMap = new HashMap<>();
        paramMap.put("locationId", locationId);
        namedParameterJdbcTemplate.update("DELETE FROM IMAGE_SET_LOCATION WHERE LOCATION_ID = :locationId", paramMap);
    }

    private void deleteLocationQualificationSession(Long qualificationSessionId) throws SQLException {
        HashMap<String, Object> paramMap = new HashMap<>();
        paramMap.put("qualificationSessionId", qualificationSessionId);
        int deleted = namedParameterJdbcTemplate.update("DELETE FROM LOCATION_QUALIFICATION_SESSION WHERE QUALIFICATION_SESSION_ID = :qualificationSessionId", paramMap);
        if (deleted == 0) {
            throw new SQLException("Error terminando sesión de calificador");
        }
    }

    private void deleteUserLocationQualificationSession(Long qualificationSessionId) throws SQLException {
        HashMap<String, Object> paramMap = new HashMap<>();
        paramMap.put("qualificationSessionId", qualificationSessionId);
        int deleted = namedParameterJdbcTemplate.update("DELETE FROM USER_LOCATION_QUALIFICATION_SESSION WHERE QUALIFICATION_SESSION_ID = :qualificationSessionId", paramMap);
        if (deleted == 0) {
            throw new SQLException("Error terminando sesión de calificador");
        }

    }

    private Integer getLocationId(String locationCode) throws InvalidLocalizationException {
        HashMap<String, Object> paramMap = new HashMap<>();
        paramMap.put("locationCode", locationCode);
        try {
            return namedParameterJdbcTemplate.queryForObject(SELECT_LOCATION, paramMap, Integer.class);
        } catch (EmptyResultDataAccessException e) {
            throw new InvalidLocalizationException("Localización es inválida");
        }

    }

    private long createQualificationSession(int locationId) throws SQLException {
        MapSqlParameterSource paramMap = new MapSqlParameterSource();
        paramMap.addValue("locationId", locationId);


        GeneratedKeyHolder holder = new GeneratedKeyHolder();
        int inserted = namedParameterJdbcTemplate.update(INSERT_QUALIFICATION_SESSION, paramMap, holder);
        if (inserted == 0) {
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
        } catch (DuplicateKeyException exception) {
            if (exception.getLocalizedMessage().contains("LOCATION_QUALIFICATION_SESSION.PRIMARY")) {
                String cause = "Ya existe sessión en la locación con código " + locationCode;
                LOG.error("Error validando sesión en locación con código " + locationCode + ": " + cause);
                throw new DuplicatedSessionForLocationException("Error creando sesión. Ya se ha iniciado sesión en la locación dada");
            }
            throw exception;
        }

    }

    private Long getCurrentQualificationSessionInSession(Integer locationId) {
        Long qualificationSessionId;
        try {
            HashMap<String, Object> paramMap = new HashMap<>();
            paramMap.put("locationId", locationId);
            qualificationSessionId = namedParameterJdbcTemplate.queryForObject("SELECT QUALIFICATION_SESSION_ID FROM LOCATION_QUALIFICATION_SESSION where LOCATION_ID = :locationId", paramMap, Long.class);
        } catch (EmptyResultDataAccessException e) {
            qualificationSessionId = null;
        }
        return qualificationSessionId;
    }

    public Long getCurrentQualificationSessionInSessionByLocationCode(String locationCode) throws InvalidLocalizationException {
        Integer localizationId = getLocationId(locationCode);
        return getCurrentQualificationSessionInSession(localizationId);
    }

    private void updateEndDate(long qualificationSessionId) throws SQLException {
        MapSqlParameterSource paramMap = new MapSqlParameterSource();
        paramMap.addValue("qualificationSessionId", qualificationSessionId);
        paramMap.addValue("endDate", new Timestamp(Instant.now().toEpochMilli()));

        int update = namedParameterJdbcTemplate.update(UPDATE_END_DATE_QUALIFICATION_SESSION, paramMap);
        if (update == 0) {
            throw new SQLException("Error terminando sesión de calificador");
        }

    }


}
