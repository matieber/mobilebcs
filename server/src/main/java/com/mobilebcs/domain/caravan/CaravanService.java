package com.mobilebcs.domain.caravan;

import com.mobilebcs.controller.caravan.CaravanInfoResponse;
import com.mobilebcs.controller.caravan.CaravanQualificationResponse;
import java.util.List;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Service;

@Service
public class CaravanService {

    private static final String SELECT_CARAVAN= "SELECT ps.SCORE, ps.QUALIFICATION_SESSION_ID, is2.SET_CODE FROM PREDICTED_SCORE ps " +
            "LEFT JOIN IMAGE_SET is2 ON ps.IMAGE_SET_ID = is2 .ID where is2.IDENTIFICATION = :identification" +
            " ORDER BY ps.QUALIFICATION_SESSION_ID";

    private final NamedParameterJdbcTemplate namedParameterJdbcTemplate;
    private BeanPropertyRowMapper rowMapper;

    public CaravanService(NamedParameterJdbcTemplate namedParameterJdbcTemplate) {
        this.namedParameterJdbcTemplate = namedParameterJdbcTemplate;
        rowMapper = new BeanPropertyRowMapper(CaravanQualificationResponse.class);
    }


    public CaravanInfoResponse lookup(String identification) {


        MapSqlParameterSource paramMap = new MapSqlParameterSource();
        paramMap.addValue("identification", identification);
        List<CaravanQualificationResponse> caravans = namedParameterJdbcTemplate.query(SELECT_CARAVAN, paramMap, rowMapper);
        return new CaravanInfoResponse(caravans);

    }
}
