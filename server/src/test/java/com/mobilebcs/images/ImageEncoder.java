package com.mobilebcs.images;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.net.URL;

public class ImageEncoder {

    public static byte[] getImage(String imageName, String imageExtension) throws IOException {
        String resourceName = "images/" + imageName + "." + imageExtension;

        ClassLoader classLoader = ImageEncoder.class.getClassLoader();

        URL resource = classLoader.getResource(resourceName);
        BufferedImage img = ImageIO.read(resource);
        return encode(img, imageExtension);
    }

    private static byte[] encode(BufferedImage image, String extension) throws IOException {

        ByteArrayOutputStream bos = new ByteArrayOutputStream();
        ImageIO.write(image, extension, bos);
        byte[] imageBytes = bos.toByteArray();
        bos.close();
        return imageBytes;

    }
}
