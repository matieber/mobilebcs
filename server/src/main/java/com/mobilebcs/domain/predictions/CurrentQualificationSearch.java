package com.mobilebcs.domain.predictions;

import com.mobilebcs.controller.prediction.QualifierSessionPredictionResponse;
import com.mobilebcs.controller.prediction.ScoreResponse;
import com.mobilebcs.domain.caravan.CaravanService;
import com.mobilebcs.domain.qualifications.QualificationRepository;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Service;

@Service
public class CurrentQualificationSearch {


    private final NamedParameterJdbcTemplate namedParameterJdbcTemplate;


    private static final String SELECT_IMAGES_BY_LOCATION_CODE = "SELECT ims.ID FROM IMAGE_SET ims LEFT JOIN IMAGE_SET_LOCATION isl ON ims.ID = isl.IMAGE_SET_ID LEFT JOIN LOCATION l ON isl.LOCATION_ID = l.ID WHERE l.CODE = :location";
    private static final String SELECT_PREDICTED_SCORE_WITH_LOCATION ="SELECT ps.SCORE FROM PREDICTED_SCORE ps WHERE ps.QUALIFICATION_SESSION_ID IS NULL AND IMAGE_SET_ID IN (" +
        SELECT_IMAGES_BY_LOCATION_CODE + ")";

    private static final String SELECT_PREDICTED_SCORE_WITH_QUALIFICATION ="SELECT ps.SCORE FROM PREDICTED_SCORE ps WHERE ps.QUALIFICATION_SESSION_ID = :qualificationSessionId";


    private final CaravanService caravanService;

    private final QualificationRepository qualificationRepository;

    public CurrentQualificationSearch(NamedParameterJdbcTemplate namedParameterJdbcTemplate, CaravanService caravanService,
                                      QualificationRepository qualificationRepository) {
        this.namedParameterJdbcTemplate = namedParameterJdbcTemplate;
        this.caravanService = caravanService;
        this.qualificationRepository = qualificationRepository;
    }

    public QualifierSessionPredictionResponse find(String location) {

        QualificationEntity currentQualificationSession = qualificationRepository.findCurrentQualificationSessionId(location);

        QualifierSessionPredictionResponse qualifierSessionPredictionResponse=null;
        LocalDateTime endDate=null;
        LocalDateTime startDate=null;
        Long currentQualificationSessionId=null;
        List<Double> scores;
        if(currentQualificationSession==null || currentQualificationSession.getId()==null) {
            scores = getScoreByLocation(location);
        }else{
            scores = getScoreByQualificationSession(currentQualificationSession.getId());
            endDate=Optional.ofNullable(currentQualificationSession).map(QualificationEntity::getEndDate).map(Timestamp::toLocalDateTime).orElse(null);
            startDate=Optional.ofNullable(currentQualificationSession).map(QualificationEntity::getStartDate).map(Timestamp::toLocalDateTime).orElse(null);
            currentQualificationSessionId=currentQualificationSession.getId();

        }
        System.out.println("score size is "+ Optional.ofNullable(scores).map(List::size).orElse(0));
        Integer caravanSize=caravanService.getCaravanSize(location);
        if(caravanSize!=null && caravanSize>0){
            qualifierSessionPredictionResponse=createResponse(scores,startDate,endDate,currentQualificationSessionId,caravanSize);
        }
        return qualifierSessionPredictionResponse;
    }



    private List<Double> getScoreByQualificationSession(Long currentQualificationSessionId) {
        List<Double> scores;
        System.out.println("qualification session is " + currentQualificationSessionId);
        MapSqlParameterSource paramMap = new MapSqlParameterSource();
        paramMap.addValue("qualificationSessionId", currentQualificationSessionId);
        scores = namedParameterJdbcTemplate.queryForList(SELECT_PREDICTED_SCORE_WITH_QUALIFICATION, paramMap, Double.class);
        return scores;
    }

    private List<Double> getScoreByLocation(String location) {
        List<Double> scores;
        System.out.println("qualification session is null");
        MapSqlParameterSource paramMap = new MapSqlParameterSource();
        paramMap.addValue("location", location);
        scores = namedParameterJdbcTemplate.queryForList(SELECT_PREDICTED_SCORE_WITH_LOCATION, paramMap, Double.class);
        return scores;
    }

    private QualifierSessionPredictionResponse createResponse(List<Double> scores,LocalDateTime startDate, LocalDateTime endDate, Long currentQualificationSessionId, Integer caravanSize) {
        List<ScoreResponse> scoreResponse = scores.stream().map(ScoreResponse::new).collect(Collectors.toList());
        QualifierSessionPredictionResponse qualifierSessionPredictionResponse = new QualifierSessionPredictionResponse();
        qualifierSessionPredictionResponse.setScores(scoreResponse);
        qualifierSessionPredictionResponse.setSessionEndDate(endDate);
        qualifierSessionPredictionResponse.setQualificationSession(currentQualificationSessionId);
        qualifierSessionPredictionResponse.setCaravanSize(caravanSize);
        qualifierSessionPredictionResponse.setSessionStartDate(startDate);
        return qualifierSessionPredictionResponse;
    }




}
