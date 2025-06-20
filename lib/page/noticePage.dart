import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class NoticePage extends StatefulWidget {
  const NoticePage({super.key});

  @override
  State<NoticePage> createState() => _NoticePageState();
}

class _NoticePageState extends State<NoticePage> {
  List<dynamic> notices = [];
  int expandedIndex = 0; // 항상 첫 번째 공지를 펼친 상태로 시작

  @override
  void initState() {
    super.initState();
    _loadNotices();
  }

  Future<void> _loadNotices() async {
    final jsonStr = await rootBundle.loadString('assets/notice_list.json');
    final List<dynamic> jsonList = json.decode(jsonStr);
    setState(() {
      notices = jsonList;
      expandedIndex = 0; // ✅ 데이터 로딩 후에도 첫 번째 항목을 펼쳐둠
    });
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF1F1F1F);
    const orange = Color(0xFFE94E2B);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("공지사항"),
      ),
      body: notices.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "새로운 소식과 중요한 변경사항을 확인하세요!",
            style: TextStyle(
              color: orange,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(notices.length, (index) {
            final notice = notices[index];
            final isExpanded = expandedIndex == index;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2C),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  ListTile(
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            notice['title'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Icon(
                          isExpanded
                              ? Icons.expand_less
                              : Icons.expand_more,
                          color: Colors.white70,
                        ),
                      ],
                    ),
                    trailing: Text(
                      notice['date'],
                      style: const TextStyle(color: Colors.white70),
                    ),
                    onTap: () {
                      setState(() {
                        expandedIndex = isExpanded ? -1 : index;
                      });
                    },
                  ),
                  if (isExpanded)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Text(
                        notice['content'],
                        style: const TextStyle(
                          color: Colors.white70,
                          height: 1.5,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
