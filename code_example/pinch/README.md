# apinch

A new Flutter application.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Bajar paquetes necesarios
Ir a pubspec.yaml y Pub get que instala paquetes necesarios

## Instalar en celular Host go
https://play.google.com/store/apps/details?id=dns.hosts.server.change&hl=es_AR&gl=US

y definir en el archivo hosts de "ip servidor python mock_server"  apinch
y poner a correr hosts go

## Comentarios
Prototipo fase 1. Proyecto para Android Studio. La app la corrés como cualquier app Flutter, es decir conectando el celu por USB y haciendo "run".
Por terminal desde Android studio hay que levantar un servidor que hice en Python con "python3 mock_server.py". Permite registrar usuarios de forma persistente (graba a un file .txt con cuerpo en formato json) y loguear usuarios.

Para usar la app, se va registrarte. Tiene doble validación de password y formato de email. Una vez registrado se puede  loguear (carga las credenciales automáticamente ahí, y cuando se vuelva a abrir la app). Si te logueás te lleva a la pantalla principal (con tabs). Con el candadito de arriba a la derecha de deslogueás, aunque de lado server aún no hay un signout (solo login y register). Se realizan varios chequeos de error ante problemas de conexión, logueo sin usuario registrado, etc etc

## Info util
https://drive.google.com/drive/u/0/folders/1N1YqBGSHINtQs2jz9J5ZgTmyNCIg0Kc4
