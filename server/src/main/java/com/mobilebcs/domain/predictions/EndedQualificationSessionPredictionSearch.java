package com.mobilebcs.domain.predictions;

import static org.springframework.util.CollectionUtils.isEmpty;

import com.mobilebcs.controller.prediction.QualifierSessionAverageResponse;
import com.mobilebcs.controller.prediction.QualifierSessionPredictionResponse;
import com.mobilebcs.domain.caravan.CaravanService;
import com.mobilebcs.domain.qualifications.QualificationRepository;
import com.mobilebcs.domain.score.ScoreService;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.Optional;
import java.util.OptionalDouble;

import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.util.CollectionUtils;

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

    public List<QualifierSessionAverageResponse> findDispersion(String location, int amount) {
        List<QualificationEntity> lastQualifications= qualificationRepository.findLatest(amount,location);
        List<QualifierSessionAverageResponse> qualifierSessionAverageResponses=new ArrayList<>();
        for(QualificationEntity qualificationEntity: lastQualifications){
            List<Double> scores = scoreService.findScores(qualificationEntity.getId());
            if(!isEmpty(scores)){
                QualifierSessionAverageResponse qualifierSessionAverageResponse=new QualifierSessionAverageResponse();
                QualificationSessionAverageDispersion dispersion = dispersion(scores);
                qualifierSessionAverageResponse.setAverage(dispersion.getAverage());
                qualifierSessionAverageResponse.setStandardDeviation(dispersion.getStandardDeviation());
                LocalDateTime endDate=Optional.ofNullable(qualificationEntity).map(QualificationEntity::getEndDate).map(Timestamp::toLocalDateTime).orElse(null);
                LocalDateTime startDate=Optional.ofNullable(qualificationEntity).map(QualificationEntity::getStartDate).map(Timestamp::toLocalDateTime).orElse(null);
                qualifierSessionAverageResponse.setSessionEndDate(endDate);
                qualifierSessionAverageResponse.setSessionStartDate(startDate);
                qualifierSessionAverageResponse.setQualificationSession(qualificationEntity.getId());
                qualifierSessionAverageResponses.add(qualifierSessionAverageResponse);
            }
        }
        return qualifierSessionAverageResponses;
    }

    public double average(List<Double> scores) {
        OptionalDouble average = scores.stream().filter(Objects::nonNull).mapToDouble(Double::doubleValue).average();
        if(average.isEmpty()){
            System.out.println();
        }
        return average.getAsDouble();
    }

    public QualificationSessionAverageDispersion dispersion(List<Double> scores) {
        double average = average(scores);
        double sumaDeCuadrados = 0;
         sumaDeCuadrados = scores.stream().mapToDouble(Double::doubleValue).map(value -> Math.pow(value - average, 2)).sum();

        double variance = sumaDeCuadrados / scores.size();
        double standardDeviation=Math.sqrt(variance);
        return new QualificationSessionAverageDispersion(average,standardDeviation);

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
