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
import 'package:yoga_engine/yoga_engine.dart';
void main() {
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}
class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}
class _MyHomePageState extends State<MyHomePage> {
  _MyHomePageState() {
    Yoga.init();
    _firstYogaLayoutProperties = NodeProperties();
    _lastYogaLayoutProperties = NodeProperties();
    _firstYogaNodeProperties = NodeProperties();
    _lastYogaNodeProperties = NodeProperties();
    _firstYogaLayoutProperties.setPadding(YGEdge.YGEdgeTop, 40);
  }
  int _counter = 1;
  double _size = 20;
  late NodeProperties _firstYogaLayoutProperties;
  late NodeProperties _lastYogaLayoutProperties;
  late NodeProperties _firstYogaNodeProperties;
  late NodeProperties _lastYogaNodeProperties;
  List<Widget> _buildLines() {
    final List<Widget> lines = [];
    for (int i = 1; i <= _counter; i++) {
      lines.add(Text('Line $i', key: Key('$i')));
    }
    return lines;
  }
  Widget _buildLinesExample() {
    return Column(
      children: [
        ..._buildLines(),
        ElevatedButton(
          child: const Text('Add one more line'),
          onPressed: () => setState(() {
            _counter++;
          }),
        )
      ],
    );
  }
  Widget _buildImageExample() {
    return Image.network('https://mcdn.wallpapersafari.com/medium/8/37/zlwnoM.jpg');
  }
  // VERY, VERY WEIRD
  Widget _buildRectangleExample() {
    return GestureDetector(
      onTap: () => setState(() {
        _size *= 2;
      }),
      child: SizedBox.square(
        dimension: _size,
        child: const DecoratedBox(
          decoration: BoxDecoration(color: Colors.red),
        ),
      ),
    );
  }
  Widget _buildTextExample() {
    return GestureDetector(
      onTap: () => setState(() {
        _size *= 1.2;
      }),
      child: Text('Click to enlarge', style: TextStyle(fontSize: _size, backgroundColor: Colors.white)),
    );
  }
  Widget _buildDoubleYoga(Widget child) {
    return YogaLayout(
      nodeProperties: _firstYogaLayoutProperties,
      children: [
        MeasureSize(child: YogaMetadataWidget(
          nodeProperties: _firstYogaNodeProperties,
          child: YogaLayout(
            nodeProperties: _lastYogaLayoutProperties,
            children: [
              MeasureSize(child: YogaMetadataWidget(
                nodeProperties: _lastYogaNodeProperties,
                child: child,
              )),
            ],
          ),
        )),
      ],
    );
  }
  Widget _buildYoga(Widget child) {
    return YogaLayout(
      nodeProperties: _firstYogaLayoutProperties,
      children: [
        YogaMetadataWidget(
          nodeProperties: _lastYogaNodeProperties,
          child: child,
        ),
      ],
    );
  }
  Widget _buildFlex(Widget child) {
    return Row(children: [child]);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _buildDoubleYoga(_buildTextExample())),
      backgroundColor: Colors.orangeAccent,
    );
  }
}
