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

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:yoga_engine/src/layout/yoga_node_abstraction.dart';
import 'package:yoga_engine/src/layout/yoga_style.dart';

import 'measurable_widget.dart';
import 'yoga_result/yoga_result.dart';
import 'yoga_result/yoga_result_widget.dart';

final Map<Key, YogaNodeAbstraction> _yogaNodes = {};

class YogaWidget extends StatefulWidget {
  YogaWidget({
    this.child,
    required Key key,
    YogaStyle? style,
  }) :
  isFixedWidth = style?.width?.real != null || style?.width?.percent != null,
  isFixedHeight = style?.width?.real != null || style?.width?.percent != null,
  super(key: key) {
    if (_yogaNodes[key] == null) {
      _yogaNodes[key] = YogaNodeAbstraction(style);
    }
    yogaNode = _yogaNodes[key]!;
  }

  final Widget? child;
  final bool isFixedWidth;
  final bool isFixedHeight;
  late final YogaNodeAbstraction yogaNode;

  @override
  YogaWidgetState createState() => YogaWidgetState();
}

class YogaWidgetState extends State<YogaWidget> {
  YogaResult? _yogaResult;
  YogaWidgetState? parent;
  BoxConstraints? _constraints;
  Size _size = Size(0, 0);
  late void Function() unsubscribe;

  @override
  void initState() {
    parent = context.findAncestorStateOfType<YogaWidgetState>();
    if (parent != null) {
      parent!.widget.yogaNode.child = widget.yogaNode;
      widget.yogaNode.root = parent!.widget.yogaNode.root;
    } else {
      widget.yogaNode.root = widget.yogaNode;
    }
    unsubscribe = widget.yogaNode.onChange((result) {
      setState(() => _yogaResult = result);
    });
    super.initState();
  }

  /*@override
  void dispose() {
    unsubscribe();
    super.dispose();
  }*/

  void calculateLayout() {
    widget.yogaNode.calculateLayout(_constraints!);
  }

  Widget preLayout() {
    return LayoutBuilder(
      builder: (_, BoxConstraints constraints) {
        _constraints = constraints;
        return MeasureSize(
          child: widget.child ?? SizedBox.shrink(),
          onChange: (Size s) {
            _size = s;
            if (widget.yogaNode.isLeaf()) widget.yogaNode.size = s;
            if (parent == null) { // is it the root node?
              scheduleMicrotask(calculateLayout);
            }
          },
        );
      },
    );
  }

  YogaWidgetState _getRootWidget() {
    YogaWidgetState root = this;
    while (root.parent != null) root = root.parent!;
    return root;
  }

  onSizeChange(Size s) {
    if (_size == s) return;
    _size = s;
    final isLeaf = widget.yogaNode.isLeaf();
    if (!isLeaf) return;
    widget.yogaNode.size = s;
    scheduleMicrotask(() => _getRootWidget().calculateLayout());
  }

  Widget layout() {
    return YogaResultWidget(
      result: _yogaResult!,
      child: MeasureSize(
        child: widget.child ?? SizedBox.shrink(),
        onChange: onSizeChange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _yogaResult == null ? preLayout() : layout();
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
