package com.mobilebcs.domain.predictions;

import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Service;

@Service
public class UpdateQualificationSessionInPredictionService {

    private final NamedParameterJdbcTemplate namedParameterJdbcTemplate;

    public static final String SELECT_IMAGES_BY_LOCATION = "SELECT ims.ID FROM IMAGE_SET ims LEFT JOIN IMAGE_SET_LOCATION isl ON ims.ID = isl.IMAGE_SET_ID WHERE isl.LOCATION_ID = :locationId";
    private static final String UPDATE_PREDICTION_QUALIFICATION_SESSION=
        "UPDATE PREDICTED_SCORE ps SET QUALIFICATION_SESSION_ID = :qualificationSessionId WHERE QUALIFICATION_SESSION_ID IS NULL AND IMAGE_SET_ID IN (" + SELECT_IMAGES_BY_LOCATION + ") ";

    public UpdateQualificationSessionInPredictionService(NamedParameterJdbcTemplate namedParameterJdbcTemplate) {
        this.namedParameterJdbcTemplate = namedParameterJdbcTemplate;
    }

    public void setQualificationSessionId(long qualificationSessionId, int locationId) {
        MapSqlParameterSource paramMap = new MapSqlParameterSource();
        paramMap.addValue("qualificationSessionId", qualificationSessionId);
        paramMap.addValue("locationId", locationId);

        int update = namedParameterJdbcTemplate.update(UPDATE_PREDICTION_QUALIFICATION_SESSION, paramMap);
        System.out.println("amount of score updated with qualification "+update+" qualfiication id "+qualificationSessionId);

    }
}
