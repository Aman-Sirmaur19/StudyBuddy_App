import 'dart:developer';

import 'package:permission_handler/permission_handler.dart';

class CheckPermission {
  static isStoragePermission() async {
    var isStorageLowerVersion = await Permission.storage.status;
    log(isStorageLowerVersion.toString());
    if (!isStorageLowerVersion.isGranted) {
      await Permission.storage.request();
      if (!isStorageLowerVersion.isGranted) {
        return false;
      } else {
        return true;
      }
    }
    return true;
  }
}
