import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    /// 根据DioError创建HttpException
    HttpException httpException = HttpException.create(err);

    /// dio默认的错误实例，如果是没有网络，只能得到一个未知错误，无法精准的得知是否是无网络的情况
    /// 这里对于断网的情况，给一个特殊的code和msg
    if (err.type == DioErrorType.values) {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        httpException = HttpException(code: -100, msg: 'None Network.');
      }
    }

    /// 将自定义的HttpException
    err.response?.data = httpException;

    /// 调用父类，回到dio框架
    super.onError(err, handler);
  }
}

//
class HttpException implements Exception {
  final int code;
  final String msg;

  HttpException({
    this.code = -1,
    this.msg = 'unknow error',
  });

  @override
  String toString() {
    return 'Http Error [$code]: $msg';
  }

  factory HttpException.create(DioError error) {
    print(error);
    /// dio异常
    switch (error.type) {
      case DioErrorType.cancel:
        {
          return HttpException(code: -1, msg: 'request cancel');
        }
      case DioErrorType.connectionTimeout:
        {
          return HttpException(code: -1, msg: 'connect timeout');
        }
      case DioErrorType.sendTimeout:
        {
          return HttpException(code: -1, msg: 'send timeout');
        }
      case DioErrorType.receiveTimeout:
        {
          return HttpException(code: -1, msg: 'receive timeout');
        }
      case DioErrorType.badResponse:
        {
          try {
            int statusCode = error.response?.statusCode ?? 0;
            // String errMsg = error.response.statusMessage;
            // return ErrorEntity(code: errCode, message: errMsg);
            switch (statusCode) {
              case 400:
                {
                  return HttpException(
                      code: statusCode, msg: 'Request syntax error');
                }
              case 401:
                {
                  return HttpException(
                      code: statusCode, msg: 'Without permission');
                }
              case 403:
                {
                  return HttpException(
                      code: statusCode, msg: 'Server rejects execution');
                }
              case 404:
                {
                  return HttpException(
                      code: statusCode, msg: 'Unable to connect to server');
                }
              case 405:
                {
                  return HttpException(
                      code: statusCode, msg: 'The request method is disabled');
                }
              case 500:
                {
                  return HttpException(
                      code: statusCode, msg: 'Server internal error');
                }
              case 502:
                {
                  return HttpException(
                      code: statusCode, msg: 'Invalid request');
                }
              case 503:
                {
                  return HttpException(
                      code: statusCode, msg: 'The server is down.');
                }
              case 505:
                {
                  return HttpException(
                      code: statusCode, msg: 'HTTP requests are not supported');
                }
              default:
                {
                  return HttpException(
                      code: statusCode,
                      msg: error.response?.statusMessage ?? 'unknow error');
                }
            }
          } on Exception catch (_) {
            return HttpException(code: -1, msg: 'unknow error');
          }
        }
      default:
        {
          return HttpException(code: -1, msg: error.response?.data);
        }
    }
  }
}