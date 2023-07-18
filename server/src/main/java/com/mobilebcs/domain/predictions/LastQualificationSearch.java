package com.mobilebcs.domain.predictions;

import com.mobilebcs.controller.prediction.QualifierSessionPredictionResponse;
import com.mobilebcs.controller.prediction.ScoreResponse;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
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
public class LastQualificationSearch {


    private final NamedParameterJdbcTemplate namedParameterJdbcTemplate;

    private static final String SELECT_PREDICTED_SCORE_WITH_QUALIFICATION ="SELECT ps.SCORE FROM PREDICTED_SCORE ps WHERE ps.QUALIFICATION_SESSION_ID = :qualificationSessionId";

    private static final String SELECT_LAST_QUALIFICATION_SESSION= "SELECT MAX(qs.END_DATE) AS MAX_END_DATE FROM QUALIFICATION_SESSION qs LEFT JOIN LOCATION l ON qs.LOCATION_ID = l.ID WHERE l.CODE = :location";
    private static final String SELECT_ROW_LAST_QUALIFICATION_SESSION = "SELECT * FROM QUALIFICATION_SESSION q WHERE END_DATE = ("+SELECT_LAST_QUALIFICATION_SESSION+")";

    private static final String SELECT_CARAVAN_SIZE="SELECT COUNT(1) FROM IMAGE_SET_QUALIFICATION_SESSION WHERE QUALIFICATION_SESSION_ID = :qualificationSessionId";

    public LastQualificationSearch(NamedParameterJdbcTemplate namedParameterJdbcTemplate) {
        this.namedParameterJdbcTemplate = namedParameterJdbcTemplate;
    }

    public QualifierSessionPredictionResponse find(String location) {
        LocalDateTime endDate=null;


        LastQualificationEntity lastQualificationEntity = findLastQualificationSession(location);
        Long currentQualificationSessionId=null;
        if(lastQualificationEntity !=null){
            System.out.println(lastQualificationEntity.toString());
            currentQualificationSessionId= lastQualificationEntity.getId();
            endDate= Optional.ofNullable(lastQualificationEntity.getEndDate()).map(Timestamp::toLocalDateTime).orElse(null);
        }

        QualifierSessionPredictionResponse qualifierSessionPredictionResponse=null;
        List<Double> scores=new ArrayList<>();
        if(currentQualificationSessionId!=null){
            System.out.println("qualification session is not null");
            MapSqlParameterSource paramMap = new MapSqlParameterSource();
            paramMap.addValue("qualificationSessionId", currentQualificationSessionId);
            scores = namedParameterJdbcTemplate.queryForList(SELECT_PREDICTED_SCORE_WITH_QUALIFICATION, paramMap, Double.class);
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
        qualifierSessionPredictionResponse.setCaravanSize(getCaravanSize(currentQualificationSessionId));
        return qualifierSessionPredictionResponse;
    }

    private LastQualificationEntity findLastQualificationSession(String location) {
        MapSqlParameterSource paramMap = new MapSqlParameterSource();
        paramMap.addValue("location", location);
        List<LastQualificationEntity> lastQualificationEntity =null;
        try {
            List<LastQualificationEntity> lastQualificationEntity1 =
                namedParameterJdbcTemplate.query(SELECT_LAST_QUALIFICATION_SESSION, paramMap, new BeanPropertyRowMapper<>(LastQualificationEntity.class));

                System.out.println("-----------------------------");
                for (LastQualificationEntity l:lastQualificationEntity1) {
                    System.out.println(l.toString());
                }
                System.out.println("-----------------------------");

            lastQualificationEntity = namedParameterJdbcTemplate.query(SELECT_ROW_LAST_QUALIFICATION_SESSION, paramMap, new BeanPropertyRowMapper<>(
                LastQualificationEntity.class));
        }catch (EmptyResultDataAccessException exception){

        }

        return lastQualificationEntity.isEmpty()?  null : lastQualificationEntity.get(0);
    }

    private Integer getCaravanSize(Long qualificationSessionId) {
        MapSqlParameterSource paramMap = new MapSqlParameterSource();
        paramMap.addValue("qualificationSessionId", qualificationSessionId);
        return namedParameterJdbcTemplate.queryForObject(SELECT_CARAVAN_SIZE, paramMap, Integer.class);
    }

}
