# Requerimientos descartados

## Registrar calificador versión descartada

### Implementación del commit b3345ea2ea0029c63897d11c8b6b33c4d258f8d2

La clase CalificatorController posee el endpoint get /calificator/{name}/next-animal encargado de devolver las imagenes según el usuario.

Las tecnologías usadas son:
* org.reactivestreams.Publisher
* reactor.core.publisher.Flux
* org.springframework.integration.dsl.IntegrationFlows;

Se creo un topic en el cual cada clasificador tiene una subscripción con su usuario para que la lectura de los mensajes sean independientes.

Problemas encontrados:

* La creación del Publisher debe hacerse en el starup de la aplicación por lo tanto la subscripción a la cola se realizo en la clase JmsAutoConfiguration con un bean de spring para cada usuario.
* No pudo encontrarse una manera de crear los publisher dinamicamente cuando inicia sesión el usuario con el endpoint get /user/{name}

## Multiple servers

La aplicación no permite multiples servers y se requiere la siguientes implementaciones para lograrlo:

Si hay dos aplicaciones va a haber dos ImageListener. Esto producirá:

* que los viewer se conecten a un solo server y que le lleguen los jobs que reciba dicho ImageListener. Se podría utirlizar stomp connection con rabbit mq como broker y administrar el envío de jobs hacia los viewer.
* que los calificadores reciban jobs duplicados debido a que cada ImageListener lee de la base los calificadores registrados y envía los jobs.

## Reestablecer estado de la aplicación móvil

Si la aplicación móvil pierde su estado (por ejemplo si se fuerza la salida de la aplicación o si se reinicia el móvil), No se podrá finalizar la sesión de calificación

## Persistencia de imágenes

* Las imágenes no quedarán asociadas a una sesión de calificación debido a que pueden recibirse imágenes donde no se ha comenzado la sessión. Las imágenes quedarán asociadas a una locación en una fecha dada. Si la sessión ha comenzado, cuando el clasificador califique la imágen, quedará asociada a una sesión de clasificación.
* Las imágenes que lleguen para clasificar por el calificador serán aquellas que arriben al server una vez comenzada la calificación. Pero la predicción automática será realizada y el observador podrá visualizarla.  