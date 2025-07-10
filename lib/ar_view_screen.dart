import 'package:flutter/material.dart';
import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:vector_math/vector_math_64.dart' as vm;
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/rendering.dart';
import 'dart:typed_data';

class ARViewScreen extends StatefulWidget {
  const ARViewScreen({super.key});

  @override
  State<ARViewScreen> createState() => _ARViewScreenState();
}

class _ARViewScreenState extends State<ARViewScreen> {
  late ARKitController arkitController;
  ARKitNode? currentNode;
  vm.Vector3 _lastPosition = vm.Vector3(0, 0, -0.5);
  double _lastScale = 0.2;
  Offset? _lastFocalPoint;
  String _currentModelPath = '';
  bool _isReferenceNode = false;
  final GlobalKey _repaintKey = GlobalKey();

  @override
  void dispose() {
    arkitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AR Viewer')),
      body: Stack(
        children: [
          RepaintBoundary(
            key: _repaintKey,
            child: GestureDetector(
              onScaleStart: (details) {
                _lastFocalPoint = details.focalPoint;
              },
              onScaleUpdate: (details) {
                if (currentNode != null) {
                  // Di chuyển (pan): dựa vào sự thay đổi của focalPoint
                  if (_lastFocalPoint != null) {
                    final dx = (details.focalPoint.dx - _lastFocalPoint!.dx) / 100;
                    final dy = (details.focalPoint.dy - _lastFocalPoint!.dy) / 100;
                    _lastPosition += vm.Vector3(dx, -dy, 0);
                    _lastFocalPoint = details.focalPoint;
                  }
                  // Scale (pinch)
                  final newScale = (_lastScale * details.scale).clamp(0.05, 2.0);
                  _replaceNode(position: _lastPosition, scale: newScale);
                }
              },
              onScaleEnd: (details) {
                if (currentNode != null) {
                  _lastScale = currentNode!.scale?.x ?? 0.2;
                }
                _lastFocalPoint = null;
              },
              onDoubleTap: () {
                if (currentNode != null) {
                  _lastPosition = vm.Vector3(0, 0, -0.5);
                  _lastScale = 0.2;
                  _replaceNode(position: _lastPosition, scale: _lastScale);
                }
              },
              child: ARKitSceneView(
                onARKitViewCreated: onARKitViewCreated,
                planeDetection: ARPlaneDetection.horizontalAndVertical,
              ),
            ),
          ),
          Positioned(
            bottom: 32,
            left: 16,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add_box),
              label: const Text('Chọn mô hình 3D'),
              onPressed: pickAndLoadModel,
            ),
          ),
          Positioned(
            bottom: 32,
            right: 16,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text('Chụp màn hình'),
              onPressed: captureARScreen,
            ),
          ),
        ],
      ),
    );
  }

  void _replaceNode({required vm.Vector3 position, required double scale}) {
    if (currentNode != null) {
      arkitController.remove(currentNode!.name);
    }
    ARKitNode node;
    if (_isReferenceNode && _currentModelPath.isNotEmpty) {
      node = ARKitReferenceNode(
        url: _currentModelPath,
        position: position,
        scale: vm.Vector3.all(scale),
      );
    } else {
      node = ARKitNode(
        geometry: ARKitSphere(
          materials: [ARKitMaterial(diffuse: ARKitMaterialProperty.color(Colors.blue))],
          radius: 0.1,
        ),
        position: position,
        scale: vm.Vector3.all(scale),
      );
    }
    arkitController.add(node);
    currentNode = node;
  }

  void onARKitViewCreated(ARKitController controller) {
    arkitController = controller;
    _isReferenceNode = false;
    _currentModelPath = '';
    _lastPosition = vm.Vector3(0, 0, -0.5);
    _lastScale = 0.2;
    final node = ARKitNode(
      geometry: ARKitSphere(
        materials: [ARKitMaterial(diffuse: ARKitMaterialProperty.color(Colors.blue))],
        radius: 0.1,
      ),
      position: _lastPosition,
      scale: vm.Vector3.all(_lastScale),
    );
    arkitController.add(node);
    currentNode = node;
  }

  Future<void> pickAndLoadModel() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['usdz', 'scn', 'dae'],
    );
    if (result != null && result.files.single.path != null) {
      final filePath = result.files.single.path!;
      if (currentNode != null) {
        arkitController.remove(currentNode!.name);
      }
      final node = ARKitReferenceNode(
        url: filePath,
        position: vm.Vector3(0, 0, -0.5),
        scale: vm.Vector3.all(0.2),
      );
      arkitController.add(node);
      currentNode = node;
      _isReferenceNode = true;
      _currentModelPath = filePath;
      _lastPosition = vm.Vector3(0, 0, -0.5);
      _lastScale = 0.2;
    }
  }

  Future<void> captureARScreen() async {
    try {
      RenderRepaintBoundary boundary = _repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        final buffer = byteData.buffer;
        final directory = await getTemporaryDirectory();
        final filePath = '${directory.path}/ar_screenshot_${DateTime.now().millisecondsSinceEpoch}.png';
        final file = File(filePath);
        await file.writeAsBytes(buffer.asUint8List());
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đã lưu ảnh AR: $filePath')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Chụp màn hình thất bại: $e')),
        );
      }
    }
  }
}

