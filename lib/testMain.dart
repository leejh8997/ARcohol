import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'firebase_options.dart'; // Firebase CLI로 생성된 설정

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: GeminiExamplePage(),
    );
  }
}

class GeminiExamplePage extends StatefulWidget {
  const GeminiExamplePage({super.key});

  @override
  State<GeminiExamplePage> createState() => _GeminiExamplePageState();
}

class _GeminiExamplePageState extends State<GeminiExamplePage> {
  String _responseText = 'Gemini에게 질문 중...';

  @override
  void initState() {
    super.initState();
    _askCocktailQuestion();
  }

  Future<void> _askCocktailQuestion() async {
    try {
      final model = FirebaseAI.googleAI().generativeModel(model: 'gemini-1.5-flash');

      final prompt = [
        Content.text('보드카와 오렌지 주스를 사용한 칵테일을 추천해줘. 이름, 만드는 방법, 맛의 특징도 알려줘.')
      ];

      final response = await model.generateContent(prompt);

      setState(() {
        _responseText = response.text ?? '응답이 없습니다.';
      });
    } catch (e) {
      setState(() {
        _responseText = '에러 발생: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI 칵테일 추천')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(child: Text(_responseText)),
      ),
    );
  }
}
