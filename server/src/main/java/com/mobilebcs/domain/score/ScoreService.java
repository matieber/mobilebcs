package com.mobilebcs.domain.score;

import java.util.List;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Service;

@Service
public class ScoreService {

    private static final String SELECT_PREDICTED_SCORE_WITH_QUALIFICATION ="SELECT ps.SCORE FROM PREDICTED_SCORE ps WHERE ps.QUALIFICATION_SESSION_ID = :qualificationSessionId";


    private final NamedParameterJdbcTemplate namedParameterJdbcTemplate;

    public ScoreService(NamedParameterJdbcTemplate namedParameterJdbcTemplate) {
        this.namedParameterJdbcTemplate = namedParameterJdbcTemplate;
    }

    public List<Double> findScores(Long qualificationSessionId) {
        List<Double> scores;
        MapSqlParameterSource paramMap = new MapSqlParameterSource();
        paramMap.addValue("qualificationSessionId", qualificationSessionId);
        scores = namedParameterJdbcTemplate.queryForList(SELECT_PREDICTED_SCORE_WITH_QUALIFICATION, paramMap, Double.class);
        return scores;
    }
}
