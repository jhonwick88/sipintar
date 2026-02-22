import 'package:url_launcher/url_launcher.dart';

class WaHelper {
  static String formatPhoneNumber(String phone) {
    String cleanStr = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanStr.startsWith('0')) {
      cleanStr = '62${cleanStr.substring(1)}';
    } else if (cleanStr.startsWith('8')) {
      cleanStr = '62$cleanStr';
    }
    return cleanStr;
  }

  static Future<void> sendMessage(String phone, String text) async {
    final formattedPhone = formatPhoneNumber(phone);
    final encodedText = Uri.encodeComponent(text);
    final url = Uri.parse("https://wa.me/$formattedPhone?text=$encodedText");
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }
}
