import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:my_mikhailovka/app_localizations.dart';
import 'package:my_mikhailovka/domain/transport_manager.dart';
import 'package:my_mikhailovka/screens/home/home.dart';

class App extends StatelessWidget {
  final TransportManager transportManager;

  App(this.transportManager);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        //const Locale('en', 'US'), // English
        const Locale('ru', 'RU'), // Russian
      ],
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(transportManager),
    );
  }
}