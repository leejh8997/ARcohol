import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:portone_flutter/iamport_certification.dart';
import 'package:portone_flutter/model/certification_data.dart';

class Certification extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IamportCertification(
      appBar: AppBar(
        title: const Text('포트원 V1 본인인증'),
      ),
      initialChild: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            SizedBox(height: 15),
            Text('잠시만 기다려주세요...', style: TextStyle(fontSize: 20)),
          ],
        ),
      ),
      userCode: 'imp78610854',
      data: CertificationData(
        pg: 'inicis_unified',
        merchantUid: 'mid_${DateTime.now().millisecondsSinceEpoch}',
        mRedirectUrl: 'https://arcohol-20250609.web.app/cert',
      ),
      callback: (Map<String, dynamic> result) {
        Navigator.pop(context, result);
      },
    );
  }
}
