import 'package:flutter/material.dart';
import 'package:convex_flutter/convex_flutter.dart';

class DiaryPage extends StatelessWidget {
  const DiaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ❌ už není const
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final client = ConvexClient.instance;

            final count = await client.query('users:getMemberCount', {});
            debugPrint('USERS COUNT: $count');
          },
          child: const Text('TEST CONVEX'),
        ),
      ),
    );
  }
}
