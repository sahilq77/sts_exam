import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CCAvenueService {
  static const String _merchantId = "4396482";
  static const String _accessCode = "AVTM82MG77CN84MTNC";
  static const String _workingKey =
      "YOUR_WORKING_KEY"; // Get this from CCAvenue dashboard
  static const String _baseUrl = "https://secure.ccavenue.com";

  static const String _testUrl = "https://test.ccavenue.com";
  static const bool _isTestMode = true; // Set to false for production

  static String get _apiUrl => _isTestMode ? _testUrl : _baseUrl;

  // Generate checksum for request
  static String _generateChecksum({
    required String workingKey,
    required Map<String, String> params,
  }) {
    String paramString = '';
    params.forEach((key, value) {
      paramString += '$key=$value';
    });
    var keyBytes = utf8.encode(workingKey);
    var paramBytes = utf8.encode(paramString);
    var hash = Hmac(sha256, keyBytes);
    var digest = hash.convert(paramBytes);
    return digest.toString();
  }

  // Verify checksum for response
  static bool _verifyChecksum({
    required String workingKey,
    required Map<String, String> params,
    required String receivedChecksum,
  }) {
    String paramString = '';
    params.forEach((key, value) {
      if (key != 'checksum') {
        paramString += '$key=$value';
      }
    });
    var keyBytes = utf8.encode(workingKey);
    var paramBytes = utf8.encode(paramString);
    var hash = Hmac(sha256, keyBytes);
    var digest = hash.convert(paramBytes);
    return digest.toString() == receivedChecksum;
  }

  // Encrypt parameters for CCAvenue
  static String _encrypt(Map<String, String> params, String workingKey) {
    try {
      String postData = '';
      params.forEach((key, value) {
        postData += '$key=$value';
      });

      var keyBytes = utf8.encode(workingKey);
      var dataBytes = utf8.encode(postData);

      // Simple XOR encryption (CCAvenue specific)
      List<int> encrypted = [];
      for (int i = 0; i < dataBytes.length; i++) {
        encrypted.add(dataBytes[i] ^ keyBytes[i % keyBytes.length]);
      }

      // Convert to hex
      StringBuffer hex = StringBuffer();
      for (int i = 0; i < encrypted.length; i++) {
        hex.write(encrypted[i].toRadixString(16).padLeft(2, '0'));
      }

      return hex.toString();
    } catch (e) {
      debugPrint('Encryption error: $e');
      return '';
    }
  }

  // Decrypt response
  static String _decrypt(String encryptedData, String workingKey) {
    try {
      var keyBytes = utf8.encode(workingKey);
      List<int> encryptedBytes = [];

      // Convert hex to bytes
      for (int i = 0; i < encryptedData.length; i += 2) {
        encryptedBytes.add(
          int.parse(encryptedData.substring(i, i + 2), radix: 16),
        );
      }

      // XOR decryption
      StringBuffer decrypted = StringBuffer();
      for (int i = 0; i < encryptedBytes.length; i++) {
        decrypted.writeCharCode(
          encryptedBytes[i] ^ keyBytes[i % keyBytes.length],
        );
      }

      return utf8.decode(decrypted.toString().codeUnits);
    } catch (e) {
      debugPrint('Decryption error: $e');
      return '';
    }
  }

  static Future<Map<String, dynamic>> initiatePayment({
    required String orderId,
    required String amount,
    required String currency,
    required String redirectUrl,
    required String cancelUrl,
    required String customerId,
    String? customerEmail,
    String? customerPhone,
    String? billingName,
    String? billingAddress,
    String? billingCity,
    String? billingState,
    String? billingZip,
    String? billingCountry,
  }) async {
    try {
      final params = <String, String>{
        'merchant_id': _merchantId,
        'order_id': orderId,
        'amount': amount,
        'currency': currency,
        'redirect_url': redirectUrl,
        'cancel_url': cancelUrl,
        'language': 'EN',
        'integration_transact_mode': 'iframe',
        'billing_cust_id': customerId,
        'billing_cust_name': billingName ?? 'Customer',
        'billing_cust_addr': billingAddress ?? '',
        'billing_cust_country': billingCountry ?? 'India',
        'billing_cust_state': billingState ?? '',
        'billing_cust_city': billingCity ?? '',
        'billing_zip': billingZip ?? '',
        'billing_cust_tel': customerPhone ?? '',
        'billing_cust_eml': customerEmail ?? '',
        'billing_cust_notes': 'CCAvenue Payment',
      };

      final encryptedData = _encrypt(params, _workingKey);
      final checksum = _generateChecksum(
        workingKey: _workingKey,
        params: {'encRequest': encryptedData},
      );

      final paymentUrl =
          '$_apiUrl/transaction/transaction.do?command=initiateTransaction';

      final response = await http.post(
        Uri.parse(paymentUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'encRequest': encryptedData,
          'access_code': _accessCode,
          'checksum': checksum,
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return {
          'success': true,
          'paymentUrl':
              '$_apiUrl/transaction/index.php?command=initiateTransaction',
          'encRequest': encryptedData,
          'accessCode': _accessCode,
          'checksum': checksum,
          'response': responseData,
        };
      } else {
        return {
          'success': false,
          'error': 'Payment initiation failed: ${response.statusCode}',
        };
      }
    } catch (e) {
      debugPrint('Payment initiation error: $e');
      return {'success': false, 'error': 'Payment initiation error: $e'};
    }
  }
}
