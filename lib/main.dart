import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gridlex/authentication/authentication_bloc.dart';
import 'package:gridlex/authentication/authentication_event.dart';
import 'package:gridlex/bloc.dart';
import 'package:gridlex/my_app.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:workmanager/workmanager.dart';

// const myTask = "syncWithTheBackEnd";
// void printHello() async {
//   final DateTime now = DateTime.now();
//   final int isolateId = Isolate.current.hashCode;
//   print("[$now] Hello, world! isolate=${isolateId} function='$printHello'");
//   callbackDispatcher();
// }

void main() async {
  Bloc.observer = EchoBlocObserver();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  WidgetsFlutterBinding.ensureInitialized();
  // Workmanager().initialize(
  //     callbackDispatcher, // The top level function, aka callbackDispatcher
  //     isInDebugMode:
  //         true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
  //     );
  await Firebase.initializeApp();
  // final int helloAlarmID = 0;
  // await AndroidAlarmManager.initialize();
  // BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
  runApp(BlocProvider<AuthenticationBloc>(
    create: (BuildContext context) {
      return AuthenticationBloc()..add(AppStartedEvent());
    },
    child: MyApp(),
  ));
  // await AndroidAlarmManager.periodic(
  //     const Duration(minutes: 1), helloAlarmID, printHello);
}

// [Android-only] This "Headless Task" is run when the Android app
// is terminated with enableHeadless: true
// void backgroundFetchHeadlessTask(HeadlessTask task) async {
//   String taskId = task.taskId;
//   bool isTimeout = task.timeout;
//   if (isTimeout) {
//     // This task has exceeded its allowed running-time.
//     // You must stop what you're doing and immediately .finish(taskId)
//     print("[BackgroundFetch] Headless task timed-out: $taskId");
//     BackgroundFetch.finish(taskId);
//     return;
//   }
//   print('[BackgroundFetch] Headless event received.');
//   // Do your work here...
//   BackgroundFetch.finish(taskId);
// }

void callbackDispatcher() async {
  var isAvailable = await isInternetAvailable();
  if (isAvailable) {
    await Firebase.initializeApp();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString("lstFormData") != null) {
      print("Form Session ===>");
      var lstFormData = prefs.getString("lstFormData");
      List<dynamic> lstJsonData = jsonDecode(lstFormData ?? '');
      //await Firebase.initializeApp();
      for (var i = 0; i < lstJsonData.length; i++) {
        var jsonObj = jsonDecode(lstJsonData[i]);
        DocumentReference? ref = await FirebaseFirestore.instance
            .collection("medicalgridlex")
            .add(jsonObj);
        if (ref != null) {
          lstJsonData.removeAt(i);
          print(jsonObj["image"]);
          if (jsonObj["image"] != null) {
            if (jsonObj["image"].toString().isNotEmpty) {
              final _firebaseStorage = FirebaseStorage.instance;
              File fileTemp = await File(jsonObj["image"].toString()).create();
              // tempFile = fileTemp;
              var filename = jsonObj["image"].toString().split('/').last;
              var snapshot = await _firebaseStorage
                  .ref()
                  .child('images/' + filename)
                  .putFile(fileTemp);
              print(snapshot);
            }
          }
          //yield MedicalSuccessState("Form submitted Successfully");
        }
      }
      prefs.setString("lstFormData", jsonEncode(lstJsonData));
    }
  }
  // Workmanager().executeTask((task, inputData) async {
  //   switch (task) {
  //     case myTask:
  //       print("this method was called from native!");

  //       break;
  //     case Workmanager.iOSBackgroundTask:
  //       print("iOS background fetch delegate ran");
  //       break;
  //   }

  //   //Return true when the task executed successfully or not
  //   return Future.value(true);
  // });
}

Future<bool> isInternetAvailable() async {
  var connectivityResult = await Connectivity().checkConnectivity();
  if (connectivityResult == ConnectivityResult.mobile) {
    // I am connected to a mobile network.
    return true;
  } else if (connectivityResult == ConnectivityResult.wifi) {
    // I am connected to a wifi network.
    return true;
  } else {
    return false;
  }
}

void executeFormSubmitCode() async {
  var isAvailable = await isInternetAvailable();
  if (isAvailable) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString("lstFormData") != null) {
      print("Form Session ===>");
      var lstFormData = prefs.getString("lstFormData");
      List<dynamic> lstJsonData = jsonDecode(lstFormData ?? '');
      await Firebase.initializeApp();
      for (var i = 0; i < lstJsonData.length; i++) {
        var jsonObj = jsonDecode(lstJsonData[i]);
        DocumentReference? ref = await FirebaseFirestore.instance
            .collection("medicalgridlex")
            .add(jsonObj);
        if (ref != null) {
          lstJsonData.removeAt(i);
          print(jsonObj["image"]);
          if (jsonObj["image"] != null) {
            if (jsonObj["image"].toString().isNotEmpty) {
              final _firebaseStorage = FirebaseStorage.instance;
              File fileTemp = await File(jsonObj["image"].toString()).create();
              // tempFile = fileTemp;
              var filename = jsonObj["image"].toString().split('/').last;
              var snapshot = await _firebaseStorage
                  .ref()
                  .child('images/' + filename)
                  .putFile(fileTemp);
              print(snapshot);
            }
          }
          //yield MedicalSuccessState("Form submitted Successfully");
        }
      }
      prefs.setString("lstFormData", jsonEncode(lstJsonData));
    }
  }
}
