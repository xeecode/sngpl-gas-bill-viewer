import 'dart:typed_data';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

import '../models/bill_data.dart';
import 'bill_parser.dart';
import 'sngpl_exception.dart';

/// Talks to sngpl.com.pk. One instance = one session (cookies are kept inside),
/// because the captcha is tied to the session that requested it.
class SngplService {
  SngplService() {
    _dio = Dio(BaseOptions(
      baseUrl: base,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 25),
      headers: {'User-Agent': _userAgent},
      validateStatus: (s) => s != null && s < 500,
    ));
    _dio.interceptors.add(CookieManager(_jar));
  }

  static const base = 'https://www.sngpl.com.pk';
  static const loginPath = '/login.jsp?mdids=85';
  static const captchaPath = '/captcha-image.jpg';
  static const viewBillPath = '/viewbill';

  static const _userAgent =
      'Mozilla/5.0 (Linux; Android 14; Pixel 9 Pro) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/155.0.0.0 Mobile Safari/537.36';

  final CookieJar _jar = CookieJar();
  late final Dio _dio;

  /// Starts a fresh session and returns the first captcha image.
  Future<Uint8List> loadCaptcha() async {
    try {
      await _dio.get<String>(
        loginPath,
        options: Options(responseType: ResponseType.plain),
      );
      return await _captchaImage(captchaPath);
    } on DioException catch (e) {
      throw _friendly(e);
    }
  }

  /// New captcha inside the same session.
  Future<Uint8List> refreshCaptcha() async {
    try {
      final rand = DateTime.now().millisecondsSinceEpoch;
      return await _captchaImage('$captchaPath?rand=$rand');
    } on DioException catch (e) {
      throw _friendly(e);
    }
  }

  Future<Uint8List> _captchaImage(String path) async {
    final res = await _dio.get<List<int>>(
      path,
      options: Options(
        responseType: ResponseType.bytes,
        headers: {'Referer': '$base$loginPath'},
      ),
    );
    final data = res.data;
    if (res.statusCode != 200 || data == null || data.length < 100) {
      throw const SngplException(
        'Could not load the captcha. Tap refresh to try again.',
      );
    }
    return Uint8List.fromList(data);
  }

  Future<BillData> fetchBill(String consumer, String captcha) async {
    try {
      final res = await _dio.post<String>(
        viewBillPath,
        data: {
          'proc': 'viewbill',
          'consumer': consumer,
          'contype': 'NewCon',
          'txtCaptcha': captcha,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          responseType: ResponseType.plain,
          headers: {'Referer': '$base$loginPath', 'Origin': base},
        ),
      );
      if (res.statusCode != 200) {
        throw const SngplException(
          'SNGPL did not accept the request. Try again in a moment.',
        );
      }
      return BillParser.parse(res.data ?? '');
    } on DioException catch (e) {
      throw _friendly(e);
    }
  }

  SngplException _friendly(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const SngplException(
          'SNGPL is taking too long to respond. Try again.',
        );
      case DioExceptionType.connectionError:
        return const SngplException(
          'No connection. Check your internet and try again.',
        );
      default:
        return const SngplException(
          'Something went wrong while talking to SNGPL. Try again.',
        );
    }
  }
}
