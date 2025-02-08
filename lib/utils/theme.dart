import 'package:flutter/material.dart';

class MyTheme {
  static ThemeData lightTheme = ThemeData.light().copyWith(
    primaryColorDark: const Color(0xFF036673),
    primaryColor: const Color(0xFF1D808E),
    primaryColorLight: const Color(0x6438D3E8),
    scaffoldBackgroundColor:  Colors.blueGrey[50],
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF036673),
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 22),
      iconTheme: IconThemeData(
        color: Colors.white,
      ),
    ),

    navigationRailTheme: const NavigationRailThemeData(
      backgroundColor: Color(0xFF036673),
      elevation: 0,
      labelType: NavigationRailLabelType.all,
      indicatorColor: Color(0x6438D3E8),
      unselectedIconTheme: IconThemeData(color: Colors.white54),
    ),

    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.selected)) {
              return lightTheme.primaryColor.withValues(alpha: 0.7);
            }
            return Colors.grey[300];
          },
        ),
        foregroundColor: WidgetStateProperty.resolveWith<Color?>(
              (states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.white;
            }
            return Colors.black;
          },
        ),
        iconColor: WidgetStateProperty.resolveWith<Color?>(
              (states) => states.contains(WidgetState.selected) ? Colors.white : Colors.black,
        ),
        side: WidgetStateProperty.resolveWith<BorderSide>(
              (states) => BorderSide(
            color: states.contains(WidgetState.selected) ? Colors.blueGrey : Colors.grey,
            width: 0.5,
          ),
        ),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
    ),

    textTheme: const TextTheme(
      titleLarge: TextStyle(fontSize: 22, color: Colors.black),
      titleMedium: TextStyle(fontSize: 15, color: Colors.black),
      titleSmall: TextStyle(fontSize: 12, color: Colors.black),
      bodyMedium : TextStyle(fontSize: 13, color: Colors.black, fontWeight: FontWeight.bold),
      bodySmall : TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.bold),
    ),

    cardTheme: CardTheme(
      color: Colors.grey[100],
      shadowColor: Colors.black,
      surfaceTintColor: Colors.teal[200],
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
    ),

  );

  static ThemeData darkTheme = ThemeData.dark().copyWith(
    primaryColor: Colors.grey[800],
    appBarTheme: const AppBarTheme(color: Colors.black),
  );
}