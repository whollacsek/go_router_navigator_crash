import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'assistant.dart';

class MyWidget extends StatelessWidget {
  final String currentRoute;

  const MyWidget(
    this.currentRoute, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 200,
      child: Center(
        child: Text("Wrapped Widget"),
      ),
    );
  }
}

class Wrapper extends ConsumerWidget {
  final Widget child;

  const Wrapper({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentRoute = GoRouter.of(context).location;

    final assistant = ref.read(assistantStateProvider.notifier);

    ref.listen<AssistantState>(assistantStateProvider, (previous, current) {
      if (previous is AssistantInitialState &&
          current is AssistantWelcomeState) {
        showAssistant(context, currentRoute, () => assistant.close());
      }
    });

    return Stack(
      children: [
        child,
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
              child: const Icon(Icons.help_outline),
              onPressed: () {
                assistant.open();
              }),
        ),
      ],
    );
  }

  void showAssistant(
      BuildContext context, String currentRoute, void Function() whenComplete) {
    showModalBottomSheet(
      context: context,
      builder: (context) => MyWidget(currentRoute),
    ).whenComplete(whenComplete);
  }
}
