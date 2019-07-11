import 'dart:async';

import 'package:farmsmart_flutter/ui/common/CircularPainter.dart';
import 'package:flutter/material.dart';

import 'network_image_from_future.dart';

class CircularProgressViewModel {
  double initialValue;
  List<Widget> content;

  CircularProgressViewModel(
      {@required this.initialValue, @required this.content});
}

CircularProgressViewModel buildCircularProgressViewModel(
    {@required double initialValue, @required List<Widget> content}) {
  return CircularProgressViewModel(
      initialValue: initialValue, content: content);
}

class CircularProgressStyle {
  final double height;
  final double width;
  final Color completeColor;
  final Color lineColor;
  final double lineWidth;
  final EdgeInsets innerPadding;

  const CircularProgressStyle(
      {this.height,
      this.width,
      this.completeColor,
      this.lineColor,
      this.lineWidth,
      this.innerPadding});

  CircularProgressStyle copyWith(
      {double height,
      double width,
      Color completeColor,
      Color lineColor,
      double lineWidth,
      EdgeInsets edgePadding}) {
    return CircularProgressStyle(
      height: height ?? this.height,
      width: width ?? this.width,
      completeColor: completeColor ?? this.completeColor,
      lineColor: lineColor ?? this.lineColor,
      lineWidth: lineWidth ?? this.lineColor,
      innerPadding: innerPadding ?? this.innerPadding,
    );
  }
}

class _DefaultStyle extends CircularProgressStyle {
  final double height = 87;
  final double width = 87;
  final Color completeColor = const Color(0xff24d900);
  final Color lineColor = Colors.transparent;
  final double lineWidth = 3;
  final EdgeInsets innerPadding = const EdgeInsets.all(4.0);

  const _DefaultStyle(
      {double height,
      double width,
      Color completeColor,
      Color lineColor,
      double testWidth,
      EdgeInsets edgePadding});
}

const CircularProgressStyle _defaultStyle = const _DefaultStyle();

class CircularProgress extends StatefulWidget {
  final CircularProgressViewModel _viewModel;
  final CircularProgressStyle _style;

  const CircularProgress(
      {Key key,
      @required CircularProgressViewModel viewModel,
      CircularProgressStyle style = _defaultStyle})
      : this._viewModel = viewModel,
        this._style = style,
        super(key: key);

  @override
  _CircularProgressState createState() => _CircularProgressState();
}

class _CircularProgressState extends State<CircularProgress> {
  double defaultValue = 0;
  double percentageComplete = 100.0;

  @override
  void initState() {
    super.initState();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: widget._style.height,
        width: widget._style.width,
        child: CustomPaint(
          foregroundPainter: CircularPainter(
              lineColor: widget._style.lineColor,
              completeColor: widget._style.completeColor,
              completePercent: widget._viewModel.initialValue,
              width: widget._style.lineWidth),
          child: Padding(
            padding: widget._style.innerPadding,
            child: ClipOval(
              child: Stack(children: widget._viewModel.content),
            ),
          ),
        ),
      ),
    );
  }
}
