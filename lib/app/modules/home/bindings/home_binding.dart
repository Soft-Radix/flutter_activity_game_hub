import 'package:get/get.dart';

import '../../../modules/categories/controllers/category_controller.dart';
import '../../../modules/random_picker/controllers/random_picker_controller.dart';

class HomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CategoryController>(() => CategoryController());
    Get.lazyPut<RandomPickerController>(() => RandomPickerController());
  }
}
