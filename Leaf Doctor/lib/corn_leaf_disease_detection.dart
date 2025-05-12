import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class CornLeafDiseaseDetection extends StatefulWidget {
  const CornLeafDiseaseDetection({super.key});

  @override
  State<CornLeafDiseaseDetection> createState() => _CornLeafDiseaseDetectionState();
}

class _CornLeafDiseaseDetectionState extends State<CornLeafDiseaseDetection> {
  File? filePath;
  String label = "";
  double confidence = 0.0;

  Map<String, String> diseaseRecommendations = {
    'Common Rust': 'Use fungicides like Tebuconazole and Chlorothalonil. Practice crop rotation and remove infected plant material.',
    'Blight': 'Apply copper-based fungicides, and practice proper crop rotation and sanitation.',
    'Gray Leaf Spot': 'Use resistant corn varieties, remove infected plant debris, and apply fungicides like Mancozeb.',
    'Healthy': 'No action required.',
    'Unknown' : 'Upload a valid image',
  };

  Map<String, String> diseaseInformation = {
    'Common Rust': 'Common Rust is a fungal disease caused by Puccinia sorghi affecting corn leaves.',
    'Blight': 'Blight is a disease that causes rapid and extensive death of plant tissues.',
    'Gray Leaf Spot': 'Gray Leaf Spot is a foliar disease caused by the fungus Cercospora zeae-maydis.',
    'Healthy': 'The leaf is healthy with no signs of disease.',
    'Unknown': 'No information available.',
  };

  Map<String, String> diseaseSymptoms = {
    'Common Rust': 'Symptoms include small, round to oval, reddish-brown pustules on leaves.',
    'Blight': 'Symptoms include large, irregular dead areas on leaves and rapid leaf death.',
    'Gray Leaf Spot': 'Symptoms include rectangular gray to tan lesions on leaves.',
    'Healthy': 'No symptoms.',
    'Unknown': 'No symptoms available.',
  };

  Map<String, String> diseaseManagement = {
    'Common Rust': 'Manage by using resistant varieties, applying fungicides, and crop rotation.',
    'Blight': 'Manage by removing infected debris, crop rotation, and fungicide application.',
    'Gray Leaf Spot': 'Manage by planting resistant hybrids and applying fungicides.',
    'Healthy': 'No management needed.',
    'Unknown': 'No management information available.',
  };

  @override
  void initState() {
    super.initState();
    _tfLiteInit();
  }

  @override
  void dispose() {
    super.dispose();
    Tflite.close();
  }

