import 'package:http/http.dart' as http;

class NetError extends Error {
  http.Response response;
  int statusCode;
  String message;
  Error error;

  NetError({this.response, this.error});

  @override
  String toString() {
    if (response?.statusCode == null) {
      statusCode = 1000;
    } else {
      statusCode = response.statusCode;
    }

    if (response?.body == null) {
      message = "Network error";
    } else {
      message = response.body;
    }

    return "status code = $statusCode, message = $message, raw error = $error";
  }


}