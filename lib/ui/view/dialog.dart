import 'dart:math';

import 'package:ente_auth/core/ext/list.dart';
import 'package:ente_auth/data/models/typedefs.dart';
import 'package:ente_auth/data/res/components_constants.dart';
import 'package:ente_auth/data/res/theme/colors.dart';
import 'package:ente_auth/data/res/theme/effects.dart';
import 'package:ente_auth/data/res/theme/ente_theme.dart';
import 'package:ente_auth/l10n/l10n.dart';
import 'package:ente_auth/ui/view/buttons/button_result.dart';
import 'package:ente_auth/ui/view/buttons/button_type.dart';
import 'package:ente_auth/ui/view/buttons/button_widget.dart';
import 'package:ente_auth/ui/view/text_input.dart';
import 'package:flutter/material.dart';

///Will return null if dismissed by tapping outside
Future<ButtonResult?> showDialogWidget({
  required BuildContext context,
  required String title,
  String? body,
  required List<ButtonWidget> buttons,
  IconData? icon,
  bool isDismissible = true,
}) {
  return showDialog(
    barrierDismissible: isDismissible,
    barrierColor: backdropFaintDark,
    context: context,
    builder: (context) {
      final widthOfScreen = MediaQuery.of(context).size.width;
      final isMobileSmall = widthOfScreen <= mobileSmallThreshold;
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: isMobileSmall ? 8 : 0),
        child: Dialog(
          insetPadding: EdgeInsets.zero,
          child: DialogWidget(
            title: title,
            body: body,
            buttons: buttons,
            icon: icon,
          ),
        ),
      );
    },
  );
}

class DialogWidget extends StatelessWidget {
  final String title;
  final String? body;
  final List<ButtonWidget> buttons;
  final IconData? icon;
  const DialogWidget({
    required this.title,
    this.body,
    required this.buttons,
    this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final widthOfScreen = MediaQuery.of(context).size.width;
    final isMobileSmall = widthOfScreen <= mobileSmallThreshold;
    final colorScheme = getEnteColorScheme(context);
    return Container(
      width: min(widthOfScreen, 320),
      padding: isMobileSmall
          ? const EdgeInsets.all(0)
          : const EdgeInsets.fromLTRB(6, 8, 6, 6),
      decoration: BoxDecoration(
        color: colorScheme.backgroundElevated,
        boxShadow: shadowFloatLight,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ContentContainer(
                title: title,
                body: body,
                icon: icon,
              ),
              const SizedBox(height: 36),
              ...List<Widget>.from(buttons).joinWith(const SizedBox(height: 6)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContentContainer extends StatelessWidget {
  final String title;
  final String? body;
  final IconData? icon;
  const _ContentContainer({
    required this.title,
    this.body,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = getEnteTextTheme(context);
    final colorScheme = getEnteColorScheme(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        icon == null
            ? const SizedBox.shrink()
            : Row(
                children: [
                  Icon(
                    icon,
                    size: 32,
                  ),
                ],
              ),
        icon == null ? const SizedBox.shrink() : const SizedBox(height: 19),
        Text(title, style: textTheme.largeBold),
        body != null ? const SizedBox(height: 19) : const SizedBox.shrink(),
        body != null
            ? Text(
                body!,
                style: textTheme.body.copyWith(color: colorScheme.textMuted),
              )
            : const SizedBox.shrink(),
      ],
    );
  }
}

class TextInputDialog extends StatefulWidget {
  final String title;
  final String? body;
  final String submitButtonLabel;
  final IconData? icon;
  final String? label;
  final String? message;
  final FutureVoidCallbackParamStr onSubmit;
  final String? hintText;
  final IconData? prefixIcon;
  final String? initialValue;
  final Alignment? alignMessage;
  final int? maxLength;
  final bool showOnlyLoadingState;
  final TextCapitalization? textCapitalization;
  final bool alwaysShowSuccessState;
  final bool isPasswordInput;
  const TextInputDialog({
    required this.title,
    this.body,
    required this.submitButtonLabel,
    required this.onSubmit,
    this.icon,
    this.label,
    this.message,
    this.hintText,
    this.prefixIcon,
    this.initialValue,
    this.alignMessage,
    this.maxLength,
    this.textCapitalization,
    this.showOnlyLoadingState = false,
    this.alwaysShowSuccessState = false,
    this.isPasswordInput = false,
    super.key,
  });

  @override
  State<TextInputDialog> createState() => _TextInputDialogState();
}

class _TextInputDialogState extends State<TextInputDialog> {
  //the value of this ValueNotifier has no significance
  final _submitNotifier = ValueNotifier(false);

  @override
  void dispose() {
    _submitNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final widthOfScreen = MediaQuery.of(context).size.width;
    final isMobileSmall = widthOfScreen <= mobileSmallThreshold;
    final colorScheme = getEnteColorScheme(context);
    return Container(
      width: min(widthOfScreen, 320),
      padding: isMobileSmall
          ? const EdgeInsets.all(0)
          : const EdgeInsets.fromLTRB(6, 8, 6, 6),
      decoration: BoxDecoration(
        color: colorScheme.backgroundElevated,
        boxShadow: shadowFloatLight,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ContentContainer(
              title: widget.title,
              body: widget.body,
              icon: widget.icon,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 19),
              child: TextInput(
                label: widget.label,
                message: widget.message,
                hintText: widget.hintText,
                prefixIcon: widget.prefixIcon,
                initialValue: widget.initialValue,
                alignMessage: widget.alignMessage,
                autoFocus: true,
                maxLength: widget.maxLength,
                submitNotifier: _submitNotifier,
                onSubmit: widget.onSubmit,
                popNavAfterSubmission: true,
                showOnlyLoadingState: widget.showOnlyLoadingState,
                textCapitalization: widget.textCapitalization,
                alwaysShowSuccessState: widget.alwaysShowSuccessState,
                isPasswordInput: widget.isPasswordInput,
              ),
            ),
            const SizedBox(height: 36),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: ButtonWidget(
                    buttonType: ButtonType.secondary,
                    buttonSize: ButtonSize.small,
                    labelText: context.l10n.cancel,
                    isInAlert: true,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ButtonWidget(
                    buttonSize: ButtonSize.small,
                    buttonType: ButtonType.neutral,
                    labelText: widget.submitButtonLabel,
                    onTap: () async {
                      _submitNotifier.value = !_submitNotifier.value;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
