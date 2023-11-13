package com.mobilebcs.domain.qualifications;

import static org.springframework.util.CollectionUtils.isEmpty;

import com.mobilebcs.domain.predictions.QualificationEntity;
import java.util.List;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Service;

@Service
public class QualificationRepository {

    private static final String SELECT_LAST_QUALIFICATION_SESSION= "SELECT MAX(qs.END_DATE) AS MAX_END_DATE " +
            "FROM QUALIFICATION_SESSION qs LEFT JOIN LOCATION l ON qs.LOCATION_ID = l.ID WHERE l.CODE = :location AND qs.END_DATE IS NOT NULL";

    private static final String SELECT_LATEST_QUALIFICATION_SESSIONS = "SELECT qs.ID, qs.END_DATE, qs.START_DATE " +
            "FROM QUALIFICATION_SESSION qs LEFT JOIN LOCATION l ON qs.LOCATION_ID = l.ID WHERE l.CODE = :location AND qs.END_DATE IS NOT NULL " +
            "ORDER BY qs.END_DATE ASC LIMIT :amount";
    private static final String SELECT_ROW_LAST_QUALIFICATION_SESSION = "SELECT * FROM QUALIFICATION_SESSION q WHERE END_DATE = ("+SELECT_LAST_QUALIFICATION_SESSION+")";

    private static final String SELECT_ROW_QUALIFICATION_SESSION = "SELECT * FROM QUALIFICATION_SESSION WHERE ID = :qualificationSessionId";


    private static final String SELECT_CURRENT_QUALIFICATION="SELECT qs.START_DATE,qs.END_DATE, qs.ID FROM LOCATION_QUALIFICATION_SESSION lqs LEFT JOIN LOCATION l ON lqs.LOCATION_ID = l.ID LEFT JOIN QUALIFICATION_SESSION qs ON lqs.QUALIFICATION_SESSION_ID = qs.ID WHERE l.CODE = :location";


    private static final String SELECT ="SELECT qs.ID FROM QUALIFICATION_SESSION qs LEFT JOIN LOCATION l ON qs.LOCATION_ID = l.ID WHERE l.CODE = :location AND qs.END_DATE IS NOT NULL";
    private final NamedParameterJdbcTemplate namedParameterJdbcTemplate;


    public QualificationRepository(NamedParameterJdbcTemplate namedParameterJdbcTemplate) {
        this.namedParameterJdbcTemplate = namedParameterJdbcTemplate;
    }

    public QualificationEntity findCurrentQualificationSessionId(String location) {
        MapSqlParameterSource paramMap = new MapSqlParameterSource();
        paramMap.addValue("location", location);
        QualificationEntity qualificationEntity=null;
        try {
            qualificationEntity = namedParameterJdbcTemplate.queryForObject(SELECT_CURRENT_QUALIFICATION, paramMap, new BeanPropertyRowMapper<>(QualificationEntity.class));
        }catch (EmptyResultDataAccessException exception){

        }
        return qualificationEntity;
    }

    public QualificationEntity findQualificationSession(Long qualificationSessionId){
        MapSqlParameterSource paramMap = new MapSqlParameterSource();
        paramMap.addValue("qualificationSessionId", qualificationSessionId);
        List<QualificationEntity> qualificationEntity =null;
        try {
            qualificationEntity = namedParameterJdbcTemplate.query(SELECT_ROW_QUALIFICATION_SESSION, paramMap, new BeanPropertyRowMapper<>(
                    QualificationEntity.class));
        }catch (EmptyResultDataAccessException ignored){
        }

        return !isEmpty(qualificationEntity) ? qualificationEntity.get(0) : null;
    }

    public QualificationEntity findLastQualificationSession(String location) {
        MapSqlParameterSource paramMap = new MapSqlParameterSource();
        paramMap.addValue("location", location);
        List<QualificationEntity> qualificationEntity =null;
        try {
            qualificationEntity = namedParameterJdbcTemplate.query(SELECT_ROW_LAST_QUALIFICATION_SESSION, paramMap, new BeanPropertyRowMapper<>(
                    QualificationEntity.class));
        }catch (EmptyResultDataAccessException ignored){
        }

        return !isEmpty(qualificationEntity) ? qualificationEntity.get(0) : null;
    }

    public List<Long> findEndedQualificationSessionIds(String location){
        MapSqlParameterSource paramMap = new MapSqlParameterSource();
        paramMap.addValue("location", location);
        List<Long> list=null;
        try{
            list = namedParameterJdbcTemplate.queryForList(SELECT, paramMap, Long.class);
        }catch (EmptyResultDataAccessException e){

        }
        return list;
    }

    public List<QualificationEntity> findLatest(int amount, String location) {
        MapSqlParameterSource paramMap = new MapSqlParameterSource();
        paramMap.addValue("location", location);
        paramMap.addValue("amount",amount);
        List<QualificationEntity> qualificationEntities =null;
        try {
            qualificationEntities = namedParameterJdbcTemplate.query(SELECT_LATEST_QUALIFICATION_SESSIONS, paramMap, new BeanPropertyRowMapper<>(
                    QualificationEntity.class));
        }catch (EmptyResultDataAccessException ignored){
        }

        return qualificationEntities;
    }
}
