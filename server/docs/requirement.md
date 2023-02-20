# Aplicaciones

* server: posee los servicios rest de los cuales la aplicación móvil consumirá
* aplicación móvil: aplicación usada por los calificadores y viewers
* aplicación batch: consumirá las imágenes tomadas a cada caravana, generará un job y los enviará al server. Cada
  aplicación batch va a estar en un RaspberryPi y va a pertenecer a una locación en particular.

**Ventajas:**

* Tener la aplicación batch y el server separadas permite tener la aplicación batch en un RaspberryPi y el server una
  cualquier dispositivo/servidor dentro de la misma red
* Tener la aplicación batch y el server en un mismo RasberryPi
* Poseer dos locaciones cada una con un RaspberryPi y en este la aplicación batch. Ambas comunicándose con un solo
  server.

**Alcance**

Diagrama de componentes

**Funera de alcance(Versión final)**

El backend fue pensando para ser extensible de la manera que lo muestra el diagrama. Durante la descripción de
requerimientos se mostrará cual es el alcance de cada uno y cual sería los posibles cambios para lograr la versión
final.

# Requerimientos

## Registrar usuario

Se desea registrar usuarios para que quede el histórico de sus interacciones con el sistema. Cualquier consumidor de la
aplicación va a poder registrarse como cualquier tipo de usuario.

**Tipos de usuarios a registrar:**

* Calificadores
* Viewers

**Alcance:**

* Guardar el nombre de usuario en la base de datos con su tipo de usuario
* Validaciones:
    * Error de validación si existe un usuario con el mismo nombre
    * Tipo de usuario no es ni calificador ni viewer

**Fuera de alcance:**

* Implementar mecanismo de registrar usuario con password.
* Limitar que personas pueden registrarse como calificador

## Iniciar sesión de usuario

Obtener usuario registrado para decidir que tipo de usuario es y poder mostrarle la pantalla correspondiente(pantalla de
viewer o calificador)

**Alcance:**

* Obtener de la base de datos el usuario y su tipo
* Validaciones:
    * Error de validación si no existe el usuario

**Fuera de alcance:**

* Implementar mecanismo de inicio de sesión entre aplicación móvil y server con seguridad.
* Mantener historial de sesiones iniciadas en el sistema.

## Inicio de sesión de calificación

Un usuario calificador puede:

* iniciar sesión de calificación para calificar caravanas.
* unirse a una sesión ya iniciada por otro calificador, es decir, en una sesión de calificación pueden calificar 1 o mas
  calificadores.

Un usuario calificador no puede:

* unirse a una sesión de calificación si ya está asociado a otra.

Un usuario viewer no puede:

* iniciar sesión de calificación
* unirse a una sesión de calificación sesión

Datos almacenados en el inicio/unión a una sesión:

* Fecha de inicio de la sesión de calificación.
* Asociación del usuario a la sesión de calificación.
* Asociación de la locación a la que pertenece la sesión de calificación.

Validaciones:

* no puedan haber dos sesiones iniciadas en la misma sesión.
* un clasificador no se puede unir a una sesión finalizada.

**Alcance**

* El calificador que inicia sesión de calificación se unirá automáticamente a la sesión creada.
* Cada calificador va a tener la posibilidad de calificar todas las caravanas, es decir, el sistema no va a poder
  dividir los jobs a calificar entre calificadores.
* Un calificador puede calificar los jobs que arriben al sistema luego de la unión a la sesión de calificación, es
  decir, no va a poder calificar jobs que arriben antes de que el usuario se haya unido/creado la sesión.
* Mantener un histórico en la base de datos de las sesiones iniciadas y que usuarios calificadores estuvieron
  involucrados.

**Diseño**

Un usuario tanto al iniciar sesión de calificación como uniéndose a una sesión de calificación se generará una cola jms
para cada usuario en dicha sesión de calificación. Esta cola recibirá todos los jobs que un calificador va a calificar
en una sesión.

Ventajas de usar colas:

* Los mensajes van a estar en la cola jms sin importar la cantidad de servidores que haya o los reinicios del mismo.
* En futuras versiones del server va a ser posible que los usuarios compartan la misma cola jms para repartirse la
  calificación.

**Fuera de alcance**

* Un usuario puede darse de baja de una sesión de calificación y conectarse a otra.
* Que la sesión pueda configurase para que los usuarios calificadores se repartan las caravanas a calificar. Para lograr
  eso es necesario:
    * que la tabla QUALIFICATION_SESSION tenga un tipo de calificación
    * que el tipo de calificación muestre si los jobs pueden repartirse entre calificadores o que todos los
      calificadores puedan calificar todas las caravanas.

