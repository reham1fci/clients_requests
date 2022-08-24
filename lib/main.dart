//@dart = 2.8
import 'package:clientsrequests/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'Screeens/Splash.dart';

void main() => runApp(
     MaterialApp(
  debugShowCheckedModeBanner: false,
  localizationsDelegates: const[
    AppLocalizations.delegate,
    // Built-in localization of basic text for Material widgets
    GlobalMaterialLocalizations.delegate,
    // Built-in localization for text direction LTR/RTL
    GlobalWidgetsLocalizations.delegate,
  ],
  supportedLocales: const[
    Locale('en'),
    Locale('ar'),
  ],
  home:  Splash(),
)
);

