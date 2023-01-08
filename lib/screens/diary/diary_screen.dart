import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nigh/apptheme.dart';
import 'package:nigh/screens/Todo/to_do_controller.dart';
import 'package:weekly_date_picker/weekly_date_picker.dart';

import '../../animation/expansion_animation.dart';
import '../../animation/rotate_animation.dart';
import '../../api/model/todo.dart';
import '../../constant.dart';

class DiaryScreen extends ConsumerStatefulWidget {
  const DiaryScreen({super.key});

  @override
  ConsumerState<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends ConsumerState<DiaryScreen> {
  GlobalKey actionKey = GlobalKey();
  bool _weekAnimation = false;
  DateTime _selectedDay = DateTime.now();
  final TextEditingController todoTextEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    actionKey = LabeledGlobalKey('AppBar');
  }

  // void showOverlay(BuildContext context) {
  //   final child = Align(
  //     alignment: Alignment.topCenter,
  //     child: Card(
  //       color: Colors.amber,
  //       child: Row(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           Text(
  //             'Diary',
  //             style: Theme.of(context).textTheme.titleLarge?.copyWith(color: themePrimary),
  //           ).pl(20),
  //           const Icon(
  //             Icons.arrow_downward,
  //             color: Colors.transparent,
  //           )
  //         ],
  //       ),
  //     ).pt(y + height),
  //   );
  //   OverlayEntry entry = OverlayEntry(builder: (context) => child);
  //   Overlay.of(context)?.insert(entry);
  //   // remove the entry
  //   Future.delayed(const Duration(seconds: 2)).whenComplete(() => entry.remove());
  // }

  // void findDropDownData() {
  //   RenderBox? renderBox = actionKey.currentContext?.findRenderObject() as RenderBox?;
  //   Offset? position = renderBox?.localToGlobal(Offset.zero);
  //   height = actionKey.currentContext?.size?.height ?? 0;
  //   width = actionKey.currentContext?.size?.width ?? 0;
  //   x = position?.dx ?? 0;
  //   y = position?.dy ?? 0;
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          GestureDetector(
            onTap: () {
              _weekAnimation = !_weekAnimation;
              setState(() {});
            },
            child: Card(
              elevation: 0,
              margin: EdgeInsets.zero,
              color: Colors.transparent,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(DateFormat.yMMMEd().format(DateTime.now())),
                  RotateAnimation(
                    rotate: _weekAnimation,
                    child: const Icon(
                      Icons.arrow_drop_down,
                      color: textPrimary,
                    ),
                  )
                ],
              ),
            ),
          ),
          ExpansionAnimation(
            expand: _weekAnimation,
            child: WeeklyDatePicker(
              selectedDay: _selectedDay,
              changeDay: (value) => setState(() {
                _selectedDay = value;
              }),
              enableWeeknumberText: false,
              weeknumberColor: themePrimary,
              weeknumberTextColor: textPrimary,
              backgroundColor: backgroundPrimary,
              weekdayTextColor: textSecondary,
              digitsColor: Colors.white,
              selectedBackgroundColor: themePrimary,
              weekdays: const ["Mo", "Tu", "We", "Th", "Fr", "Sat", "Sun"],
              daysInWeek: 7,
            ),
          ),
          const Expanded(child: SizedBox()),
        ],
      ),
    );
  }
}
