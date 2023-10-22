package com.mobilebcs.domain.predictions;

import com.mobilebcs.controller.prediction.QualifierSessionPredictionResponse;
import com.mobilebcs.controller.prediction.ScoreResponse;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.util.CollectionUtils;

@Service
public class PredictionSearchService {

    private final NamedParameterJdbcTemplate namedParameterJdbcTemplate;


    private static final String SELECT_CURRENT_QUALIFICATION="SELECT lqs.QUALIFICATION_SESSION_ID FROM LOCATION_QUALIFICATION_SESSION lqs LEFT JOIN LOCATION l ON lqs.LOCATION_ID = l.ID WHERE l.CODE = :location";

    private static final String SELECT_PREDICTED_SCORE_WITH_QUALIFICATION ="SELECT ps.SCORE FROM PREDICTED_SCORE ps WHERE ps.QUALIFICATION_SESSION_ID = :qualificationSessionId";

    private static final String SELECT_IMAGES_BY_LOCATION_CODE = "SELECT ims.ID FROM IMAGE_SET ims LEFT JOIN IMAGE_SET_LOCATION isl ON ims.ID = isl.IMAGE_SET_ID LEFT JOIN LOCATION l ON isl.LOCATION_ID = l.ID WHERE l.CODE = :location";
    private static final String SELECT_PREDICTED_SCORE_WITH_LOCATION ="SELECT ps.SCORE FROM PREDICTED_SCORE ps WHERE ps.QUALIFICATION_SESSION_ID IS NULL AND IMAGE_SET_ID IN (" +
        SELECT_IMAGES_BY_LOCATION_CODE + ")";

    private static final String SELECT_LAST_QUALIFICATION_SESSION= "SELECT qs.ID, MAX(qs.END_DATE) AS MAX_END_DATE FROM QUALIFICATION_SESSION qs LEFT JOIN LOCATION l ON qs.LOCATION_ID = l.ID WHERE l.CODE = :location GROUP BY  qs.ID";
    private static final String SELECT_ROW_LAST_QUALIFICATION_SESSION = "SELECT * FROM QUALIFICATION_SESSION q INNER JOIN ("+SELECT_LAST_QUALIFICATION_SESSION+") AS s ON q.ID = s.ID";
    public PredictionSearchService(NamedParameterJdbcTemplate namedParameterJdbcTemplate) {
        this.namedParameterJdbcTemplate = namedParameterJdbcTemplate;
    }

    public QualifierSessionPredictionResponse findLastOne(String location) {
        LocalDateTime endDate=null;
        Long currentQualificationSessionId = findCurrentQualificationSessionId(location);
        if(currentQualificationSessionId==null){
            QualificationEntity qualificationEntity = findLastQualificationSession(location);
            if(qualificationEntity !=null){
                System.out.println(qualificationEntity.toString());
                currentQualificationSessionId= qualificationEntity.getId();
                endDate=Optional.ofNullable(qualificationEntity.getEndDate()).map(Timestamp::toLocalDateTime).orElse(null);
            }
        }
        QualifierSessionPredictionResponse qualifierSessionPredictionResponse=null;
        List<Double> scores;
        if(currentQualificationSessionId!=null){
            System.out.println("qualification session is not null");
            MapSqlParameterSource paramMap = new MapSqlParameterSource();
            paramMap.addValue("qualificationSessionId", currentQualificationSessionId);
            scores = namedParameterJdbcTemplate.queryForList(SELECT_PREDICTED_SCORE_WITH_QUALIFICATION, paramMap, Double.class);
        }else{
            System.out.println("qualification session is null");
            MapSqlParameterSource paramMap = new MapSqlParameterSource();
            paramMap.addValue("location", location);
            scores = namedParameterJdbcTemplate.queryForList(SELECT_PREDICTED_SCORE_WITH_LOCATION, paramMap, Double.class);
        }
        System.out.println("score size is "+ Optional.ofNullable(scores).map(List::size).orElse(0));
        if(!CollectionUtils.isEmpty(scores)){
            qualifierSessionPredictionResponse=createResponse(scores,endDate,currentQualificationSessionId);
        }
        return qualifierSessionPredictionResponse;
    }

    private QualifierSessionPredictionResponse createResponse(List<Double> scores, LocalDateTime endDate, Long currentQualificationSessionId) {
        List<ScoreResponse> scoreResponse = scores.stream().map(ScoreResponse::new).collect(Collectors.toList());
        QualifierSessionPredictionResponse qualifierSessionPredictionResponse = new QualifierSessionPredictionResponse();
        qualifierSessionPredictionResponse.setScores(scoreResponse);
        qualifierSessionPredictionResponse.setSessionEndDate(endDate);
        qualifierSessionPredictionResponse.setQualificationSession(currentQualificationSessionId);
        return qualifierSessionPredictionResponse;
    }

    private QualificationEntity findLastQualificationSession(String location) {
        MapSqlParameterSource paramMap = new MapSqlParameterSource();
        paramMap.addValue("location", location);
        QualificationEntity qualificationEntity =null;
        try {
            qualificationEntity = namedParameterJdbcTemplate.queryForObject(SELECT_ROW_LAST_QUALIFICATION_SESSION, paramMap, new BeanPropertyRowMapper<>(
                QualificationEntity.class));
        }catch (EmptyResultDataAccessException exception){

        }
        return qualificationEntity;
    }

    private Long findCurrentQualificationSessionId(String location) {
        MapSqlParameterSource paramMap = new MapSqlParameterSource();
        paramMap.addValue("location", location);
        Long qualificationSessionId=null;
        try {
            qualificationSessionId = namedParameterJdbcTemplate.queryForObject(SELECT_CURRENT_QUALIFICATION, paramMap, Long.class);
        }catch (EmptyResultDataAccessException exception){

        }
        return qualificationSessionId;
    }


}
