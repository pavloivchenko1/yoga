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

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:yoga_engine/src/layout/node_properties.dart';
import 'package:yoga_engine/src/layout/yoga_result/yoga_result.dart';

import 'yoga_style.dart';

class YogaNodeAbstraction {
  YogaNodeAbstraction([this.style]);

  YogaStyle? style;
  late YogaNodeAbstraction root;
  YogaNodeAbstraction? child;
  late NodeProperties _current;
  bool _isCalculated = false;
  Size? size;
  void Function(YogaResult result)? _changeListener;
  YogaResult? _yogaResult;

  void buildNode() {
    _current = NodeProperties();
    if (size != null) {
      _current.setOwnSize(size!.width, size!.height);
    }
    applyStyleToNode(style, _current);
  }

  NodeProperties buildYogaTree([NodeProperties? parent]) {
    buildNode();
    if (child != null) child!.buildYogaTree(_current);
    if (parent != null) parent.insertChildAt(_current, 0);
    return _current;
  }

  bool get isCalculated => _isCalculated;

  bool isLeaf() => child == null;

  void _setYogaResult() {
    _yogaResult = YogaResult(
      width: _current.getLayoutWidth(),
      height: _current.getLayoutHeight(),
      top: _current.getTop(),
      left: _current.getLeft(),
      isFixedWidth: style?.width?.real != null || style?.width?.percent != null,
      isFixedHeight: style?.height?.real != null || style?.height?.percent != null,
    );
  }

  void Function() onChange(void Function(YogaResult result) listener) {
    _changeListener = listener;
    if (_yogaResult != null) listener(_yogaResult!);
    return () => _changeListener = null;
  }

  void update() {
    _isCalculated = true;
    _setYogaResult();
    if (_changeListener != null && _yogaResult !=  null) {
      _changeListener!(_yogaResult!);
    }
    if (child != null) child!.update();
    // calloc.free(_current.node);
  }

  void calculateLayout(BoxConstraints constraints) {
    if (root != this) {
      throw ErrorDescription('calculateLayout can only be called for the root node! Are you sure it\'s the root?');
    }
    final tree = buildYogaTree();
    tree.calculateLayout(constraints.maxWidth, constraints.maxHeight);
    update();
  }
}
