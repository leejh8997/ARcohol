import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  Future<Map<String, dynamic>?> getPolicyData() async {
    final doc = await FirebaseFirestore.instance
        .collection('privacy_policy')
        .doc('main')
        .get();
    return doc.data();
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = const Color(0xFF1F1F1F);
    final Color orange = const Color(0xFFE94E2B);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("개인정보 처리방침"),
      ),
      body: FutureBuilder(
        future: getPolicyData(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;
          final List sections = data["sections"];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data["title"] ?? '',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  data["subtitle"] ?? '',
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
                const SizedBox(height: 20),
                ...sections.map((section) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        section["heading"] ?? '',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: orange,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // ✅ 일반 항목 리스트
                      if (section.containsKey("content"))
                        ...List.generate(
                          section["content"].length,
                              (i) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: Text(
                              '• ${section["content"][i]}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),

                      // ✅ 테이블 데이터 렌더링
                      if (section.containsKey("table"))
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Table(
                            border: TableBorder.all(color: Colors.white24),
                            columnWidths: const {
                              0: FlexColumnWidth(2),
                              1: FlexColumnWidth(3),
                            },
                            children: [
                              // 테이블 헤더
                              TableRow(
                                decoration:
                                BoxDecoration(color: Colors.grey[700]),
                                children: section["table"]["columns"]
                                    .map<Widget>((col) => Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    col,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ))
                                    .toList(),
                              ),

                              // 테이블 데이터
                              ...List.generate(
                                section["table"]["rows"].length,
                                    (i) {
                                  final row = section["table"]["rows"][i];
                                  return TableRow(
                                    children: section["table"]["columns"]
                                        .map<Widget>((colName) => Padding(
                                      padding:
                                      const EdgeInsets.all(8.0),
                                      child: Text(
                                        row[colName] ?? '',
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ))
                                        .toList(),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 24),
                    ],
                  );
                }).toList(),
                Text(
                  '최종 수정일: ${data["lastUpdated"] ?? ""}',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