## Generación de jobs de imágenes a calificar

Los jobs de caravanas para calificar van a ser enviados desde una aplicación batch al server.

Composición del job:

* Cada job de imágenes va a estar conformado por la posición de la caravana, las imágenes de la misma y un identificador
  del job en formato UUID.
* Cada job va a estar asignado a una locación en particular

### Aplicación batch

La aplicación batch tendrá una locación preconfigurada que será utilizada para notificar al server de donde proviene el
job.
Leerá las imágenes tomadas a la caravana, armará el job y lo enviará al server. Este procedimiento por cada caravana. La
cantidad de imágenes a tomar serán configuración de la aplicación batch. La primera imagen de cada job (elemento 0 de la
lista) se va a suponer que va a poseer el número de caravana, por lo tanto, está imagen(la primera de la lista) es la
única que se enviará al calificador a la hora de calificar. El resto de imagen van a ser enviadas a los viewers.

### Server

Destino del job:

* se almacenará en la base de datos
    * El job va a persistirse en la base de datos pero las imágenes van a estar en el sistema de archivos donde se
      localiza
      el server. En la base de datos se va a persistir solamente el path del archivo.
    * El path del archivo va a estar conformado de la siguiente manera:
      ${images.path}/location${locationCode}/position${position}/${fileName}
* Los jobs se almacenarán en una cola JMS para luego ser enviados a la cola de los calificadores.

**Diseño**

Los jobs se van a guardar en la base de datos y en la cola JMS.

Ventajas:

* Los jobs se guardan en la base de datos:
    * para mantener un historial del jobs calificados en cada sesión.
    * para permitir recibir jobs antes de iniciar sesión de calificación. De esta manera es posible una vez iniciada la
      sesión de calificación consumir de la base de datos los jobs existentes en dicha locación.

**Fuera de alcance**

Las imágenes van a ser enviadas mediante stream

## Comunicación entre generador de imágenes y generador de jobs de imágenes

Proceso automático que leerá de la cola JMS en la cual el generador de jobs envío el jobs y los reenviará a la cola de
los calificadores.

**Fuera de alcance**

* que los calificadores puedan calificar jobs creados anteriormente a la unión/creación de la sesión de calificación, es
  decir, que los jobs que existan antes del inicio de sesión no serán calificadas por nadie. Aquellos que arriben antes
  de que un calificador se una a una sesión de calificación tampoco van a ser calificados.

Para lograr que los jobs generados antes del inicio de sesión de calificación o antes de que el usuario
se uniera a una sesión existente se envíen a la cola de calificación de cada usuario va a ser necesario que cuando
se inicia sesión de calificación se carguen todos los jobs desde la base de datos en la locación específica de la
sesión a la cola jms del usuario. Esto puede provocar que:

* si se crea la cola del usuario calificador y luego se asigna a la sesión, mientras se envíen los jobs desde la
  base a la cola, puedan llegar nuevos job y se ubiquen antes de los jobs de la base
* si se crea la cola del usuario calificador, se agregan los jobs de la base a la cola y luego se asigna a la
  sesión de calificación, pueden llegar job nuevos que no fueron leídos de la base y que tampoco se haya enviado
  a la cola porque no se había asignado a la sesión.

## Finalizar sesión de calificación

Datos almacenados al finalizar la sesión de calificación:

* Hora del fin de sesión.

Datos a eliminar:

* Se eliminarán las imágenes del server.
* Se eliminará de la base de datos solamente los registros relacionados de la tabla IMAGE.

## Enviar job al calificador

El calificador pedirá el siguiente job a calificar al server, el server leerá el siguiente job de su cola de
calificación y lo enviará.
El job va a poseer solamente una sola imagen y esta será la que tiene prioridad más alta.

Validaciones:

* El usuario debe existir
* El usuario debe ser calificador
* El calificador debe pertenecer a una sesión de calificación

## Enviar job al viewer

Los viewers tendrán configurados en la aplicación móvil cuantas imágenes como máximo desean recibir de cada caravana.

## Aplicación móvil

# Inicio de sesión de clasificación

**Alcance**

La aplicación móvil tendrá configurada la locación a la cual pertenece. Es decir, solo va a existir una locación.
Los clasificadores tendrán la posibilidad de calificar todas las caravanas posteriores a su unión a la sesión.
Los clasificadores podrán unirse a una sesión de clasificación existente.

**Fuera de alcance**

Poder elegir a que locación se desea iniciar sesión de calificación.
El calificador a la hora de iniciar sesión podrá decidir si desea que el tipo de clasificación sea repartida entre
clasificadores o que todos los clasificadores puedan clasificar todas las caravanas.
