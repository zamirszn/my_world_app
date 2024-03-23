// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:object_extract/global.dart';
import 'package:object_extract/object_detection_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            appName,
            style: TextStyle(color: Colors.blue),
          ),
          actions: [
            ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(appLogo))
          ],
          elevation: 0,
        ),
        body: FutureBuilder<PermissionStatus>(
          future: Permission.location.request(),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data == PermissionStatus.granted) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(appLogo)),
                  const SizedBox(
                    height: 40,
                  ),
                  Center(
                    child: Text(
                      """Join My World \n\n 1. Take a Picture \n 2. App will Identify the Picture \n 3. You can share the Picture""",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                          fontSize: 20),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      FloatingActionButton.extended(
                        heroTag: "1",
                        icon: const Icon(Icons.camera_alt_rounded),
                        onPressed: () async {
                          snapImage(context);
                        },
                        label: const Text("Open Camera"),
                      ),
                      FloatingActionButton.extended(
                        heroTag: "2",
                        icon: const Icon(Icons.image_rounded),
                        onPressed: () {
                          imagePicker(context);
                        },
                        label: const Text("Pick an image"),
                      ),
                    ],
                  ),
                ],
              );
            }
            if (snapshot.data == PermissionStatus.permanentlyDenied) {
              // The user opted to never again see the permission request dialog for this
              // app. The only way to change the permission's status now is to let the
              // user manually enable it in the system settings.
              Geolocator.openAppSettings();
            }
            return Center(
              child: SizedBox(
                child: TextButton(
                    onPressed: () {
                      setState(() {});
                    },
                    child: const Text("Grant Location Permission")),
              ),
            );
          },
        ));
  }

  Future<String?> setGeoTagAndTime(XFile image) async {
    Position? location;
    showLoadingDialog("Getting geolocation data", context);

    location = await determinePosition();
    Navigator.pop(context);

    if (location == null) {
      showError("Couldn't get location", context);
      return null;
    }

    String dateTime = getFormattedCameraDateTime();
    String? exifWrittenImagePath = await writeExif(
        dateTime: dateTime, image: image, location: location, context: context);

    
    return exifWrittenImagePath;
  }

  Future<void> snapImage(context) async {
    final XFile? pickedImage =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedImage != null) {
      String? geoTaggedImage = await setGeoTagAndTime(pickedImage);
      if (geoTaggedImage != null) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) =>
              ObjectDetectionScreen(pickedFile: XFile(geoTaggedImage)),
        ));
      }
    }
  }

  Future<void> imagePicker(context) async {
    FilePickerResult? pickedImage = await FilePicker.platform.pickFiles(
      allowCompression: false,
      allowMultiple: false,
      type: FileType.image,
    );

    // XFile? pickedFile = await ImagePicker().pickImage(source: source, requestFullMetadata: true);
    if (pickedImage != null) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ObjectDetectionScreen(
            pickedFile: XFile(pickedImage.files.single.path!)),
      ));
    }
  }
}
