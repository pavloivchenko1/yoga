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

import 'package:flutter/widgets.dart';

import 'render_yoga_result.dart';
import 'yoga_result.dart';

class YogaResultWidget extends SingleChildRenderObjectWidget {
  const YogaResultWidget({
    Key? key,
    required this.result,
    Widget? child,
  }) : super(key: key, child: child);

  final YogaResult result;

  @override
  void updateRenderObject(BuildContext context, covariant RenderYogaResult renderObject) {
    renderObject.yogaResult = result;
    super.updateRenderObject(context, renderObject);
  }

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderYogaResult(result);
  }
}
