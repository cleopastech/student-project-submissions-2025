import 'package:flutter/material.dart';

import 'corn_leaf_disease_detection.dart';

void main(){
  runApp(const MyApp());
}

class MyApp extends StatelessWidget{
  const MyApp({super.key});

  //This widget is the root of your application
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: 'Corn Leaf Disease Detection',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: CornLeafDiseaseDetection(),
    );
  }
}