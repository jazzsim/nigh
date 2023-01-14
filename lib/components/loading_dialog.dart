import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nigh/constant.dart';
import '../appsetting.dart';
import 'loading_view.dart';

class LoadingScreen {
  final BuildContext context;

  LoadingScreen(this.context);

  void show() {
    // based
    // show the loading dialog
    showDialog(
        // The user CANNOT close this dialog  by pressing outsite it
        barrierDismissible: false,
        context: context,
        builder: (_) {
          return WillPopScope(
            onWillPop: () async => false,
            child: Padding(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.2),
              child: Consumer(
                builder: (context, ref, child) {
                  return Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    // The background color
                    backgroundColor: themePrimary,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15.0),
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 90.0, minWidth: 120.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // The loading indicator
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 8.0),
                              child: LoadingView(35),
                            ),
                            // Some text
                            const Text(
                              'Loading',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: backgroundPrimary, fontSize: 15.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        });

    // based
    // // show the loading dialog
    // showDialog(
    //     // The user CANNOT close this dialog  by pressing outsite it
    //     barrierDismissible: false,
    //     context: context,
    //     builder: (_) {
    //       return WillPopScope(
    //         onWillPop: () async => false,
    //         child: Dialog(
    //           // The background colorj
    //           backgroundColor: Color.fromARGB(162, 0, 0, 0),
    //           child: Padding(
    //             padding: const EdgeInsets.symmetric(vertical: 20),
    //             child: Column(
    //               mainAxisSize: MainAxisSize.min,
    //               children: const [
    //                 // The loading indicator
    //                 CircularProgressIndicator(),
    //                 SizedBox(
    //                   height: 15,
    //                 ),
    //                 // Some text
    //                 Text('Loading...')
    //               ],
    //             ),
    //           ),
    //         ),
    //       );
    //     });
  }

  void hide() {
    Navigator.of(context).pop();
  }
}
