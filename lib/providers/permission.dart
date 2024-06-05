import 'dart:developer';

import 'package:permission_handler/permission_handler.dart';

class CheckPermission {
  static isStoragePermission() async {
    var isStorageLowerVersion = await Permission.storage.status;
    var isStorageHigherVersion = await Permission.manageExternalStorage.status;
    log(isStorageLowerVersion.toString());
    log(isStorageHigherVersion.toString());
    if (!isStorageLowerVersion.isGranted && !isStorageHigherVersion.isGranted) {
      await Permission.storage.request();
      await Permission.manageExternalStorage.request();
      if (!isStorageLowerVersion.isGranted &&
          !isStorageHigherVersion.isGranted) {
        return false;
      } else {
        return true;
      }
    }
    return true;
  }
}
