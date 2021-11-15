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

import 'dart:ffi';

import 'package:flutter/widgets.dart';
import 'package:yoga_engine/src/ffi/mapper.dart';

import '../../yoga_engine.dart';

class Point2DDebug {
  Point2DDebug(this.top, this.right, this.bottom, this.left);

  final double top;
  final double right;
  final double bottom;
  final double left;
}

class LayoutDebug {
  LayoutDebug(Mapper _mapper, Pointer<YGNode> node) {
    position = Point2DDebug(
      _mapper.yGNodeLayoutGetTop(node),
      _mapper.yGNodeLayoutGetRight(node),
      _mapper.yGNodeLayoutGetBottom(node),
      _mapper.yGNodeLayoutGetLeft(node)
    );

    margin = Point2DDebug(
      _mapper.yGNodeLayoutGetMargin(node, YGEdge.YGEdgeTop),
      _mapper.yGNodeLayoutGetMargin(node, YGEdge.YGEdgeRight),
      _mapper.yGNodeLayoutGetMargin(node, YGEdge.YGEdgeLeft),
      _mapper.yGNodeLayoutGetMargin(node, YGEdge.YGEdgeBottom),
    );

    padding = Point2DDebug(
      _mapper.yGNodeLayoutGetPadding(node, YGEdge.YGEdgeTop),
      _mapper.yGNodeLayoutGetPadding(node, YGEdge.YGEdgeRight),
      _mapper.yGNodeLayoutGetPadding(node, YGEdge.YGEdgeLeft),
      _mapper.yGNodeLayoutGetPadding(node, YGEdge.YGEdgeBottom),
    );

    border = Point2DDebug(
      _mapper.yGNodeLayoutGetBorder(node, YGEdge.YGEdgeTop),
      _mapper.yGNodeLayoutGetPadding(node, YGEdge.YGEdgeRight),
      _mapper.yGNodeLayoutGetPadding(node, YGEdge.YGEdgeLeft),
      _mapper.yGNodeLayoutGetPadding(node, YGEdge.YGEdgeBottom),
    );

    width = _mapper.yGNodeLayoutGetWidth(node);
    height = _mapper.yGNodeLayoutGetHeight(node);

    direction = _mapper.yGNodeLayoutGetDirection(node);
  }

  late final Point2DDebug position;
  late final Point2DDebug margin;
  late final Point2DDebug padding;
  late final Point2DDebug border;
  late final double width;
  late final double height;
  late final YGDirection direction;
}

class NodeHelper {
  final Mapper _mapper;

  NodeHelper(Mapper mapper) : _mapper = mapper;

  final _binding = Map<Pointer<YGNode>, RenderBox>();

  void setRenderBoxToNode(RenderBox renderBox, Pointer<YGNode> node) {
    _binding[node] = renderBox;
  }

  void removeNodeReference(Pointer<YGNode> node) {
    _binding.remove(node);
  }

  RenderBox? getRenderBoxFromNode(Pointer<YGNode> node) {
    return _binding[node];
  }

  double getLeft(Pointer<YGNode> node) {
    return _mapper.yGNodeLayoutGetLeft(node);
  }

  double getTop(Pointer<YGNode> node) {
    return _mapper.yGNodeLayoutGetTop(node);
  }

  double getLayoutWidth(Pointer<YGNode> node) {
    return _mapper.yGNodeLayoutGetWidth(node);
  }

  double getLayoutHeight(Pointer<YGNode> node) {
    return _mapper.yGNodeLayoutGetHeight(node);
  }

  LayoutDebug getLayoutDebug(Pointer<YGNode> node) {
    return LayoutDebug(_mapper, node);
  }
}
