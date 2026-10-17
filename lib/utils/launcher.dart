import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens external apps (browser, dialer, email, WhatsApp) and reports failures.
class Launcher {
  Launcher._();

  static Future<bool> _open(BuildContext context, Uri uri, {String? failMessage}) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    var ok = false;
    try {
      ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      ok = false;
    }
    if (!ok) {
      messenger?.showSnackBar(SnackBar(content: Text(failMessage ?? 'Could not open $uri')));
    }
    return ok;
  }

  static Future<bool> url(BuildContext context, String url) {
    final uri = Uri.tryParse(url.trim());
    if (uri == null || url.trim().isEmpty) return Future.value(false);
    return _open(context, uri);
  }

  /// Opens an Instagram or YouTube link in its app when installed (so the
  /// profile or video opens directly), otherwise in the browser.
  static Future<bool> social(BuildContext context, String url) async {
    final uri = Uri.tryParse(url.trim());
    if (uri == null || url.trim().isEmpty) return false;
    try {
      if (await launchUrl(uri, mode: LaunchMode.externalNonBrowserApplication)) return true;
    } catch (_) {}
    if (!context.mounted) return false;
    return _open(context, uri);
  }

  static Future<bool> call(BuildContext context, String phone) =>
      _open(context, Uri(scheme: 'tel', path: _phone(phone)), failMessage: 'No app can place calls');

  /// Builds the mailto query by hand: [Uri.queryParameters] encodes spaces
  /// as "+", which many mail apps show literally.
  static Future<bool> email(BuildContext context, String to, {String subject = '', String body = ''}) {
    final query = [
      if (subject.isNotEmpty) 'subject=${Uri.encodeComponent(subject)}',
      if (body.isNotEmpty) 'body=${Uri.encodeComponent(body)}',
    ].join('&');
    return _open(
      context,
      Uri.parse('mailto:${to.trim()}${query.isEmpty ? '' : '?$query'}'),
      failMessage: 'No email app found',
    );
  }

  /// wa.me opens WhatsApp if installed, otherwise WhatsApp Web.
  static Future<bool> whatsapp(BuildContext context, String number, {String text = ''}) {
    final digits = number.replaceAll(RegExp(r'[^0-9]'), '');
    final query = text.isEmpty ? '' : '?text=${Uri.encodeComponent(text)}';
    return _open(context, Uri.parse('https://wa.me/$digits$query'), failMessage: 'Could not open WhatsApp');
  }

  static String _phone(String s) => s.replaceAll(RegExp(r'[^0-9+]'), '');
}
