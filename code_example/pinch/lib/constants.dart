class LoginFormMessages {
  static const String emailRequiredMessage = "El e-mail es requerido";
  static const String emailInvalidFormatMessage =
      "El formato de e-mail es incorrecto";
  static const String passwordRequiredMessage = "La contraseña es requerida";
  static const String forgotPasswordMessage = "Olvidé mi contraseña";
  static const String fullNameRequiredMessage =
      "El nombre completo es requerido";
  static const String passwordDoesNotMatchMessage =
      "Las contraseñas no coinciden";
  static const String mobilePhoneRequiredMesage =
      "El número de celular es requerido";
  static const String serverConnectionError =
      "No es posible conectar con el servidor";

  static const String invalidRedeemCodeMessage = "Código de canje no válido";
  static const String emptyRedeemCodeMessage = "Código de canje no ingresado";

  static const String enterRedeemCodeLabel = "Usar código de canje";
}

class CreditPageMessages {
  static const String noServerResponse =
      "Lo sentimos, no pudimos conectarnos con el servidor. Por favor, intenta más tarde.";
  static const String availableCreditMessage = "Disponible en tu cuenta aPinch";
  static const String earnedCreditLabel = " obtenido con anuncios";
  static const String boughtCreditLabel = " comprado";
  static const String earnCreditWatchingAdverts =
      "Pincha aquí y obtén créditos mirando publicidad";
}

class FormFieldNames {
  static const String emailForm = "E-mail";
  static const String passwordForm = "Contraseña";
  static const String confirmedPasswordForm = "Confirmar contraseña";
  static const String fullNameForm = "Nombre completo";
  static const String mobilePhoneForm = "Celular";
  static const String loginActionButtonForm = "Ingresar";
  static const String registerActionButtonForm = "Registrarse";
  static const String gotoLoginButtonForm = "Ir a Ingreso";
  static const String gotoRegisterButtonForm = "Registrarse";
  static const String proceedWithRedeemCode = "Ingresar con código de canje";
  static const String redeemCodeForm = "Código de canje";
}

class FormScreenTitle {
  static const String registerFormTitle = "Formulario de Registro";
  static const String loginFormTitle = "Formulario de Ingreso";
}

class CreditFieldNames {
  static const String comprarActionButton = "Comprar";
  static const String verPublicidadActionButton = "Ver publicidad";
}

class WifiConstants {
  static const String openWifi = 'openwireless.org';
  static const String privateWifi = 'OpenWrt24';
  static const String privateWifiPassword = 'baltazar';
  static const String openWifiPassword = '';
}

class AdsConstants {
  static const int timeToWatchAds = 10; //segs
}

class AppURLConstants {
  //static const String domainName = "http://apinch";
  static const String domainName = "http://192.168.1.234";
  //static const String domainName = "http://192.168.0.109";
  static const String mainImageURL = "images/apinch.png";
  static const String loginURL = domainName + ":5555/login";
  static const String registerURL = domainName + ":5555/register";
  static const String creditURL = "/credit";
  static const String domain = domainName + ":5555";
}

class ServiceURLConstants {
  static const String FAS_URL = "http://131.221.0.129:14221";
  //static const String FAS_URL = 'http://168.90.72.46:14221/';
}

class ThresholdValues {
  static const int poolCreditSecInterval = 5;
}

class SplashConstants {
  static const String connectButtonMsg = "";
  static const String mainSplashMsg = "Bienvenido. La aplicación esta cargando";
  static const String backButtonMessage =
      "Al seleccionar \"Si\" la applicación se cerrará";
  static const String backButtonQuestion = "¿Desea cerrar la applicación?";
  static const String backButtonYesAnswer = "Si";
  static const String backButtonNoAnswer = "No";
}
