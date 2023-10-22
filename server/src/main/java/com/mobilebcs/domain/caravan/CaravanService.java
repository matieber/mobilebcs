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

    private static final String SELECT_CARAVAN_SIZE="SELECT COUNT(1) FROM IMAGE_SET_QUALIFICATION_SESSION WHERE QUALIFICATION_SESSION_ID = :qualificationSessionId";

    private static final String SELECT_CARAVAN_SIZE_2="SELECT COUNT(1) FROM IMAGE_SET_LOCATION isl LEFT JOIN LOCATION l ON isl.LOCATION_ID = l.ID WHERE l.CODE = :location";

    private static final String SELECT_CARAVAN_SIZE_3= "SELECT COUNT(1) FROM LOCATION_QUALIFICATION_SESSION lqs LEFT JOIN IMAGE_SET_LOCATION isl ON isl.LOCATION_ID = lqs.LOCATION_ID WHERE lqs.QUALIFICATION_SESSION_ID = :qualificationSessionId";

    private final NamedParameterJdbcTemplate namedParameterJdbcTemplate;
    private final BeanPropertyRowMapper rowMapper;

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

    public Integer getCaravanSize(Long qualificationSessionId) {
        MapSqlParameterSource paramMap = new MapSqlParameterSource();
        paramMap.addValue("qualificationSessionId", qualificationSessionId);
        Integer size = namedParameterJdbcTemplate.queryForObject(SELECT_CARAVAN_SIZE, paramMap, Integer.class);
        if(size==0){
            size = namedParameterJdbcTemplate.queryForObject(SELECT_CARAVAN_SIZE_3, paramMap, Integer.class);
        }
        return size;
    }

    public Integer getCaravanSize(String locationCode) {
        MapSqlParameterSource paramMap = new MapSqlParameterSource();
        paramMap.addValue("location", locationCode);
        return namedParameterJdbcTemplate.queryForObject(SELECT_CARAVAN_SIZE_2, paramMap, Integer.class);
    }
}
