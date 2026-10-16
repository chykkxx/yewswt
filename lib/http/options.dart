// 超时时间
class HttpOptions {
  //地址域名前缀
  static const String baseUrl = '';
  //单位时间是ms
  static const Duration connectTimeout = Duration(minutes: 5);
  static const Duration receiveTimeout = Duration(minutes: 5);
  static const Duration sendTimeout = Duration(minutes: 5);
}