package com.mobilebcs.domain.images;

import com.mobilebcs.controller.images.CaravanImage;
import com.mobilebcs.controller.images.CaravanRequest;
import com.mobilebcs.domain.exception.InvalidLocalizationException;
import com.mobilebcs.domain.exception.InvalidOperationException;
import com.mobilebcs.domain.qualifier.NextCaravanMessage;
import com.mobilebcs.domain.session.QualificationSessionService;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.jms.core.JmsTemplate;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.io.IOException;

import java.nio.file.Path;
import java.nio.file.Paths;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@Component
public class ImagesService {

    private String imageQueueName;
    private final QualificationSessionService qualificationSessionService;

    private final ImageRepository imageRepository;
    private final FileService fileService;

    private final JmsTemplate jmsTemplate;

    public ImagesService(QualificationSessionService qualificationSessionService, ImageRepository imageRepository, FileService fileService, JmsTemplate jmsTemplate, @Value("${images.queue.name}") String imageQueueName) {
        this.qualificationSessionService = qualificationSessionService;
        this.imageRepository = imageRepository;
        this.fileService = fileService;
        this.jmsTemplate = jmsTemplate;
        this.imageQueueName =imageQueueName;
    }

    @Transactional(rollbackFor = Exception.class)
    public void save( String locationCode,CaravanRequest caravanRequest) throws IOException, SQLException, InvalidLocalizationException {


        Map<Path,CaravanImage> caravanImages=new HashMap<>();
        Path imageParentPath=Paths.get("session"+locationCode,"position"+caravanRequest.getPosition());
        for(CaravanImage caravanImage:caravanRequest.getImages()){
            Path imagePath=Paths.get(imageParentPath.toString(),caravanImage.getFileName());
            caravanImages.put(imagePath,caravanImage);
        }
        imageRepository.saveImages(caravanRequest.getSetId(),locationCode,caravanRequest.getPosition(),caravanImages.keySet());
        for(Map.Entry<Path,CaravanImage> caravanImage: caravanImages.entrySet()){
            fileService.save(imageParentPath,caravanImage.getValue().getFileName(),caravanImage.getValue().getContent());
        }
        jmsTemplate.convertAndSend(imageQueueName,new NextCaravanMessage(caravanRequest.getPosition(), caravanRequest.getSetId(),locationCode));

    }
}