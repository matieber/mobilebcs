package com.mobilebcs.domain.predictions;

import com.mobilebcs.domain.exception.InvalidLocalizationException;
import com.mobilebcs.domain.session.QualificationSessionService;
import java.sql.SQLException;
import java.util.UUID;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Service;

@Service
public class ScorePredictionService {

        private static final String INSERT_PREDICTION_SCORE_QUERY = "INSERT INTO `PREDICTED_SCORE`(IMAGE_SET_ID,SCORE,QUALIFICATION_SESSION_ID) VALUES((SELECT ID FROM IMAGE_SET WHERE SET_CODE = :setCode),:score,:qualificationSessionId)";

      private final NamedParameterJdbcTemplate namedParameterJdbcTemplate;

    private final QualificationSessionService qualificationSessionService;


    public ScorePredictionService(NamedParameterJdbcTemplate namedParameterJdbcTemplate, QualificationSessionService qualificationSessionService) {
        this.namedParameterJdbcTemplate = namedParameterJdbcTemplate;
        this.qualificationSessionService = qualificationSessionService;
    }

    public void saveScore(UUID setCode,double score,String locationCode) throws SQLException, InvalidLocalizationException {
        MapSqlParameterSource paramMap = new MapSqlParameterSource();
        paramMap.addValue("setCode", setCode.toString());
        paramMap.addValue("score", score);
        Long value = qualificationSessionService.getCurrentQualificationSessionInSessionByLocationCode(locationCode);
        paramMap.addValue("qualificationSessionId",
            value);


            int inserted = namedParameterJdbcTemplate.update(INSERT_PREDICTION_SCORE_QUERY, paramMap);
            if(inserted==0){
                throw new SQLException("Error insertando predicción");
            }


    }


}
