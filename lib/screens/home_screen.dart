import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nigh/apptheme.dart';
import 'package:nigh/screens/setting_screen.dart';
import 'package:nigh/screens/todo/to_do_screen.dart';
import 'package:nigh/screens/user/login_controller.dart';
import 'package:nigh/screens/user/login_screen.dart';
import 'package:nigh/screens/user/register_screen.dart';
import 'package:nigh/screens/user/user_controller.dart';

import '../../appsetting.dart';
import '../animation/expansion_animation.dart';
import '../api_client.dart';
import '../components/logo.dart';
import '../components/snackbar.dart';
import '../constant.dart';
import 'diary/diary_controller.dart';
import 'diary/edit_diary_screen.dart';
import 'diary/diary_screen.dart';
import 'others_screen.dart';
import 'todo/edit_to_do_screen.dart';
import 'todo/to_do_controller.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  static MaterialPageRoute<dynamic> route() => MaterialPageRoute(builder: (context) => const HomeScreen());

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _loginMessage = false;
  @override
  void initState() {
    super.initState();
    ref.read(appSettingProvider).initializeApp(context).then((value) {
      _loginMessage = ref.read(loginStateNotifierProvider) == LoginState.guest;
    });
  }

  final screens = const [
    ToDoScreen(),
    DiaryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    ref.listen(loginStateNotifierProvider, (previous, next) => next == LoginState.loggedin ? _loginMessage = false : _loginMessage = true);
    return ref.watch(initializedStateProvider)
        ? WillPopScope(
            onWillPop: () async => false,
            child: Scaffold(
                resizeToAvoidBottomInset: true,
                appBar: ref.watch(screenStateProvider) == 0
                    ? AppBar(title: const Text('To Do'), actions: [
                        ref.watch(todoDatetimeStateProvider).day == DateTime.now().day || ref.watch(todoDatetimeStateProvider).isAfter(DateTime.now())
                            ? IconButton(
                                splashRadius: 0.1,
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (_) => const EditTodoScreen(),
                                  ).then((value) {
                                    ref.watch(todoTextEditingStateProvider).text = '';
                                    ref.invalidate(hasReminderStateProvider);
                                    ref.invalidate(reminderStateProvider);
                                  });
                                },
                                icon: const Icon(Icons.add))
                            : const SizedBox()
                      ])
                    : AppBar(
                        title: const Text('Diary'),
                        actions: [IconButton(splashRadius: 0.1, onPressed: () => Navigator.of(context).push(EditDiaryScreen.route()), icon: const Icon(Icons.add))],
                      ),
                drawer: Drawer(
                    backgroundColor: backgroundPrimary,
                    child: SafeArea(
                      child: Column(
                        children: [
                          const Logo(
                            height: 180,
                          ).pb(20),
                          const Divider(
                            color: textSecondary,
                            height: 0,
                          ),
                          Column(
                            children: [
                              ListTile(
                                  title: RichText(
                                      maxLines: 3,
                                      text: TextSpan(
                                          text: 'Logged in as ',
                                          style: ref
                                              .watch(textThemeProvider(context))
                                              .bodyMedium
                                              ?.copyWith(fontSize: ref.watch(textThemeProvider(context)).titleMedium?.fontSize, color: textPrimary),
                                          children: [
                                            TextSpan(
                                                text: ref.watch(userNotifierProvider).username,
                                                style: ref.watch(textThemeProvider(context)).titleMedium?.copyWith(color: themePrimary))
                                          ]))),
                            ],
                          ),
                          const Divider(
                            color: textSecondary,
                            height: 0,
                          ),
                          ref.watch(loginStateNotifierProvider) == LoginState.loggedin
                              ? // Setting section
                              Column(
                                  children: [
                                    ListTile(
                                      enabled: false,
                                      title: Text(
                                        'Account',
                                        style: ref.watch(textThemeProvider(context)).titleMedium?.copyWith(color: themePrimary),
                                      ),
                                    ),
                                    ListTile(
                                      title: const Text(
                                        'Setting',
                                      ),
                                      onTap: () => Navigator.of(context).push(SettingScreen.route()),
                                    )
                                  ],
                                )
                              : const SizedBox(),
                          ref.watch(loginStateNotifierProvider) != LoginState.loggedin
                              ? Column(
                                  children: [
                                    const Divider(
                                      color: textSecondary,
                                      height: 0,
                                    ),
                                    ListTile(
                                      enabled: false,
                                      title: Text(
                                        'Account',
                                        style: ref.watch(textThemeProvider(context)).titleMedium?.copyWith(color: themePrimary),
                                      ),
                                    ),
                                    ListTile(
                                      title: const Text(
                                        'Login',
                                        style: TextStyle(color: textPrimary),
                                      ),
                                      onTap: () => Navigator.of(context).push(LoginScreen.route()),
                                    ),
                                    ListTile(
                                      title: const Text(
                                        'Register',
                                        style: TextStyle(color: textPrimary),
                                      ),
                                      onTap: () => Navigator.of(context).push(RegisterScreen.route()),
                                    ),
                                  ],
                                )
                              : const SizedBox(),
                          const Divider(
                            color: textSecondary,
                            height: 0,
                          ),
                          ListTile(
                            enabled: false,
                            title: Text(
                              'Others',
                              style: ref.watch(textThemeProvider(context)).titleMedium?.copyWith(color: themePrimary),
                            ),
                          ),
                          ListTile(
                            title: const Text(
                              'Privacy Policy',
                              style: TextStyle(color: textPrimary),
                            ),
                            onTap: () => Navigator.of(context).push(OthersScreen.route('Privacy Policy')),
                          ),
                          ListTile(
                              title: const Text(
                                'Terms of Use',
                                style: TextStyle(color: textPrimary),
                              ),
                              onTap: () => Navigator.of(context).push(OthersScreen.route('Terms of Use'))),
                          const SizedBox().exp(),
                          ref.watch(loginStateNotifierProvider) == LoginState.loggedin
                              ? Column(
                                  children: [
                                    const Divider(
                                      color: textPrimary,
                                    ),
                                    ListTile(
                                      title: const Text(
                                        'Log Out',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                      onTap: () async {
                                        ref.watch(loginStateNotifierProvider.notifier).loading();
                                        await globalSharedPrefs.setString('api_key', '').then((value) async {
                                          await ApiClient.setHeader();
                                        });
                                        await ref.watch(loginStateNotifierProvider.notifier).initLogin();
                                        ref.invalidate(screenStateProvider);
                                        ref.invalidate(todoNotifierProvider);
                                        await ref.read(todoNotifierProvider.notifier).getTodos(ref.watch(todoDatetimeStateProvider).toString());
                                        ref.invalidate(diaryNotifierProvider);
                                        await ref.read(diaryNotifierProvider.notifier).getDiaries(ref.watch(diaryDatetimeStateProvider).toString());
                                        if (!mounted) return;
                                        messageSnackbar(context, 'Logged out');
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                )
                              : const SizedBox(),
                        ],
                      ),
                    )),
                body: IndexedStack(
                  index: ref.watch(screenStateProvider),
                  children: screens,
                ),
                bottomNavigationBar: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ExpansionAnimation(
                      expand: _loginMessage,
                      child: Container(
                          color: themePrimary,
                          child: Stack(children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'You are not logged in.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: backgroundPrimary),
                                ).p(15),
                                TextButton(
                                    onPressed: () => Navigator.of(context).push(LoginScreen.route()),
                                    style: TextButton.styleFrom(backgroundColor: backgroundPrimary, elevation: 0),
                                    child: Text(
                                      'Login now',
                                      style: ref.watch(textThemeProvider(context)).bodyMedium?.copyWith(color: Colors.white),
                                      // ))
                                    ).pLTRB(10, 0, 10, 0))
                              ],
                            ),
                            Positioned(
                                right: 5,
                                child: IconButton(
                                    splashRadius: 0.1,
                                    onPressed: () {
                                      _loginMessage = !_loginMessage;
                                      setState(() {});
                                    },
                                    icon: const Icon(
                                      Icons.close,
                                      color: backgroundPrimary,
                                    )))
                          ])),
                    ),
                    SizedBox(
                      height: 70,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                    child: GestureDetector(
                                  onTap: (() {
                                    if (ref.watch(screenStateProvider) != 0) ref.watch(screenStateProvider.notifier).state = 0;
                                  }),
                                  child: Container(
                                    color: ref.watch(screenStateProvider) == 0 ? themePrimary : backgroundPrimary,
                                    margin: EdgeInsets.zero,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: ref.watch(screenStateProvider) == 0
                                          ? [const Icon(Icons.today, color: backgroundPrimary), const Text('Todo', style: TextStyle(color: backgroundPrimary))]
                                          : [
                                              const Icon(Icons.today_outlined, color: textSecondary),
                                              const Text(
                                                'Todo',
                                                style: TextStyle(color: textSecondary),
                                              )
                                            ],
                                    ),
                                  ),
                                )),
                                Expanded(
                                    child: GestureDetector(
                                  onTap: (() {
                                    if (ref.watch(screenStateProvider) != 1) ref.watch(screenStateProvider.notifier).state = 1;
                                  }),
                                  child: Container(
                                    color: ref.watch(screenStateProvider) == 1 ? themePrimary : backgroundPrimary,
                                    margin: EdgeInsets.zero,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: ref.watch(screenStateProvider) == 1
                                          ? [
                                              const Icon(
                                                Icons.book,
                                                color: backgroundPrimary,
                                              ),
                                              const Text('Diary', style: TextStyle(color: backgroundPrimary)),
                                            ]
                                          : [
                                              const Icon(
                                                Icons.book_outlined,
                                                color: textSecondary,
                                              ),
                                              const Text(
                                                'Diary',
                                                style: TextStyle(color: textSecondary),
                                              )
                                            ],
                                    ),
                                  ),
                                )),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )))
        : Scaffold(
            body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  height: 200,
                ).pb(20),
                const Text('Loading...').pb(10),
              ],
            ),
          ));
  }
}
