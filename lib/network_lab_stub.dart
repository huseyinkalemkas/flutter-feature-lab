import 'package:flutter/material.dart';

class NetworkLabScreen extends StatelessWidget {
  final VoidCallback? onHome;
  const NetworkLabScreen({super.key, this.onHome});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Network Lab')),
    body: const Center(child: Text('Soket testi web ortamında kullanılamaz.')),
  );
}
