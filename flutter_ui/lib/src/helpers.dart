import 'dart:io' show Platform;

// get correct uri based on platform
class helpers{
 static String getUri() {
    if (Platform.isAndroid){
      return 'http://10.0.2.2:5000';
    }
    else if (Platform.isIOS){
     return 'http://127.0.0.1:5000';
    }
    return "";
  }
}