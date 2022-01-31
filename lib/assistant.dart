import 'package:hooks_riverpod/hooks_riverpod.dart';

class AssistantState {
  bool? isOpen;

  AssistantState({this.isOpen});

  AssistantState copyWith({isOpen}) {
    return AssistantState(isOpen: isOpen ?? this.isOpen);
  }
}

class AssistantInitialState extends AssistantState {
  AssistantInitialState() : super(isOpen: false);
}

class AssistantWelcomeState extends AssistantState {
  AssistantWelcomeState() : super(isOpen: true);
}

class Assistant extends StateNotifier<AssistantState> {
  Assistant() : super(AssistantInitialState());

  void close() {
    state = AssistantInitialState();
  }

  void open() {
    state = AssistantWelcomeState();
  }
}

final assistantStateProvider =
    StateNotifierProvider<Assistant, AssistantState>((ref) {
  return Assistant();
});
