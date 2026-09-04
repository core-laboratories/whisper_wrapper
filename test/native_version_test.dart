import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('vendored whisper.cpp revision matches platform build metadata', () {
    final manifest = File('WHISPER_CPP_VERSION').readAsLinesSync();
    final values = <String, String>{
      for (final line in manifest)
        if (line.contains('='))
          line.substring(0, line.indexOf('=')): line.substring(
            line.indexOf('=') + 1,
          ),
    };

    expect(values['tag'], matches(RegExp(r'^v\d+\.\d+\.\d+$')));
    expect(values['commit'], matches(RegExp(r'^[0-9a-f]{40}$')));

    final version = values['tag']!.substring(1);
    for (final path in <String>[
      'android/src/whisper/CMakeLists.txt',
      'linux/CMakeLists.txt',
      'windows/CMakeLists.txt',
      'ios/whisper_wrapper.podspec',
      'macos/whisper_wrapper.podspec',
    ]) {
      expect(
        File(path).readAsStringSync(),
        contains('whisper.cpp-v$version'),
        reason: '$path must identify the vendored native engine',
      );
    }
  });
}
