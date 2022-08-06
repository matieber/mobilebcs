
# Iniciar aplicación

Iniciar cola de mensajería con docker
    docker run -p 61616:61616 -e AMQ_USER=admin -e AMQ_PASSWORD=admin quay.io/artemiscloud/activemq-artemis-broker

Iniciar aplicación: java -jar server.jar

La aplicación inicia en el puerto 8080


# Registrar calificador

## Implementación del commit 489f71c330c44e1324a8db593a3362c324a4f07f

La clase CalificatorController posee el endpoint get /calificator/{name}/next-animal encargado de devolver las imagenes según el usuario. 

Las tecnologías usadas son:
    * org.reactivestreams.Publisher
    * reactor.core.publisher.Flux
    * org.springframework.integration.dsl.IntegrationFlows;

Se creo un topic en el cual cada clasificador tiene una subscripción con su usuario para que la lectura de los mensajes sean independientes.

Problemas encontrados:

 * La creación del Publisher debe hacerse en el starup de la aplicación por lo tanto la subscripción a la cola se realizo en la clase JmsAutoConfiguration con un bean de spring para cada usuario.
 * No pudo encontrarse una manera de crear los publisher dinamicamente cuando inicia sesión el usuario con el endpoint get /user/{name}



