import 'package:get/get.dart';
import 'package:hive/hive.dart';

class SettingsController extends GetxController {
  static const String _boxName = 'settings';
  late Box<dynamic> _settingsBox;

  // Observable settings
  final RxBool useGeminiApi = false.obs;
  final RxBool enableNotifications = true.obs;
  final RxBool enableSoundEffects = true.obs;
  final RxString defaultGameDuration = '30'.obs;
  final RxString defaultPlayerCount = '4'.obs;

  @override
  void onInit() {
    super.onInit();
    _initBox();
  }

  Future<void> _initBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      _settingsBox = await Hive.openBox(_boxName);
    } else {
      _settingsBox = Hive.box(_boxName);
    }
    _loadSettings();
  }

  void _loadSettings() {
    useGeminiApi.value = _settingsBox.get('useGeminiApi', defaultValue: false);
    enableNotifications.value = _settingsBox.get('enableNotifications', defaultValue: true);
    enableSoundEffects.value = _settingsBox.get('enableSoundEffects', defaultValue: true);
    defaultGameDuration.value = _settingsBox.get('defaultGameDuration', defaultValue: '30');
    defaultPlayerCount.value = _settingsBox.get('defaultPlayerCount', defaultValue: '4');
  }

  void toggleGeminiApi(bool value) {
    useGeminiApi.value = value;
    _settingsBox.put('useGeminiApi', value);
  }

  void toggleNotifications(bool value) {
    enableNotifications.value = value;
    _settingsBox.put('enableNotifications', value);
  }

  void toggleSoundEffects(bool value) {
    enableSoundEffects.value = value;
    _settingsBox.put('enableSoundEffects', value);
  }

  void setDefaultGameDuration(String value) {
    defaultGameDuration.value = value;
    _settingsBox.put('defaultGameDuration', value);
  }

  void setDefaultPlayerCount(String value) {
    defaultPlayerCount.value = value;
    _settingsBox.put('defaultPlayerCount', value);
  }

  void resetSettings() {
    toggleGeminiApi(false);
    toggleNotifications(true);
    toggleSoundEffects(true);
    setDefaultGameDuration('30');
    setDefaultPlayerCount('4');
  }
}
