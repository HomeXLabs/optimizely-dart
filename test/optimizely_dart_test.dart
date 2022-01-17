import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:optimizely_dart/optimizely_dart.dart';

void main() {
  const MethodChannel channel = MethodChannel('optimizely_plugin');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'initOptimizelyManager':
          break;
        case 'isFeatureEnabled':
          var featureKey = methodCall.arguments['feature_key'];
          if (featureKey == 'flutter') {
            return true;
          }
          return false;
        case 'getAllFeatureVariables':
          var featureKey = methodCall.arguments['feature_key'];
          if (featureKey == 'calculator') {
            return {'calc_type': 'scientific'};
          }
          return {};
        default:
          break;
      }
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('initOptimizelyManager', () async {
    try {
      final optimizelyPlugin = OptimizelyPlugin();
      optimizelyPlugin.initOptimizelyManager(
        'sdkKey',
        'dataFile',
      );
    } on PlatformException catch (error) {
      throw error;
    }
  });

  test('isFeatureEnabled', () async {
    final optimizelyPlugin = OptimizelyPlugin();
    final enabled = await optimizelyPlugin.isFeatureEnabled(
      'flutter',
    );
    expect(enabled, true);
  });

  test('getAllFeatureVariables', () async {
    final optimizelyPlugin = OptimizelyPlugin();
    var features = await optimizelyPlugin.getAllFeatureVariables(
      'calculator',
    );
    expect(features['calc_type'], 'scientific');
  });
}
