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

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

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
      if (renderObject!.parent is RenderObject) (renderObject.parent as RenderObject).markNeedsLayout();
      widget.onSized.call(size);
    } else if (!_hasMeasured) {
      // Need to build twice in order to get size
      scheduleMicrotask(() => setState(()=>_hasMeasured = true));
    }
    return widget.child;
  }
}

/*class _MeasurableWidgetState extends State<MeasurableWidget> {
  Size previous = Size.zero;
  @override
  Widget build(BuildContext context) {
    final renderObject = context.findRenderObject();
    if (renderObject != null) {
      Size size = (renderObject as RenderBox).getDryLayout(BoxConstraints.expand());
      if (size != previous) {
        previous = size;
        widget.onSized(size);
      }
    }
    return widget.child;
  }
}*/

typedef void OnWidgetSizeChange(Size size);

class MeasureSizeRenderObject extends RenderProxyBox {
  Size oldSize = Size.zero;
  final OnWidgetSizeChange onChange;

  MeasureSizeRenderObject(this.onChange);

  @override
  void performLayout() {
    super.performLayout();

    Size newSize = child!.size;
    if (oldSize == newSize) return;

    oldSize = newSize;
    WidgetsBinding.instance!.addPostFrameCallback((_) {
       onChange(newSize);
    });
  }
}

class MeasureSize extends SingleChildRenderObjectWidget {
  final OnWidgetSizeChange onChange;

  const MeasureSize({
    Key? key,
    required this.onChange,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return MeasureSizeRenderObject(onChange);
  }
}
