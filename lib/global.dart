// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_exif_plugin/constants.dart';
import 'package:flutter_exif_plugin/flutter_exif_plugin.dart';
import 'package:flutter_exif_plugin/tags.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:geolocator/geolocator.dart';

const String appName = "My world";
Color appColor = "#FF7F7F".toColor(); //light red
String appLogo = "assets/logo.png";

// exif = FlutterExif.fromBytes(imageToRead);
//     final result = await exif.getAttribute(TAG_USER_COMMENT);
//     final latlon = await exif.getLatLong();

Future<Map<String, String?>?> readExif(
    {required XFile pickedImage, required BuildContext context}) async {
  try {
    FlutterExif exif = FlutterExif.fromPath(pickedImage.path);
    String? date = await exif.getAttribute(TAG_DATETIME_ORIGINAL);
    Float64List? latLong = await exif.getLatLong();

    return {
      "dateTime": date,
      "latitude": latLong?[0].toString(),
      "longitute": latLong?[1].toString(),
    };
  } catch (e) {
    showError(e, context);
  }

  return null;
}

Future<String?> writeExif(
    {required Position location,
    required String dateTime,
    required XFile image,
    required BuildContext context}) async {
  FlutterExif exif;
  String? writtenFilePath;

  try {
    if (Platform.isAndroid) {
      if (await requestPermission(Permission.manageExternalStorage)) {
        Directory? directory = await getExternalStorageDirectory();
        String newPath = "";
        List<String>? paths = directory?.path.split("/");
        for (int x = 1; x < paths!.length; x++) {
          String folder = paths[x];
          if (folder != "Android") {
            newPath += "/$folder";
          } else {
            break;
          }
        }
        directory = Directory("$newPath/myworld");

        //storage/0/emulated/app_directory

        Uint8List imageBytes = await image.readAsBytes();
        exif = FlutterExif.fromBytes(imageBytes);
        await exif.setLatLong(location.latitude, location.longitude);
        await exif.setAttribute(TAG_DATETIME_ORIGINAL, dateTime);
        await exif.saveAttributes();
        Uint8List? imageToRead = await exif.imageData;

        // now we have exit written data
        // next is to save the data to storage

        String imgDateTime =
            DateFormat("yyyy_MM_dd_HH_mm_ss").format(DateTime.now());

        if (await directory.exists()) {
          // Folder exists, call writeFile method
          String localPath = "${directory.path}/myworld_$imgDateTime.jpg";

          final file = File(localPath);
          File f = await file.writeAsBytes(imageToRead!.cast<int>());
          writtenFilePath = f.path;
        } else {
          // Folder does not exist, create the folder and then call writeFile method
          await directory.create(recursive: true);
          String localPath = "${directory.path}/myworld_$imgDateTime.jpg";

          final file = File(localPath);
          File f = await file.writeAsBytes(imageToRead!.cast<int>());
          writtenFilePath = f.path;
        }

        return writtenFilePath;
      } else {
        Navigator.pop(context);
        showError("Please grant external storage permission to write exif data",
            context);
      }
    }
  } catch (e) {
    showError(e, context);
  }
  return writtenFilePath;
}

String getFormattedCameraDateTime() {
  final DateTime now = DateTime.now();
  final DateFormat formatter = DateFormat("yyyy:MM:dd HH:mm:ss");
  String formatted = formatter.format(now);
  return formatted;
}

/// Determine the current position of the device.
///
/// When the location services are not enabled or permissions
/// are denied the `Future` will return an error.
Future<Position?> determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    Geolocator.openLocationSettings();
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  Position? position;
  try {
    position = await Geolocator.getCurrentPosition(
        timeLimit: const Duration(seconds: 60),
        desiredAccuracy: LocationAccuracy.best);
  } catch (e) {}
  return position;
}

TextStyle appBodyTextStyle(context) {
  return TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 17,
      color: Theme.of(context).textTheme.bodyMedium?.color);
}

extension ColorExtension on String {
  toColor() {
    var hexString = this;
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

String? formatStringDateTime(String? dateString) {
  // Parse the string into a DateTime object
  if (dateString == null) {
    return null;
  }
  DateFormat format = DateFormat('yyyy:MM:dd HH:mm:ss');
  DateTime dateTime = format.parse(dateString);

  // Format the DateTime object
  return DateFormat('MMM d, y hh:mma').format(dateTime);
}

// double? gpsValuesToFloat(IfdValues? values) {
//   if (values == null || values is! IfdRatios) {
//     return null;
//   }

//   double sum = 0.0;
//   double unit = 1.0;

//   for (final v in values.ratios) {
//     sum += v.toDouble() * unit;
//     unit /= 60.0;
//   }

//   return sum;
// }

// Future<Map<String, String?>?> readExif({required XFile pickedImage}) async {
//   try {
//     final fileBytes = File(pickedImage.path).readAsBytesSync();
//     Map tags = await readExifFromBytes(fileBytes);

//     double? lat = gpsValuesToFloat(tags['GPS GPSLatitude']?.values);
//     double? long = gpsValuesToFloat(tags['GPS GPSLongitude']?.values);

//     String? lngRef = tags['GPS GPSLongitudeRef']?.toString();
//     String? latRef = tags['GPS GPSLatitudeRef']?.toString();
//     IfdTag? date = tags["Image DateTime"];

//     if (latRef == 'S' && lat != null) {
//       lat *= -1;
//     }

//     if (lngRef == 'W' && long != null) {
//       long *= -1;
//     }

//     return {
//       "dateTime": date?.printable,
//       "latitude": lat?.toString(),
//       "longitute": long?.toString(),
//     };
//   } catch (e) {
//     showError(e, context);
//   }

//   return null;
// }

Future<bool> requestPermission(Permission permission) async {
  var status = await permission.status;

  if (status.isGranted) {
    // Permission already granted
    return true;
  } else {
    // Request permission
    var result = await permission.request();

    // Return true if the permission is granted, false otherwise
    return result == PermissionStatus.granted;
  }
}

Future<String> getAssetPath(String asset) async {
  final path = await getLocalPath(asset);
  await Directory(dirname(path)).create(recursive: true);
  final file = File(path);
  if (!await file.exists()) {
    final byteData = await rootBundle.load(asset);
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
  }
  return file.path;
}

Future<String> getLocalPath(String path) async {
  return '${(await getApplicationSupportDirectory()).path}/$path';
}

Future<void> showError(Object e, BuildContext context) async {
  debugPrintStack(
    label: e.toString(),
    stackTrace: e is Error ? e.stackTrace : null,
  );

  return showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Error'),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Center(child: Text(e.toString())),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

Future<void> showLoadingDialog(String message, context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return SimpleDialog(
        title: const Text('Info'),
        alignment: Alignment.center,
        children: [
          const CupertinoActivityIndicator(
            radius: 16,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Center(child: Text(message)),
          ),
        ],
      );
    },
  );
}
