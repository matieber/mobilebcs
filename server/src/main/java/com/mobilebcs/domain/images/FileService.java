package com.mobilebcs.domain.images;

import java.io.IOException;
import java.nio.file.Path;

public interface FileService {
    void save(Path parentPath, String fileName, byte[] value) throws IOException;
}
