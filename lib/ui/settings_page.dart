import 'package:ente_auth/theme/colors.dart';
import 'package:ente_auth/theme/ente_theme.dart';
import 'package:ente_auth/ui/settings/about_section_widget.dart';
import 'package:ente_auth/ui/settings/app_version_widget.dart';
import 'package:ente_auth/ui/settings/data/data_section_widget.dart';
import 'package:ente_auth/ui/settings/general_section_widget.dart';
import 'package:ente_auth/ui/settings/security_section_widget.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final enteColorScheme = getEnteColorScheme(context);
    return Scaffold(
      body: Container(
        color: enteColorScheme.backdropBase,
        child: _getBody(context, enteColorScheme),
      ),
    );
  }

  Widget _getBody(BuildContext context, EnteColorScheme colorScheme) {
    const sectionSpacing = SizedBox(height: 8);
    final List<Widget> contents = [
      const DataSectionWidget(),
      sectionSpacing,
      const SecuritySectionWidget(),
      sectionSpacing,
      const AdvancedSectionWidget(),
      sectionSpacing,
      const AboutSectionWidget(),
      const AppVersionWidget(),
      const Padding(
        padding: EdgeInsets.only(bottom: 60),
      ),
    ];

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                children: contents,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
