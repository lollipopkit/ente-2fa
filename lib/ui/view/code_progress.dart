import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class CodeTimerProgress extends StatefulWidget {
  final int period;

  const CodeTimerProgress({
    super.key,
    required this.period,
  });

  @override
  State<CodeTimerProgress> createState() => _CodeTimerProgressState();
}

class _CodeTimerProgressState extends State<CodeTimerProgress>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  double _progress = 0.0;
  late final int _microSecondsInPeriod;

  @override
  void initState() {
    super.initState();
    _microSecondsInPeriod = widget.period * 1000000;
    _ticker = createTicker((elapsed) {
      _updateTimeRemaining();
    });
    _ticker.start();
    _updateTimeRemaining();
  }

  void _updateTimeRemaining() {
    int timeRemaining = (_microSecondsInPeriod) -
        (DateTime.now().microsecondsSinceEpoch % _microSecondsInPeriod);
    setState(() {
      _progress = (timeRemaining / _microSecondsInPeriod);
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return 
    LayoutBuilder(
      builder: (context, constrains) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: _progress > 0.4 ? Colors.green : Colors.red,
          ),
          width: constrains.maxWidth * _progress,
          height: 4,
        );
      },
    );
  }
}
