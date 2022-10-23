package com.mobilebcs.infraestructure.system;

import com.mobilebcs.domain.images.FileService;
import org.apache.commons.io.FileUtils;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.io.File;
import java.io.IOException;
import java.nio.file.Path;
import java.nio.file.Paths;
@Component
public class FileServiceImpl implements FileService {

    private final Path imagesDirectory;

    public FileServiceImpl(@Value("${images.path}") String imagePath){
        this.imagesDirectory = Paths.get(imagePath);
    }

    @Override
    public void save(Path relativeParentDirectory, String fileName, byte[] content) throws IOException {
        Path absoluteParentDirectory=Paths.get(imagesDirectory.toString(),relativeParentDirectory.toString());
        File newFile = new File(absoluteParentDirectory.toString(), fileName);
        File parentFile = newFile.getParentFile();
        if (parentFile.exists() || parentFile.mkdirs()) {
            if (!newFile.exists()) {
                if (newFile.createNewFile()){
                    FileUtils.writeByteArrayToFile(newFile, content);
                } else {
                    throw new IOException("No se puede crear " + newFile + ", es posible que no tenga permisos de escritura o que otro proceso abra el archivo");
                }
            }
        } else {
            throw new IOException("No se puede crear el directorio " + parentFile + ", es posible que no tenga permisos de escritura");
        }
    }
}
