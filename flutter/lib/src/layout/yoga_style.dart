/*
 * Copyright 2020 ZUP IT SERVICOS EM TECNOLOGIA E INOVACAO SA
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'package:yoga_engine/src/ffi/types.dart';

import 'node_properties.dart';

class YogaValue {
  YogaValue({this.auto = false, this.real, this.percent});
  final bool auto;
  final double? real;
  final double? percent;
}

class YogaPoint2D {
  YogaPoint2D({this.top, this.left, this.right, this.bottom, this.all});
  final YogaValue? top;
  final YogaValue? bottom;
  final YogaValue? left;
  final YogaValue? right;
  final YogaValue? all;
}

class YogaStyle {
  YogaStyle({
     this.width,
     this.height,
     this.minWidth,
     this.minHeight,
     this.maxWidth,
     this.maxHeight,
     this.direction,
     this.flexDirection,
     this.justifyContent,
     this.alignContent,
     this.alignItems,
     this.alignSelf,
     this.positionType,
     this.flexWrap,
     this.overflow,
     this.display,
     this.flex,
     this.grow,
     this.shrink,
     this.basis,
     this.position,
     this.margin,
     this.padding,
     this.border,
     this.aspectRatio,
  });

  final YogaValue? width;
  final YogaValue? height;
  final YogaValue? minWidth;
  final YogaValue? minHeight;
  final YogaValue? maxWidth;
  final YogaValue? maxHeight;
  final YGDirection? direction;
  final YGFlexDirection? flexDirection;
  final YGJustify? justifyContent;
  final YGAlign? alignContent;
  final YGAlign? alignItems;
  final YGAlign? alignSelf;
  final YGPositionType? positionType;
  final YGWrap? flexWrap;
  final YGOverflow? overflow;
  final YGDisplay? display;
  final double? flex;
  final double? grow;
  final double? shrink;
  final YogaValue? basis;
  final YogaPoint2D? position;
  final YogaPoint2D? margin;
  final YogaPoint2D? padding;
  final YogaPoint2D? border;
  final double? aspectRatio;
}

void _applyYogaValue({
  YogaValue? value,
  required void Function(double) setReal,
  void Function(double)? setPercent,
  void Function()? setAuto,
}) {
  if (value == null) return;
  if (value.auto && setAuto != null) setAuto();
  else if (value.percent != null && setPercent != null) setPercent(value.percent!);
  else if (value.real != null) setReal(value.real!);
}

void _applyProperty<T>(T? property, void Function(T) setter) {
  if (property != null) setter(property);
}

void _applyPoint2D({
  YogaPoint2D? value,
  void Function(YGEdge)? setAuto,
  void Function(YGEdge, double)? setPercent,
  required void Function(YGEdge, double) setReal,
}) {
  if (value == null) return;

  void _applyEdge(YogaValue? yogaValue, YGEdge edge) {
    _applyYogaValue(
      value: yogaValue,
      setAuto: setAuto == null ? null : () => setAuto(edge),
      setPercent: setPercent == null ? null : (double val) => setPercent(edge, val),
      setReal: (double val) => setReal(edge, val),
    );
  }

  _applyEdge(value.top, YGEdge.YGEdgeTop);
  _applyEdge(value.bottom, YGEdge.YGEdgeBottom);
  _applyEdge(value.left, YGEdge.YGEdgeLeft);
  _applyEdge(value.right, YGEdge.YGEdgeRight);
  _applyEdge(value.all, YGEdge.YGEdgeAll);
}

void applyStyleToNode(YogaStyle? style, NodeProperties node) {
  if (style == null) return;

  _applyYogaValue(
    value: style.width,
    setAuto: node.setWidthAuto,
    setPercent: node.setWidthPercent,
    setReal: node.setWidth,
  );

  _applyYogaValue(
    value: style.height,
    setAuto: node.setHeightAuto,
    setPercent: node.setHeightPercent,
    setReal: node.setHeight,
  );

  _applyYogaValue(
    value: style.maxWidth,
    setPercent: node.setMaxWidthPercent,
    setReal: node.setMaxWidth,
  );

  _applyYogaValue(
    value: style.maxHeight,
    setPercent: node.setMaxHeightPercent,
    setReal: node.setMaxHeight,
  );

  _applyYogaValue(
    value: style.minWidth,
    setPercent: node.setMinWidthPercent,
    setReal: node.setMinWidth,
  );

  _applyYogaValue(
    value: style.minHeight,
    setPercent: node.setMinHeightPercent,
    setReal: node.setMinHeight,
  );

  _applyYogaValue(
    value: style.basis,
    setAuto: node.setBasisAuto,
    setPercent: node.setBasisPercent,
    setReal: node.setBasis,
  );

  _applyProperty(style.direction, node.setDirection);
  _applyProperty(style.flexDirection, node.setFlexDirection);
  _applyProperty(style.justifyContent, node.setJustifyContent);
  _applyProperty(style.alignItems, node.setAlignItems);
  _applyProperty(style.alignSelf, node.setAlignSelf);
  _applyProperty(style.positionType, node.setPositionType);
  _applyProperty(style.flexWrap, node.setFlexWrap);
  _applyProperty(style.overflow, node.setOverflow);
  _applyProperty(style.display, node.setDisplay);
  _applyProperty(style.flex, node.setFlex);
  _applyProperty(style.grow, node.setGrow);
  _applyProperty(style.shrink, node.setShrink);
  _applyProperty(style.aspectRatio, node.setAspectRatio);

  _applyPoint2D(
    value: style.position,
    setPercent: node.setPositionPercent,
    setReal: node.setPosition,
  );

  _applyPoint2D(
    value: style.margin,
    setAuto: node.setMarginAuto,
    setPercent: node.setMarginPercent,
    setReal: node.setMargin,
  );

  _applyPoint2D(
    value: style.padding,
    setPercent: node.setPaddingPercent,
    setReal: node.setPadding,
  );

  _applyPoint2D(
    value: style.border,
    setReal: node.setBorder,
  );
}
