## Code Documentation

### 1. `setGeoTagAndTime` Function

#### Purpose

This function is responsible for capturing an image using the device camera, obtaining the geolocation data of the device, and setting the captured image's metadata (EXIF) with the current date and time, as well as the geolocation information.

#### Parameters

- `image`: An `XFile` representing the image captured by the camera.

#### Returns

- A `Future<String?>` that resolves to the path of the image with updated metadata. Returns `null` if any error occurs during the process.

#### Usage

```dart
Future<String?> geoTaggedImagePath = setGeoTagAndTime(XFile image);
```

### 2. `snapImage` Function

#### Purpose

This function initiates the process of capturing an image using the device camera, setting geolocation data, and navigating to a screen for object detection.

#### Parameters

- `context`: The BuildContext for the current widget.

#### Usage

```dart
snapImage(BuildContext context);
```

### 3. `imagePicker` Function

#### Purpose

This function allows the user to pick an image from the device storage, and then navigates to a screen for object detection.

#### Parameters

- `context`: The BuildContext for the current widget.

#### Usage

```dart
imagePicker(BuildContext context);
```

### Notes:

- The `snapImage` function utilizes the `setGeoTagAndTime` function to capture an image using the device camera and set its geolocation and timestamp metadata.

- The `imagePicker` function uses the FilePicker plugin to allow the user to pick an image from the device storage.

- The selected or captured image is then passed to the `ObjectDetectionScreen` widget for further processing.

## Object Detection Screen Documentation

### Class Overview

The `ObjectDetectionScreen` class is a StatefulWidget designed to perform object detection on images using a pre-trained machine learning model. It leverages the TFLite plugin for TensorFlow Lite model inference and utilizes the ML Kit's platform method channel for object recognition. This screen is typically used in the context of an image processing application.

### Properties:

1. **`_objectDetector`**

   - Type: `ObjectDetector?`
   - Purpose: Represents an instance of the `ObjectDetector` class, responsible for object detection tasks.

2. **`_mode`**

   - Type: `DetectionMode`
   - Purpose: Specifies the detection mode, with a default value of `DetectionMode.single`. This influences how the object detector processes images.

3. **`_canProcess`**

   - Type: `bool`
   - Purpose: A flag indicating whether image processing can occur. It is initially set to `false` and is updated during the initialization process.

4. **`_isBusy`**

   - Type: `bool`
   - Purpose: Flags whether the object detector is currently processing an image. It is set to `true` during image processing and reset to `false` when processing is complete.

5. **`detectedObjectsTexts`**
   - Type: `String?`
   - Purpose: Holds a textual representation of the detected objects.

### Methods:

#### 1. `dispose`

- **Purpose:** Overrides the `dispose` method to clean up resources and close the object detector when the widget is disposed.

#### 2. `initState`

- **Purpose:** Overrides the `initState` method to start the image processing when the widget is initialized. It calls the `startProcessingImage` method.

#### 3. `startProcessingImage`

- **Purpose:** Initiates the process of initializing the object detector and processing the image. It checks whether processing is allowed (`_canProcess` is `true`).

#### 4. `_initializeDetector`

- **Purpose:** Initializes the object detector with the specified model path and options. Handles any exceptions that may occur during initialization and sets `_canProcess` to `true` if successful.

#### 5. `_processImage`

- **Purpose:** Processes the input image using the object detector. Utilizes the platform method channel to communicate with ML Kit for object recognition. Extracts unique labels from the detected objects and sets `detectedObjectsTexts` with a concatenated string of these labels. Displays a Snackbar if no objects are found in the image.

### Usage:

- **Initialization:**

  ```dart
  ObjectDetectionScreen(pickedFile: XFile(imagePath));
  ```

- **Lifecycle:**

  - The `initState` method is called on widget initialization, triggering the start of image processing.
  - The `dispose` method ensures proper cleanup when the widget is disposed.

- **Error Handling:**

  - Errors during object detector initialization, image processing, or ML Kit interactions are displayed using the `showError` function.

- **Loading Dialog:**
  - Loading dialogs are shown using the `showLoadingDialog` function to provide feedback to the user during image processing.

### Recommendations:

- Ensure the necessary permissions for image processing are handled appropriately before calling these methods.

- Verify that the required dependencies (TFLite plugin, ML Kit, etc.) are correctly configured in the `pubspec.yaml` file.

- Add comments to enhance code readability, especially for complex or critical sections.

- Consider providing user-friendly messages or UI feedback during the image processing stages.

By adhering to these recommendations, you can enhance the reliability, readability, and user experience of your object detection screen with ML Kit integration.

## Image Exif Data and Location Documentation

The following Dart code provides functionality for reading and writing Exif data (Exchangeable image file format) in images, as well as determining the device's current geographical location. The code uses the `FlutterExif` package for Exif operations and the `Geolocator` package for location-related tasks.

### 1. `readExif` Function

- **Purpose:**

  - Reads Exif data from the provided image file.

- **Parameters:**

  - `pickedImage`: An `XFile` representing the image file.
  - `context`: The `BuildContext` for displaying error messages.

- **Returns:**
  - A `Future<Map<String, String?>?>` that resolves to a map containing Exif data such as date, latitude, and longitude. Returns `null` in case of errors.

### 2. `writeExif` Function

- **Purpose:**

  - Writes Exif data to an image file, including location information.

- **Parameters:**

  - `location`: A `Position` object representing the geographical location.
  - `dateTime`: A formatted date and time string.
  - `image`: An `XFile` representing the original image file.
  - `context`: The `BuildContext` for displaying error messages.

- **Returns:**
  - A `Future<String?>` that resolves to the path of the image file with updated Exif data. Returns `null` in case of errors.

### 3. `getFormattedCameraDateTime` Function

- **Purpose:**

  - Generates a formatted date and time string for Exif data.

- **Returns:**
  - A formatted date and time string.

### 4. `determinePosition` Function

- **Purpose:**

  - Determines the current geographical position of the device.

- **Returns:**
  - A `Future<Position?>` that resolves to the current geographical position. Returns `null` if location services are not enabled or permissions are denied.
