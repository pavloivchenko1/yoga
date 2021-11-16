/*
 * Copyright 2020 ZUP IT SERVICOS EM TECNOLOGIA E INOVACAO SA
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'dart:async';
import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:yoga_engine/src/ffi/types.dart';
import 'package:yoga_engine/src/layout/node_properties.dart';
import 'package:yoga_engine/src/utils/methods.dart';
import 'package:yoga_engine/src/utils/node_helper.dart';
import 'package:yoga_engine/src/utils/node_properties_extensions.dart';

import '../yoga_initializer.dart';

class YogaResult {
  const YogaResult({
    required this.width,
    required this.height,
    required this.top,
    required this.left,
  });

  final double width;
  final double height;
  final double top;
  final double left;
}

class RenderYogaResult extends RenderShiftedBox {
  RenderYogaResult(this._yogaResult, [RenderBox? child]) :
    computedSize = Size(_yogaResult.width + _yogaResult.left, _yogaResult.height + _yogaResult.top),
    super(child);

  YogaResult _yogaResult;
  Size computedSize;

  YogaResult get yogaResult => _yogaResult;

  set yogaResult(YogaResult yogaResult) {
    if (_yogaResult == yogaResult) return;
    _yogaResult = yogaResult;
    computedSize = Size(_yogaResult.width + _yogaResult.left, _yogaResult.height + _yogaResult.top);
    markNeedsLayout();
  }

  @override
  double computeMinIntrinsicWidth(_) {
    return _yogaResult.width;
  }

  @override
  double computeMaxIntrinsicWidth(_) {
    return _yogaResult.width;
  }

  @override
  double computeMinIntrinsicHeight(_) {
    return _yogaResult.height;
  }

  @override
  double computeMaxIntrinsicHeight(_) {
    return _yogaResult.height;
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return Size(_yogaResult.width, _yogaResult.height);
  }

  @override
  void performLayout() {
    if (child == null) {
      size = computedSize;
      return;
    }
    child!.layout(BoxConstraints.tight(Size(_yogaResult.width, _yogaResult.height)));
    final BoxParentData childParentData = child!.parentData! as BoxParentData;
    childParentData.offset = Offset(_yogaResult.left, _yogaResult.top);
    size = constraints.constrain(computedSize);
  }
}

class YogaResultWidget extends SingleChildRenderObjectWidget {
  const YogaResultWidget({
    Key? key,
    required this.result,
    Widget? child,
  }) : super(key: key, child: child);

  final YogaResult result;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderYogaResult(result);
  }
}

class MeasurableWidget extends StatefulWidget {
  const MeasurableWidget({Key? key, required this.child, required this.onSized}) : super(key: key);
  final Widget child;
  final void Function(Size size) onSized;

  @override
  _MeasurableWidgetState createState() => _MeasurableWidgetState();
}

class _MeasurableWidgetState extends State<MeasurableWidget> {
  bool _hasMeasured = false;
  @override
  Widget build(BuildContext context) {
    final renderObject = context.findRenderObject();
    Size size = renderObject == null ? Size.zero : (renderObject as RenderBox).size;
    if (size != Size.zero) {
      widget.onSized.call(size);
    } else if (!_hasMeasured) {
      // Need to build twice in order to get size
      scheduleMicrotask(() => setState(()=>_hasMeasured = true));
    }
    return widget.child;
  }
}

class YogaWidget extends StatefulWidget {
  YogaWidget({required this.properties, this.child, Key? key}) : super(key: key);

  final NodeProperties properties;
  final Widget? child;

  @override
  YogaWidgetState createState() => YogaWidgetState();
}

class YogaWidgetState extends State<YogaWidget> {
  YogaResult? yogaResult;
  YogaWidgetState? _parent;
  YogaWidgetState? _child;

  void setChild(YogaWidgetState nodeState) {
    _child = nodeState;
    widget.properties.insertChildAt(nodeState.widget.properties, 0);
  }

  void paintYogaLayout() {
    setState(() {
      yogaResult = YogaResult(
        width: widget.properties.getLayoutWidth(),
        height: widget.properties.getLayoutHeight(),
        top: widget.properties.getTop(),
        left: widget.properties.getLeft(),
      );
    });
    _child?.paintYogaLayout();
  }

  @override
  void initState() {
    _parent = context.findAncestorStateOfType<YogaWidgetState>();
    if (!widget.properties.isCalculated()) {
      if (_parent != null) _parent!.setChild(this);
    } else {
      yogaResult = YogaResult(
        width: widget.properties.getLayoutWidth(),
        height: widget.properties.getLayoutHeight(),
        top: widget.properties.getTop(),
        left: widget.properties.getLeft(),
      );
    }
    super.initState();
  }

  Widget preLayout() {
    return LayoutBuilder(
      builder: (_, BoxConstraints constraints) {
        return MeasurableWidget(
          child: widget.child ?? SizedBox.shrink(),
          onSized: (Size s) {
            final _isLeaf = widget.properties.getChildCount() == 0;
            if (_isLeaf) widget.properties.setOwnSize(s.width, s.height);
            if (_parent == null) { // is it the root node?
              scheduleMicrotask(() {
                widget.properties.calculateLayout(constraints.maxWidth, constraints.maxHeight);
                paintYogaLayout();
              });
            }
          },
        );
      },
    );
  }

  Widget layout() {
    return YogaResultWidget(result: yogaResult!, child: widget.child);
  }

  @override
  Widget build(BuildContext context) {
    return yogaResult == null ? preLayout() : layout();
  }

  /*@override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, BoxConstraints constraints) {
        return MeasurableWidget(
          child: YogaResultWidget(result: yogaResult, child: widget.child),
          onSized: (Size s) {
            if (yogaResult != null) return;
            final _isLeaf = widget.properties.getChildCount() == 0;
            if (_isLeaf) widget.properties.setOwnSize(s.width, s.height);
            if (_parent == null) { // is it the root node?
              scheduleMicrotask(() {
                widget.properties.calculateLayout(constraints.maxWidth, constraints.maxHeight);
                paintYogaLayout();
              });
            }
          },
        );
      },
    );
  }*/
}
