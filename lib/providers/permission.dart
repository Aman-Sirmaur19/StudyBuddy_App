import 'package:permission_handler/permission_handler.dart';

class CheckPermission {
  static isStoragePermission() async {
    var isStorage = await Permission.manageExternalStorage.status;
    if (!isStorage.isGranted) {
      await Permission.manageExternalStorage.request();
      if (!isStorage.isGranted) {
        return false;
      } else {
        return true;
      }
    }
    return true;
  }
}
