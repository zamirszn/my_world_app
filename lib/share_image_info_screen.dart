// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_exif_plugin/flutter_exif_plugin.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:object_extract/global.dart';
import 'package:share_plus/share_plus.dart';

class ShareImageInfoScreen extends StatefulWidget {
  const ShareImageInfoScreen(
      {super.key,
      required this.pickedFile,
      required this.detectedObjectsTexts});
  final XFile pickedFile;
  final String detectedObjectsTexts;

  @override
  State<ShareImageInfoScreen> createState() => _ShareImageInfoScreenState();
}

class _ShareImageInfoScreenState extends State<ShareImageInfoScreen> {
  Map<String, dynamic>? exifResponse = {};

  @override
  void initState() {
    readFileExif();
    super.initState();
  }

  void readFileExif() async {
    try {
      exifResponse =
          await readExif(pickedImage: widget.pickedFile, context: context);

      setState(() {});
    } catch (e) {
      showError(e, context);
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
              height: screenHeight / 2.3,
            ),
            const SizedBox(
              height: 10,
            ),
            if (exifResponse != null && exifResponse!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    Text(
                      "I found (AI Identified objects: ${widget.detectedObjectsTexts}) on ${formatStringDateTime(exifResponse?["dateTime"])}, at ${exifResponse?["longitute"]}, ${exifResponse?["latitude"]}",
                      textAlign: TextAlign.center,
                      style: appBodyTextStyle(context),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: ElevatedButton.icon(
                          label: const Text("Copy Text"),
                          onPressed: () async {
                            await Clipboard.setData(ClipboardData(
                              text:
                                  "I found (AI Identified objects: ${widget.detectedObjectsTexts}) on ${formatStringDateTime(exifResponse?["dateTime"])}, at ${exifResponse?["longitute"]}, ${exifResponse?["latitude"]}",
                            ));

                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Text Copied")));
                          },
                          icon: const Icon(Icons.copy)),
                    )
                    // exifResponse!["dateTime"] != null
                    //     ? Text(
                    //         "on ${formatStringDateTime(exifResponse!["dateTime"])}",
                    //         textAlign: TextAlign.center,
                    //         style: appBodyTextStyle(context),
                    //       )
                    //     : Text(
                    //         "No Date Tag Found   ",
                    //         textAlign: TextAlign.center,
                    //         style: appBodyTextStyle(context),
                    //       ),
                    // exifResponse!["longitute"] != null &&
                    //         exifResponse!["latitude"] != null
                    //     ? Text(
                    //         "at ${exifResponse!["latitude"]}, ${exifResponse!["longitute"]} ",
                    //         textAlign: TextAlign.center,
                    //         style: appBodyTextStyle(context),
                    //       )
                    //     : Text(
                    //         "No Location Tag Found",
                    //         textAlign: TextAlign.center,
                    //         style: appBodyTextStyle(context),
                    //       ),
                  ],
                ),
              ),
            if (exifResponse != null && exifResponse!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: ElevatedButton.icon(
                    onPressed: () {
                      Share.shareXFiles(
                        text:
                            "I found (AI Identified objects: ${widget.detectedObjectsTexts}) on ${formatStringDateTime(exifResponse?["dateTime"])}, at ${exifResponse?["latitude"]}, ${exifResponse?["longitute"]}",
                        [widget.pickedFile],
                      );
                    },
                    icon: const Icon(Icons.share),
                    label: const Text(
                        "Share image with AI description and location")),
              ),
            ElevatedButton.icon(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                icon: const Icon(Icons.image),
                label: const Text("Take another image")),
            const SizedBox(
              height: 10,
            ),
            Align(
              alignment: Alignment.centerLeft,
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
