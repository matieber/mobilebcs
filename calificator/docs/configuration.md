## Configuración

### Configurar host y puerto del server

Posee la configuración de la aplicación server en la variable serverHost y serverPort.
Si serverHost est vacio se usa el valor localhost si es para ios o 10.0.2.2 si es para andriod. De esta manera se usa los default para que funcione por defecto en un ambiente de desarrollo para los emuladores de ios y android.
Si serverPOrt esta vacio se usa el valor 8080


### Configurar python

* Definir path de paython 3.8. Por ejemplo:
    * export PYTHON_3_8_HOME='/home/linuxbrew/.linuxbrew/opt/python@3.8/bin'
    * export PATH=$PATH:$PYTHON_3_8_HOME

### Configuración de escritura

* copiar archivo de assets/empty_image.png al directorio sdcard/Download/ del emulador o celular android.
* Dar el permiso a la aplicacion calificator para poder escribir en el file system desde setting del emulador.
