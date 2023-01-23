import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constant.dart';

class OthersScreen extends ConsumerStatefulWidget {
  final String title;
  const OthersScreen({super.key, required this.title});

  static MaterialPageRoute<dynamic> route(String title) => MaterialPageRoute(builder: (context) => OthersScreen(title: title));

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _OthersScreenState();
}

class _OthersScreenState extends ConsumerState<OthersScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SingleChildScrollView(
        child: SafeArea(child: Html(data: widget.title == 'Privacy Policy' ? privacyPolicy : termsOfUse)),
      ),
    );
  }
}
