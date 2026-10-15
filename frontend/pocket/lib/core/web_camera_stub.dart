import 'package:flutter/widgets.dart';

/// Stub untuk platform non-web (tidak pernah dipanggil).
class WebCamera {
  bool get canFlip => false;
  bool get isFront => true;
  Widget buildView() => const SizedBox.shrink();
  Future<void> start({bool front = true}) async =>
      throw UnsupportedError('WebCamera hanya untuk web');
  Future<bool> flip() async => false;
  Future<String> capture() async =>
      throw UnsupportedError('WebCamera hanya untuk web');
  Future<void> dispose() async {}
}
