import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

late SharedPreferences globalSharedPrefs;

const isLive = false;

const kApiUrl = 'https://2fb0-2001-e68-545c-15aa-fc16-143d-1e82-cd37.ap.ngrok.io/api';
const showApiResponse = !isLive;

// based
const themePrimary = Color(0xffE65C4F);
const themseSecondary = Color(0xffEB7D72);
const backgroundPrimary = Color(0xFF171c20);
const backgroundSecondary = Color.fromARGB(255, 46, 56, 64);
const textPrimary = Color.fromARGB(255, 219, 219, 219);
const textSecondary = Color(0xFF8A8A8A);
