import 'dart:async';

import 'package:flutter/services.dart';

class OptimizelyPlugin {
  const OptimizelyPlugin();

  static const MethodChannel _channel =
      const MethodChannel('optimizely_plugin');

  Future<void> initOptimizelyManager(
    String sdkKey,
    String dataFile,
  ) async {
    await _channel.invokeMethod('initOptimizelyManager', <String, dynamic>{
      'sdk_key': sdkKey,
      'datafile': dataFile,
    });
  }

  Future<void> initOptimizelyManagerAsync(
    String sdkKey,
  ) async {
    await _channel.invokeMethod('initOptimizelyManagerAsync', <String, dynamic>{
      'sdk_key': sdkKey,
    });
  }

  Future<void> setUser(
      userID,
      Map<String, dynamic> attributes,
      ) async {
    await _channel.invokeMethod('setUser', <String, dynamic>{
      'user_id': userID,
      'attributes': attributes
    });
  }

  Future<bool?> isFeatureEnabled(
    String featureKey,
  ) async {
    var res = await _channel.invokeMethod('isFeatureEnabled', <String, dynamic>{
      'feature_key': featureKey,
    });
    return res;
  }

  Future<Map<String, dynamic>> getAllFeatureVariables(
    String featureKey,
  ) async {
    final featureVariables =
        await _channel.invokeMethod('getAllFeatureVariables', <String, dynamic>{
      'feature_key': featureKey,
    });
    return Map<String, dynamic>.from(featureVariables);
  }

  //https://docs.developers.optimizely.com/full-stack/docs/run-a-b-tests
  //TODO: deprecate: use activateGetVariation
  Future<String?> getVariation(
    String featureKey,
    userID,
    Map<String, dynamic> attributes,
  ) async {
    final variation =
        await _channel.invokeMethod('getVariation', <String, dynamic>{
      'feature_key': featureKey,
      'user_id': userID,
      'attributes': attributes,
    });
    return variation;
  }

  Future<Map<String, dynamic>> getAllEnabledFeatures() async {
    final enabledFeatures =
    await _channel.invokeMethod('getAllEnabledFeatures');
    return Map<String, dynamic>.from(enabledFeatures);
  }

  Future<String?> activateGetVariation(
      String experimentKey,
      ) async {
    final variation =
    await _channel.invokeMethod('getAllFeatureVariables', <String, dynamic>{
      'feature_key': experimentKey,
    });
    return variation;
  }

  Future<void> trackEvent(
    String eventKey,
    Map<String, dynamic> eventTags,
  ) async {
    await _channel.invokeMethod('trackEvent', <String, dynamic>{
      'feature_key': eventKey,
      'event_tags': eventTags,
    });
  }
}
