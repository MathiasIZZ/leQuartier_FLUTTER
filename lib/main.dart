import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {


    final Size size = MediaQuery.of(context).size;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'apprendre les widgets flutter',
      theme: ThemeData(

        colorScheme: .fromSeed(seedColor: Colors.red),
        useMaterial3: true
      ),
      darkTheme: ThemeData.dark(useMaterial3: true),
      home: const MyHomePage(title: 'Le Quartier'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final String title;

  const MyHomePage({super.key, required this.title});



  @override
  Widget build(BuildContext context){
    //TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
      )
    );
  }
}


