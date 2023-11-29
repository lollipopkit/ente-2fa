import 'package:ente_auth/l10n/l10n.dart';
import 'package:ente_auth/theme/ente_theme.dart';
import 'package:ente_auth/ui/common/web_page.dart';
import 'package:ente_auth/ui/components/captioned_text_widget.dart';
import 'package:ente_auth/ui/components/expandable_menu_item_widget.dart';
import 'package:ente_auth/ui/components/menu_item_widget.dart';
import 'package:ente_auth/ui/settings/common_settings.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutSectionWidget extends StatelessWidget {
  const AboutSectionWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExpandableMenuItemWidget(
      title: context.l10n.about,
      selectionOptionsWidget: _getSectionOptions(context),
      leadingIcon: Icons.info_outline,
    );
  }

  Widget _getSectionOptions(BuildContext context) {
    return Column(
      children: [
        sectionOptionSpacing,
        MenuItemWidget(
          captionedTextWidget: CaptionedTextWidget(
            title: context.l10n.weAreOpenSource,
          ),
          pressedColor: getEnteColorScheme(context).fillFaint,
          trailingIcon: Icons.chevron_right_outlined,
          trailingIconIsMuted: true,
          onTap: () async {
            launchUrl(Uri.parse("https://github.com/ente-io/auth"));
          },
        ),
        sectionOptionSpacing,
        AboutMenuItemWidget(
          title: context.l10n.privacy,
          url: "https://ente.io/privacy",
        ),
        sectionOptionSpacing,
        AboutMenuItemWidget(
          title: context.l10n.termsOfServicesTitle,
          url: "https://ente.io/terms",
        ),
      ],
    );
  }
}

class AboutMenuItemWidget extends StatelessWidget {
  final String title;
  final String url;
  final String? webPageTitle;
  const AboutMenuItemWidget({
    required this.title,
    required this.url,
    this.webPageTitle,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MenuItemWidget(
      captionedTextWidget: CaptionedTextWidget(
        title: title,
      ),
      pressedColor: getEnteColorScheme(context).fillFaint,
      trailingIcon: Icons.chevron_right_outlined,
      trailingIconIsMuted: true,
      onTap: () async {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) {
              return WebPage(webPageTitle ?? title, url);
            },
          ),
        );
      },
    );
  }
}
