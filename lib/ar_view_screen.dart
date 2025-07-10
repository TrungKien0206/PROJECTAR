import 'package:flutter/material.dart';
import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

class ARViewScreen extends StatefulWidget {
  const ARViewScreen({super.key});

  @override
  State<ARViewScreen> createState() => _ARViewScreenState();
}

class _ARViewScreenState extends State<ARViewScreen> {
  late ARKitController arkitController;

  @override
  void dispose() {
    arkitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AR Viewer')),
      body: ARKitSceneView(
        onARKitViewCreated: onARKitViewCreated,
        planeDetection: ARPlaneDetection.horizontalAndVertical,
      ),
    );
  }

  void onARKitViewCreated(ARKitController controller) {
    arkitController = controller;
    final node = ARKitNode(
      geometry: ARKitSphere(
        materials: [ARKitMaterial(diffuse: ARKitMaterialProperty.color(Colors.blue))],
        radius: 0.1,
      ),
      position: vm.Vector3(0, 0, -0.5),
    );
    arkitController.add(node);
  }
}

