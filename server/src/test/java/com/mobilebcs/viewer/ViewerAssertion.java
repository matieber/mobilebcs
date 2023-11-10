package com.mobilebcs.viewer;

import com.mobilebcs.domain.jobnotification.ScoreJobNotification;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;
import org.junit.jupiter.api.Assertions;
import org.mockito.ArgumentCaptor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

@Service
public class ViewerAssertion {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    public void assertScore(ArgumentCaptor<Object> argumentCaptor,String locationCode,double expectedScore) {
        Optional<ScoreJobNotification>
            scoreJobNotification = argumentCaptor.getAllValues().stream().filter(object -> object instanceof ScoreJobNotification).map(o->(ScoreJobNotification)o).findAny();
        Assertions.assertTrue(scoreJobNotification.isPresent());
        Assertions.assertEquals(expectedScore,scoreJobNotification.get().getScore().doubleValue());
        Assertions.assertEquals(locationCode,scoreJobNotification.get().getLocation());
    }

    public void assertPersistedPredictionScore(Long qualificationSession, Map<UUID, Double> expectedScoresByUUID) {
        Set<UUID> imageSetIds = expectedScoresByUUID.keySet();
        String codes=imageSetIds.stream().map(UUID::toString).map(value->"'"+value+"'").collect(Collectors.joining(","));
        Assertions.assertEquals(imageSetIds.size(),expectedScoresByUUID.size());
        List<PredictedScoreEntity> predictedEntities = jdbcTemplate.query(
            "SELECT ims.SET_CODE, ps.SCORE, ps.QUALIFICATION_SESSION_ID FROM IMAGE_SET ims LEFT JOIN PREDICTED_SCORE ps ON ims.ID = ps.IMAGE_SET_ID WHERE ims.SET_CODE IN ("+codes+")", new BeanPropertyRowMapper<>(PredictedScoreEntity.class));
        Assertions.assertEquals(imageSetIds.size(),predictedEntities.size());
        for(UUID expectedCode: imageSetIds){
            Optional<PredictedScoreEntity> actual =
                predictedEntities.stream().filter(predictedScoreEntity -> expectedCode.toString().equals(predictedScoreEntity.getSetCode())).findAny();
            Assertions.assertTrue(actual.isPresent());
            Assertions.assertEquals(expectedScoresByUUID.get(expectedCode),actual.get().getScore());
            Assertions.assertEquals(expectedCode.toString(),actual.get().getSetCode());
            if(qualificationSession==null){
                Assertions.assertNull(actual.get().getQualificationSessionId());
            }else{
                Assertions.assertEquals(qualificationSession,actual.get().getQualificationSessionId());
            }
        }

    }

}
