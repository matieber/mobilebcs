package com.mobilebcs.domain.images;


import com.mobilebcs.domain.exception.InvalidLocalizationException;

import java.nio.file.Path;

import java.sql.SQLException;
import java.util.Set;
import java.util.UUID;

public interface ImageRepository {
    void saveImages(UUID setId, String locationCode, Integer position, Set<Path> imagePaths) throws SQLException, InvalidLocalizationException;

}
