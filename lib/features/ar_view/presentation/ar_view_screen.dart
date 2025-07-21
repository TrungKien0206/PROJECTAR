// File này thuộc features/ar_view/presentation - màn hình AR chính
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
import 'package:model_viewer_plus/model_viewer_plus.dart';

class ARViewScreen extends StatefulWidget {
  const ARViewScreen({super.key});

  @override
  State<ARViewScreen> createState() => _ARViewScreenState();
}

class _ARViewScreenState extends State<ARViewScreen> {
  late ARKitController arkitController;
  ARKitNode? currentNode;
  vm.Vector3 _lastPosition = vm.Vector3(0, 0, -0.5);
  double _lastScale = 0.1; // scale mặc định nhỏ
  double _sliderScale = 0.1; // scale điều khiển bởi slider
  Offset? _lastFocalPoint;
  String _currentModelPath = '';
  bool _isReferenceNode = false;
  final GlobalKey _repaintKey = GlobalKey();
  bool _isLocked = false;
  bool _isARMode = true;

  @override
  void dispose() {
    arkitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isARMode
          ? AppBar(
              title: const Text('AR Viewer'),
              actions: [
                IconButton(
                  icon: Icon(_isARMode ? Icons.view_in_ar : Icons.threed_rotation),
                  tooltip: _isARMode ? 'Chuyển sang 3D' : 'Chuyển sang AR',
                  onPressed: () {
                    setState(() {
                      _isARMode = !_isARMode;
                    });
                  },
                ),
              ],
            )
          : null,
      body: Stack(
        children: [
          if (_isARMode)
            RepaintBoundary(
              key: _repaintKey,
              child: GestureDetector(
                onScaleStart: (details) {
                  if (_isLocked) return;
                  _lastFocalPoint = details.focalPoint;
                },
                onScaleUpdate: (details) {
                  if (_isLocked) return;
                  if (currentNode != null) {
                    // Chỉ xử lý pan (di chuyển), không xử lý scale gesture
                    if (_lastFocalPoint != null) {
                      final dx = (details.focalPoint.dx - _lastFocalPoint!.dx) / 100;
                      final dy = (details.focalPoint.dy - _lastFocalPoint!.dy) / 100;
                      _lastPosition += vm.Vector3(dx, -dy, 0);
                      _lastFocalPoint = details.focalPoint;
                      _replaceNode(position: _lastPosition, scale: _sliderScale);
                    }
                  }
                },
                onScaleEnd: (details) {
                  if (_isLocked) return;
                  _lastFocalPoint = null;
                },
                onDoubleTap: () {
                  if (_isLocked) return;
                  if (currentNode != null) {
                    _lastPosition = vm.Vector3(0, 0, -0.5);
                    _sliderScale = 0.1;
                    _replaceNode(position: _lastPosition, scale: _sliderScale);
                  }
                },
                child: ARKitSceneView(
                  onARKitViewCreated: onARKitViewCreated,
                  planeDetection: ARPlaneDetection.horizontalAndVertical,
                ),
              ),
            )
          else
            Center(
              child: _modelViewerSrc != null
                  ? ModelViewer(
                      src: _modelViewerSrc!,
                      alt: "3D model",
                      ar: false,
                      autoRotate: true,
                      cameraControls: true,
                      backgroundColor: Colors.white,
                    )
                  : _currentModelPath.isEmpty
                      ? const Text('Chưa có mô hình nào được chọn', style: TextStyle(fontSize: 18))
                      : const Text('Chỉ hỗ trợ xem 3D với file .usdz', style: TextStyle(fontSize: 18, color: Colors.red)),
            ),
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // ĐÃ XOÁ các nút ElevatedButton.icon và Slider cũ ở dưới
                if (_isARMode)
                  Positioned(
                    bottom: 32,
                    right: 24,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _ARCircleButton(
                          icon: Icons.add_box,
                          onTap: pickAndLoadModel,
                          tooltip: 'Chọn mô hình 3D',
                        ),
                        const SizedBox(width: 18),
                        _ARCircleButton(
                          icon: Icons.camera_alt,
                          onTap: captureARScreen,
                          tooltip: 'Chụp màn hình',
                        ),
                        const SizedBox(width: 18),
                        _ARCircleButton(
                          icon: _isLocked ? Icons.lock : Icons.lock_open,
                          onTap: () {
                            setState(() {
                              _isLocked = !_isLocked;
                            });
                          },
                          tooltip: _isLocked ? 'Đã khoá' : 'Mở khoá',
                        ),
                      ],
                    ),
                  ),
                if (_isARMode)
                  Positioned(
                    bottom: 32,
                    left: 24,
                    child: Card(
                      color: Colors.black.withOpacity(0.7),
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.zoom_out, color: Colors.white),
                            SizedBox(
                              width: 120,
                              child: Slider(
                                value: _sliderScale,
                                min: 0.05,
                                max: 1.0,
                                divisions: 19,
                                onChanged: _isLocked ? null : (value) {
                                  setState(() {
                                    _sliderScale = value;
                                    _replaceNode(position: _lastPosition, scale: _sliderScale);
                                  });
                                },
                              ),
                            ),
                            const Icon(Icons.zoom_in, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
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
    _lastScale = 0.1;
    _sliderScale = 0.1;
    final node = ARKitNode(
      geometry: ARKitSphere(
        materials: [ARKitMaterial(diffuse: ARKitMaterialProperty.color(Colors.blue))],
        radius: 0.1,
      ),
      position: _lastPosition,
      scale: vm.Vector3.all(_sliderScale),
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
      _isReferenceNode = true;
      _currentModelPath = filePath;
      _lastPosition = vm.Vector3(0, 0, -0.5);
      _lastScale = 0.1;
      _sliderScale = 0.1;
      _replaceNode(position: _lastPosition, scale: _sliderScale);
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

  String? get _modelViewerSrc {
    if (_currentModelPath.isEmpty) return null;
    if (_currentModelPath.endsWith('.usdz')) {
      if (_currentModelPath.startsWith('http')) {
        return _currentModelPath;
      } else {
        return 'file://$_currentModelPath';
      }
    }
    return null;
  }
}

class _ARCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;
  const _ARCircleButton({required this.icon, required this.onTap, this.tooltip});
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.7),
      shape: const CircleBorder(),
      elevation: 4,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Tooltip(
          message: tooltip ?? '',
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }
}

