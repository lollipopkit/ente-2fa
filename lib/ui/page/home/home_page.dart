import 'dart:async';
import 'dart:io';

import 'package:ente_auth/core/event_bus.dart';
import 'package:ente_auth/core/events/codes_updated_event.dart';
import 'package:ente_auth/core/events/icons_changed_event.dart';
import 'package:ente_auth/core/utils/dialog_util.dart';
import 'package:ente_auth/core/utils/totp_util.dart';
import 'package:ente_auth/data/models/code.dart';
import 'package:ente_auth/data/services/preference_service.dart';
import 'package:ente_auth/data/store/code_store.dart';
import "package:ente_auth/l10n/l10n.dart";
import 'package:ente_auth/theme.dart';
import 'package:ente_auth/ui/common/loading_widget.dart';
import 'package:ente_auth/ui/page/home/coach_mark_widget.dart';
import 'package:ente_auth/ui/page/home/home_empty_state.dart';
import 'package:ente_auth/ui/page/scanner/general.dart';
import 'package:ente_auth/ui/page/secret_key.dart';
import 'package:ente_auth/ui/page/settings/settings.dart';
import 'package:ente_auth/ui/view/code.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:move_to_background/move_to_background.dart';
import 'package:uni_links/uni_links.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _settingsPage = SettingsPage();
  bool _hasLoaded = false;
  bool _isSettingsOpen = false;
  final Logger _logger = Logger("HomePage");

  final TextEditingController _textController = TextEditingController();
  bool _showSearchBox = false;
  String _searchText = "";
  List<Code> _codes = [];
  List<Code> _filteredCodes = [];
  StreamSubscription<CodesUpdatedEvent>? _streamSubscription;
  StreamSubscription<IconsChangedEvent>? _iconsChangedEvent;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_applyFilteringAndRefresh);
    _loadCodes();
    _streamSubscription = Bus.instance.on<CodesUpdatedEvent>().listen((event) {
      _loadCodes();
    });
    _initDeepLinks();
    _iconsChangedEvent = Bus.instance.on<IconsChangedEvent>().listen((event) {
      setState(() {});
    });
    _showSearchBox = PreferenceService.instance.shouldAutoFocusOnSearchBar();
  }

  void _loadCodes() {
    CodeStore.instance.getAllCodes().then((codes) {
      _codes = codes;
      _hasLoaded = true;
      _applyFilteringAndRefresh();
    });
  }

  void _applyFilteringAndRefresh() {
    if (_searchText.isNotEmpty && _showSearchBox) {
      final String val = _searchText.toLowerCase();
      _filteredCodes = _codes
          .where(
            (element) => (element.account.toLowerCase().contains(val) ||
                element.issuer.toLowerCase().contains(val)),
          )
          .toList();
    } else {
      _filteredCodes = _codes;
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _iconsChangedEvent?.cancel();
    _textController.removeListener(_applyFilteringAndRefresh);
    super.dispose();
  }

  Future<void> _redirectToScannerPage() async {
    unawaited(() async {
      final Code? code = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (BuildContext context) {
            return const ScannerPage();
          },
        ),
      );
      if (code != null) {
        CodeStore.instance.addCode(code);
        // Focus the new code by searching
        if (_codes.length > 2) {
          _focusNewCode(code);
        }
      }
    }());
  }

  Future<void> _redirectToManualEntryPage() async {
    unawaited(() async {
      final Code? code = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (BuildContext context) {
            return const SecretKeyPage();
          },
        ),
      );
      if (code != null) {
        CodeStore.instance.addCode(code);
      }
    }());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return WillPopScope(
      onWillPop: () async {
        if (_isSettingsOpen) {
          Navigator.pop(context);
          return false;
        }
        if (Platform.isAndroid) {
          MoveToBackground.moveTaskToBack();
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        drawerEnableOpenDragGesture: true,
        drawer: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 328),
          child: const Drawer(
            width: double.infinity,
            child: _settingsPage,
          ),
        ),
        onDrawerChanged: (isOpened) => _isSettingsOpen = isOpened,
        body: SafeArea(
          bottom: false,
          child: Builder(
            builder: (context) {
              return _getBody();
            },
          ),
        ),
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: !_showSearchBox
              ? const Text('Codes')
              : TextField(
                  autofocus: _searchText.isEmpty,
                  controller: _textController,
                  onChanged: (val) {
                    _searchText = val;
                    _applyFilteringAndRefresh();
                  },
                  decoration: InputDecoration(
                    hintText: l10n.searchHint,
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
          actions: <Widget>[
            IconButton(
              icon: _showSearchBox
                  ? const Icon(Icons.clear)
                  : const Icon(Icons.search),
              tooltip: l10n.search,
              onPressed: () {
                setState(
                  () {
                    _showSearchBox = !_showSearchBox;
                    if (!_showSearchBox) {
                      _textController.clear();
                    } else {
                      _searchText = _textController.text;
                    }
                    _applyFilteringAndRefresh();
                  },
                );
              },
            ),
          ],
        ),
        floatingActionButton: !_hasLoaded ||
                _codes.isEmpty ||
                !PreferenceService.instance.hasShownCoachMark()
            ? null
            : _getFab(),
      ),
    );
  }

  Widget _getBody() {
    final l10n = context.l10n;
    if (_hasLoaded) {
      if (_filteredCodes.isEmpty && _searchText.isEmpty) {
        return HomeEmptyStateWidget(
          onScanTap: _redirectToScannerPage,
          onManuallySetupTap: _redirectToManualEntryPage,
        );
      } else {
        final list = ListView.builder(
          itemBuilder: ((context, index) {
            try {
              return CodeWidget(_filteredCodes[index]);
            } catch (e) {
              return const Text("Failed");
            }
          }),
          itemCount: _filteredCodes.length,
        );
        if (!PreferenceService.instance.hasShownCoachMark()) {
          return Stack(
            children: [
              list,
              const CoachMarkWidget(),
            ],
          );
        } else if (_showSearchBox) {
          return Column(
            children: [
              Expanded(
                child: _filteredCodes.isNotEmpty
                    ? ListView.builder(
                        itemBuilder: ((context, index) {
                          Code? code;
                          try {
                            code = _filteredCodes[index];
                            return CodeWidget(code);
                          } catch (e, s) {
                            _logger.severe("code widget error", e, s);
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  l10n.sorryUnableToGenCode(code?.issuer ?? ""),
                                ),
                              ),
                            );
                          }
                        }),
                        itemCount: _filteredCodes.length,
                      )
                    : Center(child: (Text(l10n.noResult))),
              ),
            ],
          );
        } else {
          return list;
        }
      }
    } else {
      return const EnteLoadingWidget();
    }
  }

  Future<bool> _initDeepLinks() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      final String? initialLink = await getInitialLink();
      // Parse the link and warn the user, if it is not correct,
      // but keep in mind it could be `null`.
      if (initialLink != null) {
        _handleDeeplink(context, initialLink);
        return true;
      } else {
        _logger.info("No initial link received.");
      }
    } on PlatformException {
      // Handle exception by warning the user their action did not succeed
      // return?
      _logger.severe("PlatformException thrown while getting initial link");
    }

    // Attach a listener to the stream
    linkStream.listen(
      (String? link) {
        _handleDeeplink(context, link);
      },
      onError: (err) {
        _logger.severe(err);
      },
    );
    return false;
  }

  void _handleDeeplink(BuildContext context, String? link) {
    if (link == null) {
      return;
    }
    if (mounted && link.toLowerCase().startsWith("otpauth://")) {
      try {
        final newCode = Code.fromRawData(link);
        getNextTotp(newCode);
        CodeStore.instance.addCode(newCode);
        _focusNewCode(newCode);
      } catch (e, s) {
        showGenericErrorDialog(context: context);
        _logger.severe("error while handling deeplink", e, s);
      }
    }
  }

  void _focusNewCode(Code newCode) {
    _showSearchBox = true;
    _textController.text = newCode.account;
    _searchText = newCode.account;
    _applyFilteringAndRefresh();
  }

  Widget _getFab() {
    return FloatingActionButton(
      child: const Icon(Icons.add),
      tooltip: context.l10n.addCode,
      foregroundColor: Theme.of(context).colorScheme.fabForegroundColor,
      backgroundColor: Theme.of(context).colorScheme.fabBackgroundColor,
      elevation: 8.0,
      onPressed: () {
        showChoiceDialog(
          context,
          title: 'Choose',
          firstButtonLabel: 'Scan',
          secondButtonLabel: 'Enter Manually',
          firstButtonOnTap: _redirectToScannerPage,
          secondButtonOnTap: _redirectToManualEntryPage,
        );
      },
    );
  }
}