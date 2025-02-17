import 'package:ente_auth/data/res/theme/ente_theme.dart';
import 'package:ente_auth/l10n/l10n.dart';
import 'package:ente_auth/ui/view/title_bar.dart';
import 'package:flutter/material.dart';

class LanguageSelectorPage extends StatelessWidget {
  final List<Locale> supportedLocales;
  final ValueChanged<Locale> onLocaleChanged;
  final Locale? currentLocale;

  const LanguageSelectorPage(
    this.supportedLocales,
    this.onLocaleChanged,
    this.currentLocale, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: CustomScrollView(
        primary: false,
        slivers: <Widget>[
          TitleBarWidget(
            flexibleSpaceTitle: TitleBarTitleWidget(
              title: l10n.selectLanguage,
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8)),
                        child: ItemsWidget(
                          supportedLocales,
                          onLocaleChanged,
                          currentLocale,
                        ),
                      ),
                      // MenuSectionDescriptionWidget(
                      //   content: context.l10n.maxDeviceLimitSpikeHandling(50),
                      // )
                    ],
                  ),
                );
              },
              childCount: 1,
            ),
          ),
          const SliverPadding(padding: EdgeInsets.symmetric(vertical: 12)),
        ],
      ),
    );
  }
}

class ItemsWidget extends StatefulWidget {
  final List<Locale> supportedLocales;
  final ValueChanged<Locale> onLocaleChanged;
  final Locale? currentLocale;

  const ItemsWidget(
    this.supportedLocales,
    this.onLocaleChanged,
    this.currentLocale, {
    super.key,
  });

  @override
  State<ItemsWidget> createState() => _ItemsWidgetState();
}

class _ItemsWidgetState extends State<ItemsWidget> {
  late Locale? currentLocale;
  List<Widget> items = [];

  @override
  void initState() {
    currentLocale = widget.currentLocale;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    items.clear();
    for (Locale locale in widget.supportedLocales) {
      items.add(
        _menuItemForPicker(locale),
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: items,
    );
  }

  String _getLanguageName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'es':
        switch (locale.countryCode) {
          case 'ES':
            return 'Español (España)';
          default:
            return 'Español';
        }
      case 'fr':
        return 'Français';
      case 'de':
        return 'Deutsch';
      case 'it':
        return 'Italiano';
      case 'nl':
        return 'Nederlands';
      case 'pl':
        return 'Polski';
      case 'pt':
        switch (locale.countryCode) {
          case 'BR':
            return 'Português (Brasil)';
          default:
            return 'Português';
        }
      case 'ru':
        return 'Русский';
      case 'tr':
        return 'Türkçe';
      case 'fi':
        return 'Suomi';
      case 'zh':
        switch (locale.scriptCode) {
          case 'Hans':
            return '中文 (简体)';
          case 'Hant':
            return '中文 (繁體)';
          default:
            return '中文';
        }
      case 'ja':
        return '日本語';
      case 'ko':
        return '한국어';
      case 'ar':
        return 'العربية';
      case 'fa':
        return 'فارسی';
      default:
        return locale.languageCode;
    }
  }

  Widget _menuItemForPicker(Locale locale) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 3),
      child: ListTile(
        key: ValueKey(locale.toString()),
        tileColor: getEnteColorScheme(context).fillFaint,
        title: Text(_getLanguageName(locale)),
        trailing: currentLocale == locale ? const Icon(Icons.check) : null,
        onTap: () async {
          widget.onLocaleChanged(locale);
          currentLocale = locale;
          setState(() {});
        },
      ),
    );
  }
}
