package com.mobilebcs.domain.qualifier;

import com.mobilebcs.domain.exception.InvalidOperationException;
import com.mobilebcs.domain.exception.UserNonexistentException;
import com.mobilebcs.domain.user.UserQualificationSession;
import com.mobilebcs.domain.user.UserQualificationSessionService;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Service;

import java.sql.SQLException;
import java.util.UUID;

@Service
public class QualificationService {

    private final UserQualificationSessionService userQualificationSessionService;

    private final NamedParameterJdbcTemplate namedParameterJdbcTemplate;

    private final static String INSERT = "INSERT INTO QUALIFIED_SCORE(USER_ID,QUALIFICATION_SESSION_ID,IMAGE_SET_ID,SCORE) VALUES(:userId,:qualificationSessionId,(SELECT ID FROM IMAGE_SET WHERE SET_CODE = :imageSetCode),:score)";

    public QualificationService(UserQualificationSessionService userQualificationSessionService, NamedParameterJdbcTemplate namedParameterJdbcTemplate) {
        this.userQualificationSessionService = userQualificationSessionService;
        this.namedParameterJdbcTemplate = namedParameterJdbcTemplate;
    }

    public void qualify(String identificationName, UUID setCode,int score) throws InvalidOperationException, UserNonexistentException, SQLException {
        UserQualificationSession qualificationSessionByUser = userQualificationSessionService.getQualificationSessionByUser(identificationName);

        MapSqlParameterSource paramMap = new MapSqlParameterSource();
        paramMap.addValue("userId", qualificationSessionByUser.getUserId());
        paramMap.addValue("qualificationSessionId", qualificationSessionByUser.getQualificationSessionId());
        paramMap.addValue("imageSetCode", setCode.toString());
        paramMap.addValue("score", score);


            int inserted = namedParameterJdbcTemplate.update(INSERT, paramMap);
            if (inserted == 0) {
                throw new SQLException("Error agregando calificación");
            }


    }
}
