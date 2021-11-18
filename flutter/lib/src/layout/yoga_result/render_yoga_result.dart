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

import 'package:flutter/rendering.dart';

import 'yoga_result.dart';

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
    final childConstraints = BoxConstraints(
      minWidth: _yogaResult.width,
      minHeight: _yogaResult.height,
      maxWidth: _yogaResult.isFixedWidth ? _yogaResult.width : double.infinity,
      maxHeight: _yogaResult.isFixedHeight ? _yogaResult.height : double.infinity,
    );
    child!.layout(childConstraints);
    final BoxParentData childParentData = child!.parentData! as BoxParentData;
    childParentData.offset = Offset(_yogaResult.left, _yogaResult.top);
    size = constraints.constrain(computedSize);
  }
}
