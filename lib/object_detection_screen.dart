// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:object_extract/global.dart';
import 'package:object_extract/share_image_info_screen.dart';
import 'package:share_plus/share_plus.dart';

class ObjectDetectionScreen extends StatefulWidget {
  const ObjectDetectionScreen({super.key, required this.pickedFile});
  final XFile pickedFile;

  @override
  State<ObjectDetectionScreen> createState() => _ObjectDetectionScreenState();
}

class _ObjectDetectionScreenState extends State<ObjectDetectionScreen> {
  ObjectDetector? _objectDetector;
  final DetectionMode _mode = DetectionMode.single;
  bool _canProcess = false;
  bool _isBusy = false;

  String? detectedObjectsTexts;

  @override
  void dispose() {
    _canProcess = false;
    _objectDetector?.close();
    super.dispose();
  }

  @override
  void initState() {
    startProcessingImage();
    super.initState();
  }

  void startProcessingImage() async {
    await _initializeDetector();
    if (_canProcess) {
      await _processImage(InputImage.fromFilePath(widget.pickedFile.path));
    }
  }

  Future<void> _initializeDetector() async {
    _objectDetector?.close();
    _objectDetector = null;

    try {
      String modelPath = await getAssetPath('assets/ml/object_labeler.tflite');
      final options = LocalObjectDetectorOptions(
        mode: _mode,
        modelPath: modelPath,
        classifyObjects: true,
        multipleObjects: true,
      );
      _objectDetector = ObjectDetector(options: options);

      _canProcess = true;
    } catch (e) {
      showError(e, context);
    }
  }

  Future<void> _processImage(InputImage inputImage) async {
    if (_objectDetector == null || !_canProcess || _isBusy) return;
    try {
      showLoadingDialog("Analyzing image, Please wait", context);

      final objects = await _objectDetector?.processImage(inputImage);

      Set<String> uniqueLabels = <String>{};

      for (final object in objects!) {
        // Add each label to the set to ensure uniqueness
        uniqueLabels.addAll(object.labels.map((e) => e.text));
      }

// Convert the set to a list and use join to concatenate the labels with commas and spaces
      List<String> labelsList = uniqueLabels.toList();
      detectedObjectsTexts = labelsList.join(', ');
      if (detectedObjectsTexts!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No object found in this image")));
      }
      Navigator.pop(context);
    } catch (e) {
      showError(e, context);
    } finally {
      _isBusy = false;
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        leading: const SizedBox(),
        leadingWidth: 0,
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.file(
              File(
                widget.pickedFile.path,
              ),
              height: screenHeight / 2,
            ),
            const SizedBox(
              height: 40,
            ),
            if (detectedObjectsTexts != null &&
                detectedObjectsTexts!.isNotEmpty)
              Text(
                "Found Objects: $detectedObjectsTexts",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: Theme.of(context).textTheme.bodyMedium?.color),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (detectedObjectsTexts != null &&
                      detectedObjectsTexts!.isNotEmpty)
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ShareImageInfoScreen(
                              pickedFile: widget.pickedFile,
                              detectedObjectsTexts: detectedObjectsTexts!),
                        ));
                      },
                      child: const Text("Confirm"),
                    ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: FloatingActionButton.extended(
                heroTag: "3",
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
                label: const Text("Back"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
