import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router_navigator_crash/nested_screen.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'home_screen.dart';
import 'login_screen.dart';
import 'wrapper.dart';

void main() {
  runApp(App());
}

class Authenticated extends StatelessWidget {
  final Widget child;

  const Authenticated({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrapper(child: child);
  }
}

final container = ProviderContainer();

final _router = GoRouter(
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      name: "login",
      path: "/login",
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
        name: "home",
        path: "/",
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            name: "nested",
            path: "nested",
            builder: (context, state) => const NestedScreen(),
          ),
        ]),
  ],
  refreshListenable: container.read(loginInfoProvider.notifier),
  // redirect to the login page if the user is not logged in
  redirect: (state) {
    // if the user is not logged in, they need to login
    final loggedIn = container.read(loginInfoProvider).loggedIn;
    final loggingIn = state.subloc == '/login';

    // bundle the location the user is coming from into a query parameter
    final fromp = state.subloc == '/' ? '' : '?from=${state.subloc}';
    if (!loggedIn) return loggingIn ? null : '/login$fromp';

    // if the user is logged in, send them where they were going before (or
    // home if they weren't going anywhere)
    if (loggingIn) return state.queryParams['from'] ?? '/';

    // no need to redirect at all
    return null;
  },
  navigatorBuilder: (context, state, child) {
    return UncontrolledProviderScope(
        container: container,

        /// The crash happens when Navigator is injected dynamically
        /// If we remove the condition surrounding the Navigator then it doesn't crash
        /// but I'd like to have this Navigator only when the user is authenticated
        child: container.read(loginInfoProvider).loggedIn
            ? Navigator(
                onPopPage: (route, dynamic result) {
                  route.didPop(result);
                  return false; // don't pop the single page on the root navigator
                },
                pages: [MaterialPage<void>(child: Authenticated(child: child))],
              )
            : child);

    /// This will not crash but is injecting Navigator all the time
    // child: Navigator(
    //   onPopPage: (route, dynamic result) {
    //     route.didPop(result);
    //     return false; // don't pop the single page on the root navigator
    //   },
    //   pages: [MaterialPage<void>(child: Authenticated(child: child))],
    // ));
  },
);

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: "Flutter Demo",
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routeInformationParser: _router.routeInformationParser,
      routerDelegate: _router.routerDelegate,
    );
  }
}

class LoginInfo extends ChangeNotifier {
  bool _loggedIn = false;
  bool get loggedIn => _loggedIn;

  void update(bool loggedIn) {
    _loggedIn = loggedIn;
    notifyListeners();
  }
}

final loginInfoProvider = ChangeNotifierProvider<LoginInfo>((ref) {
  final loginInfo = LoginInfo();

  Future.delayed(const Duration(seconds: 5)).then((value) {
    loginInfo.update(true);
  });

  ref.onDispose(() {
    loginInfo.dispose();
  });

  return loginInfo;
});
