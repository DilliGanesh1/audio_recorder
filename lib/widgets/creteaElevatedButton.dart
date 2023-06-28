import 'package:flutter/material.dart';

ElevatedButton createElevatedButton(
    {required IconData icon,
    required Color iconColor,
    required VoidCallback onPressFunc}) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.all(6.0),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 9.0,
    ),
    onPressed: onPressFunc,
    child: Icon(
      icon,
      color: iconColor,
      size: 38.0,
    ),
  );
}
