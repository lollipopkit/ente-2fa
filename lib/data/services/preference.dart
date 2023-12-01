import 'package:ente_auth/core/event_bus.dart';
import 'package:ente_auth/core/events/icons_changed_event.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferenceService {
  PreferenceService._();

  static final instance = PreferenceService._();

  late final SharedPreferences _prefs;

  static const kShouldShowLargeIconsKey = "should_show_large_icons";
  static const kShouldHideCodesKey = "should_hide_codes";
  static const kShouldAutoFocusOnSearchBar = "should_auto_focus_on_search_bar";
  static const kShouldMinimizeOnCopy = "should_minimize_on_copy";

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  bool shouldShowLargeIcons() {
    if (_prefs.containsKey(kShouldShowLargeIconsKey)) {
      return _prefs.getBool(kShouldShowLargeIconsKey)!;
    } else {
      return false;
    }
  }

  Future<void> setShowLargeIcons(bool value) async {
    await _prefs.setBool(kShouldShowLargeIconsKey, value);
    Bus.instance.fire(IconsChangedEvent());
  }

  bool shouldHideCodes() {
    return _prefs.getBool(kShouldHideCodesKey) ?? false;
  }

  Future<void> setHideCodes(bool value) async {
    await _prefs.setBool(kShouldHideCodesKey, value);
    Bus.instance.fire(IconsChangedEvent());
  }

  bool shouldAutoFocusOnSearchBar() {
    if (_prefs.containsKey(kShouldAutoFocusOnSearchBar)) {
      return _prefs.getBool(kShouldAutoFocusOnSearchBar)!;
    } else {
      return false;
    }
  }

  Future<void> setAutoFocusOnSearchBar(bool value) async {
    await _prefs.setBool(kShouldAutoFocusOnSearchBar, value);
    Bus.instance.fire(IconsChangedEvent());
  }

  bool shouldMinimizeOnCopy() {
    if (_prefs.containsKey(kShouldMinimizeOnCopy)) {
      return _prefs.getBool(kShouldMinimizeOnCopy)!;
    } else {
      return false;
    }
  }

  Future<void> setShouldMinimizeOnCopy(bool value) async {
    await _prefs.setBool(kShouldMinimizeOnCopy, value);
  }
}