  void _showUnknownImageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Unknown Image'),
          content: Text('The image could not be recognized. Please try re-uploading or re-capturing the image.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  filePath = null;
                  label = '';
                  confidence = 0.0;
                });
                // Removed _showResultsBottomSheet() to prevent drawer from appearing for unknown result
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _tfLiteInit() async {
    await Tflite.loadModel(
      model: "assets/model.tflite",
      labels: "assets/label.txt",
      numThreads: 1,
      isAsset: true,
      useGpuDelegate: false,
    );
  }

    pickImageGallery() async {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;
      var imageMap = File(image.path);
      setState(() => filePath = imageMap);

      var recognition = await Tflite.runModelOnImage(
        path: image.path,
        imageMean: 0.0,
        imageStd: 255.0,
        numResults: 2,
        threshold: 0.2,
        asynch: true,
      );
      if (recognition == null) return;
      setState(() {
        confidence = (recognition[0]['confidence'] * 100);
        label = recognition[0]['label'].toString();
        // Do not clear filePath here to keep image preview in drawer
      });
      if (label == 'Unknown') {
        _showUnknownImageDialog();
      } else {
        _showResultsBottomSheet();
      }
    }

    pickImageCamera() async {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);
      if (image == null) return;
      var imageMap = File(image.path);
      setState(() => filePath = imageMap);

      var recognition = await Tflite.runModelOnImage(
        path: image.path,
        imageMean: 0.0,
        imageStd: 255.0,
        numResults: 2,
        threshold: 0.2,
        asynch: true,
      );
      if (recognition == null) return;
      setState(() {
        confidence = (recognition[0]['confidence'] * 100);
        label = recognition[0]['label'].toString();
        // Do not clear filePath here to keep image preview in drawer
      });
      if (label == 'Unknown') {
        _showUnknownImageDialog();
      } else {
        _showResultsBottomSheet();
      }
    }

  Widget _buildOptionButton(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Icon(icon, size: 30, color: Colors.white),
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.quicksand(fontSize: 14, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff468585),
      appBar: AppBar(
        backgroundColor: Color(0xff3f7777),
        foregroundColor: Colors.white,
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/logo.png', height: 40),
              SizedBox(width: 108),
              Center(),
              Text(
                "Leaf Doctor",
                style: GoogleFonts.quicksand(
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16),
                  Padding(
                    padding: EdgeInsets.only(left: 16.0),
                    child: Text(
                      'Select your option:',
                      style: GoogleFonts.quicksand(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(8),
                margin: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Color(0xff3f7777),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    _buildOptionButton(Icons.camera_alt_rounded, 'Camera', pickImageCamera),
                    _buildOptionButton(Icons.image, 'Upload', pickImageGallery),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'How to use the app:',
                  style: GoogleFonts.quicksand(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 8),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.quicksand(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                    ),
                    children: [
                      TextSpan(text: '1. Use the '),
                      WidgetSpan(
                        child: Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white70),
                      ),
                      TextSpan(text: ' Camera button to capture a photo of a corn leaf.\n'),
                      TextSpan(text: '2. Use the '),
                      WidgetSpan(
                        child: Icon(Icons.image, size: 16, color: Colors.white70),
                      ),
                      TextSpan(text: ' Upload button to select an image from your gallery.\n'),
                      TextSpan(text: '3. After selecting or capturing an image, the app will analyze it and show the results in a drawer.\n'),
                      TextSpan(text: '4. The drawer displays the disease detected, confidence level, recommendations, symptoms, and management tips.\n'),
                      TextSpan(text: '5. Use the Close button to dismiss the results drawer.'),
                    ],
                  ),
                ),
              ),
              
                ],
              ),
            ),
          ),
          Container(
            color: Color(0xff3f7777),
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning_amber_rounded, size: 30, color: Colors.yellow),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Note: This app is for Information Purposes only. Consult an Agricultural Expert for further confirmation on chemicals to use.",
                        style: GoogleFonts.quicksand(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.yellow.shade300,
                        ),
                      ),
                      SizedBox(height: 10),
                      Center(
                        child: Text(
                          "© 2025 Leaf Doctor. All rights reserved.",
                          style: GoogleFonts.quicksand(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showResultsBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xff3f7777),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
              if (filePath != null)
                Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: FileImage(File(filePath!.path)),
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              else if (filePath == null && label.isNotEmpty)
                Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: AssetImage('assets/upload.png'), // Placeholder image
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                    SizedBox(height: 10),
                    Text(
                      label,
                      style: GoogleFonts.quicksand(
                        fontSize: 21,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Accuracy: ${confidence.toStringAsFixed(2)}%",
                      style: GoogleFonts.quicksand(
                        fontSize: 21,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey.shade300,
                      ),
                    ),
                    SizedBox(height: 10),
                      if (diseaseRecommendations.containsKey(label))
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.green, width: 2),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            padding: EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Recommendation",
                                  style: GoogleFonts.quicksand(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                Divider(
                                  color: Colors.green,
                                  thickness: 2,
                                  height: 16,
                                ),
                                Text(
                                  "${diseaseRecommendations[label]}",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.quicksand(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    SizedBox(height: 10),
                    if (diseaseInformation.containsKey(label))
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Information",
                              style: GoogleFonts.quicksand(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white70,
                              ),
                            ),
                            Divider(
                              color: Colors.white70,
                              thickness: 2,
                              height: 16,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: diseaseInformation[label]!
                                  .split('. ')
                                  .where((sentence) => sentence.trim().isNotEmpty)
                                  .map((sentence) => Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 2),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "• ",
                                              style: GoogleFonts.quicksand(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white70,
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                sentence.trim() + (sentence.endsWith('.') ? '' : '.'),
                                                style: GoogleFonts.quicksand(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.white70,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                    SizedBox(height: 10),
                    if (diseaseSymptoms.containsKey(label))
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Symptoms",
                              style: GoogleFonts.quicksand(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white70,
                              ),
                            ),
                            Divider(
                              color: Colors.white70,
                              thickness: 2,
                              height: 16,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: diseaseSymptoms[label]!
                                  .split('. ')
                                  .where((sentence) => sentence.trim().isNotEmpty)
                                  .map((sentence) => Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 2),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "• ",
                                              style: GoogleFonts.quicksand(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white70,
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                sentence.trim() + (sentence.endsWith('.') ? '' : '.'),
                                                style: GoogleFonts.quicksand(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.white70,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                    SizedBox(height: 10),
                    if (diseaseManagement.containsKey(label))
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Management",
                              style: GoogleFonts.quicksand(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white70,
                              ),
                            ),
                            Divider(
                              color: Colors.white70,
                              thickness: 2,
                              height: 16,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: diseaseManagement[label]!
                                  .split('. ')
                                  .where((sentence) => sentence.trim().isNotEmpty)
                                  .map((sentence) => Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 2),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "• ",
                                              style: GoogleFonts.quicksand(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white70,
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                sentence.trim() + (sentence.endsWith('.') ? '' : '.'),
                                                style: GoogleFonts.quicksand(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.white70,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
              if (label == 'Unknown') 
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildOptionButton(Icons.camera_alt_rounded, 'Camera', pickImageCamera),
                    _buildOptionButton(Icons.image, 'Upload', pickImageGallery),
                  ],
                ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'Close',
                  style: GoogleFonts.quicksand(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
