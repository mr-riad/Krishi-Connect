// ignore: depend_on_referenced_packages
import 'package:url_launcher/url_launcher.dart';

Future<void> urlLunch(String url) async {
  final Uri uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
