package com.mobilebcs.domain.predictions;

import static org.springframework.util.CollectionUtils.isEmpty;

import com.mobilebcs.controller.prediction.QualifierSessionPredictionResponse;
import com.mobilebcs.domain.caravan.CaravanService;
import com.mobilebcs.domain.qualifications.QualificationRepository;
import com.mobilebcs.domain.score.ScoreService;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Service;

@Service
public class EndedQualificationSessionPredictionSearch {



    private final NamedParameterJdbcTemplate namedParameterJdbcTemplate;
    private final CaravanService caravanService;
    private final ScoreService scoreService;

    private final QualificationRepository qualificationRepository;



    public EndedQualificationSessionPredictionSearch(NamedParameterJdbcTemplate namedParameterJdbcTemplate, CaravanService caravanService, ScoreService scoreService,
                                                     QualificationRepository qualificationRepository) {
        this.namedParameterJdbcTemplate = namedParameterJdbcTemplate;
        this.caravanService=caravanService;
        this.scoreService = scoreService;
        this.qualificationRepository = qualificationRepository;
    }

    public QualifierSessionPredictionResponse findLast(String location) {
        QualificationEntity qualificationEntity = qualificationRepository.findLastQualificationSession(location);
        Long qualificationSessionId=Optional.ofNullable(qualificationEntity).map(QualificationEntity::getId).orElse(null);
        return getQualifierSessionPredictionResponse(qualificationSessionId, qualificationEntity);
    }

    public QualifierSessionPredictionResponse findSpecificQualificationSession(Long qualificationSessionId) {
        QualificationEntity qualificationEntity = qualificationRepository.findQualificationSession(qualificationSessionId);
        return getQualifierSessionPredictionResponse(qualificationSessionId, qualificationEntity);
    }

    private QualifierSessionPredictionResponse getQualifierSessionPredictionResponse(Long qualificationSessionId, QualificationEntity qualificationEntity) {
        LocalDateTime endDate=Optional.ofNullable(qualificationEntity).map(QualificationEntity::getEndDate).map(Timestamp::toLocalDateTime).orElse(null);
        LocalDateTime startDate=Optional.ofNullable(qualificationEntity).map(QualificationEntity::getStartDate).map(Timestamp::toLocalDateTime).orElse(null);

        List<Double> scores=new ArrayList<>();
        if(qualificationSessionId !=null){
            scores = scoreService.findScores(qualificationSessionId);
        }

        QualifierSessionPredictionResponse qualifierSessionPredictionResponse=null;
        if(!isEmpty(scores)){
            Integer caravanSize;
            caravanSize = caravanService.getCaravanSize(qualificationSessionId);
            qualifierSessionPredictionResponse= QualifierSessionPredictionResponse.create(scores, endDate, startDate, qualificationSessionId,caravanSize);
        }
        return qualifierSessionPredictionResponse;
    }






}
