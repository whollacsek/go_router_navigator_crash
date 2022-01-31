import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: [
            TextButton(
                onPressed: () {
                  context.go("/nested");
                },
                child: const Text("Open Nested Screen"))
          ],
        ),
      ),
    );
  }
}
