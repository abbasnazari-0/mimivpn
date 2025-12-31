import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:installed_apps/installed_apps.dart';

class InstalledApp {
  final String appName;
  final String packageName;
  final Uint8List? icon;
  final bool isSystemApp;

  InstalledApp({
    required this.appName,
    required this.packageName,
    this.icon,
    this.isSystemApp = false,
  });
}

class DeviceAppsService {
  /// Get all installed apps (including system apps)
  static Future<List<InstalledApp>> getAllApps() async {
    try {
      final apps = await InstalledApps.getInstalledApps(
        withIcon: false,
        excludeSystemApps: true, // فقط اپ‌های کاربر
        excludeNonLaunchableApps: false,
      );

      return apps.map((app) {
        Uint8List? icon;
        // if (app is InstalledApps.) {
        icon = app.icon;
        // }

        return InstalledApp(
          appName: app.name,
          packageName: app.packageName,
          icon: icon,
          isSystemApp: app.isSystemApp,
        );
      }).toList()
        ..sort(
            (a, b) => a.appName.compareTo(b.appName)); // مرتب‌سازی براساس اسم
    } catch (e) {
      print('Error getting installed apps: $e');
      return [];
    }
  }

  /// Get only user-installed apps (excluding system apps)
  static Future<List<InstalledApp>> getUserApps() async {
    try {
      final apps = await InstalledApps.getInstalledApps(
        withIcon: true,
        excludeSystemApps: true,
        excludeNonLaunchableApps: true,
      );

      return apps.where((app) => !app.isSystemApp).map((app) {
        Uint8List? icon;
        // if (app is ApplicationWithIcon) {
        icon = app.icon;
        // }

        return InstalledApp(
          appName: app.name,
          packageName: app.packageName,
          icon: icon,
          isSystemApp: app.isSystemApp,
        );
      }).toList()
        ..sort((a, b) => a.appName.compareTo(b.appName));
    } catch (e) {
      print('Error getting user apps: $e');
      return [];
    }
  }

  /// Check if an app is installed
  static Future<bool?> isAppInstalled(String packageName) async {
    try {
      return await InstalledApps.isAppInstalled(packageName);
    } catch (e) {
      print('Error checking if app is installed: $e');
      return false;
    }
  }

  /// Open an app
  static Future<bool?> openApp(String packageName) async {
    try {
      return await InstalledApps.startApp(packageName);
    } catch (e) {
      print('Error opening app: $e');
      return false;
    }
  }

  /// Get app details
  static Future<InstalledApp?> getAppDetails(String packageName) async {
    try {
      final app = await InstalledApps.getAppInfo(packageName);
      if (app != null) {
        Uint8List? icon;
        // if (app is ApplicationWithIcon) {
        icon = app.icon;
        // }

        return InstalledApp(
          appName: app.name,
          packageName: app.packageName,
          icon: icon,
          isSystemApp: app.isSystemApp,
        );
      }
      return null;
    } catch (e) {
      print('Error getting app details: $e');
      return null;
    }
  }

  /// Create Image widget from app icon
  static Widget createAppIcon(Uint8List? iconData, {double size = 48}) {
    if (iconData != null) {
      return Image.memory(
        iconData,
        width: size,
        height: size,
        fit: BoxFit.cover,
      );
    } else {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.android,
          size: size * 0.6,
          color: Colors.grey[600],
        ),
      );
    }
  }
}
