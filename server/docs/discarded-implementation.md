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
