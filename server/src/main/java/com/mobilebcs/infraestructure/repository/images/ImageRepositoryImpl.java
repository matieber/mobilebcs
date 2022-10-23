package com.mobilebcs.infraestructure.repository.images;

import com.mobilebcs.controller.DefaultExceptionHandler;
import com.mobilebcs.domain.exception.InvalidLocalizationException;
import com.mobilebcs.domain.images.ImageRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.jdbc.UncategorizedSQLException;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.stereotype.Repository;

import java.nio.file.Path;
import java.sql.SQLException;
import java.util.Set;
import java.util.UUID;

@Repository
public class ImageRepositoryImpl implements ImageRepository {

    private static final Logger LOG = LoggerFactory.getLogger(ImageRepositoryImpl.class);
    private final String INSERT_SET_QUERY ="INSERT INTO `IMAGE_SET`(SET_CODE) VALUES(:setCode)";
    private final String INSERT_SET_LOCATION_QUERY ="INSERT INTO `IMAGE_SET_LOCATION`(IMAGE_SET_ID,LOCATION_ID,`POSITION`) VALUES(:id," +
            "(SELECT ID FROM LOCATION WHERE CODE = :locationCode)," +
            ":position)";
    private final String INSERT_IMAGE_QUERY ="INSERT INTO IMAGE(IMAGE_SET_ID, PATH) VALUES(:id,:path)";
    private final NamedParameterJdbcTemplate namedParameterJdbcTemplate;
    private final String schema;

    public ImageRepositoryImpl(NamedParameterJdbcTemplate namedParameterJdbcTemplate, @Value("${spring.datasource.schema}") String schema) {
        this.namedParameterJdbcTemplate = namedParameterJdbcTemplate;
        this.schema=schema;
    }

    @Override
    public void saveImages(UUID setCode, String locationCode, Integer position, Set<Path> imagePaths) throws SQLException, InvalidLocalizationException {
        long id = saveImageSet(setCode);
        saveImageSetLocationId(id, locationCode, position);
        for(Path path:imagePaths) {
            saveImage(id,path);
        }
    }

    private long saveImageSet(UUID setId) throws SQLException {
        MapSqlParameterSource paramMap = new MapSqlParameterSource();
        paramMap.addValue("setCode", setId.toString());

        GeneratedKeyHolder holder = new GeneratedKeyHolder();
        int update = namedParameterJdbcTemplate.update(INSERT_SET_QUERY, paramMap, holder);
        if(update==0){
            throw new SQLException("Error insertando set");
        }
        return holder.getKey().longValue();
    }

    private void saveImageSetLocationId(long id, String locationCode, Integer position) throws SQLException, InvalidLocalizationException {
        MapSqlParameterSource paramMap = new MapSqlParameterSource();
        paramMap.addValue("id", id);
        paramMap.addValue("locationCode", locationCode);
        paramMap.addValue("position", position);

        try {
            int update = namedParameterJdbcTemplate.update(INSERT_SET_LOCATION_QUERY, paramMap);
            if(update==0){
                throw new SQLException("Error insertando set");
            }
        }catch (UncategorizedSQLException exception){
            if(exception.getSQLException().getLocalizedMessage().contains("nn_IMAGE_SET_LOCATION_LOCATION_ID")) {
                String cause = "Localización con código " + locationCode + " no existe";
                LOG.error("Error guardando imagen: "+cause);
                throw new InvalidLocalizationException("Error guardando imágen. Localización no existe. ");
            }
            throw exception;
        }

    }

    private void saveImage(Long id, Path path) throws SQLException {
        MapSqlParameterSource paramMap = new MapSqlParameterSource();
        paramMap.addValue("id", id.toString());
        paramMap.addValue("path", path.toString());

        int update = namedParameterJdbcTemplate.update(INSERT_IMAGE_QUERY, paramMap);
        if(update==0){
            throw new SQLException("Error insertando imagen");
        }
    }

}
