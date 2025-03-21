import 'package:get/get.dart';

import '../controllers/category_controller.dart';

class CategoriesBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CategoryController>(() => CategoryController());
  }
}
