import 'package:get/get.dart';

import '../controllers/random_picker_controller.dart';

class RandomPickerBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RandomPickerController>(() => RandomPickerController());
  }
}
