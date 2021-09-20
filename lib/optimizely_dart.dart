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

  //https://docs.developers.optimizely.com/full-stack/docs/run-feature-tests
  Future<bool?> isFeatureEnabled(
    String featureKey,
    userID,
    Map<String, dynamic> attributes,
  ) async {
    var res = await _channel.invokeMethod('isFeatureEnabled', <String, dynamic>{
      'feature_key': featureKey,
      'user_id': userID,
      'attributes': attributes
    });
    return res;
  }

  //https://docs.developers.optimizely.com/full-stack/docs/test-with-feature-configuration
  Future<Map<String, dynamic>> getAllFeatureVariables(
    String featureKey,
    userID,
    Map<String, dynamic> attributes,
  ) async {
    final featureVariables =
        await _channel.invokeMethod('getAllFeatureVariables', <String, dynamic>{
      'feature_key': featureKey,
      'user_id': userID,
      'attributes': attributes,
    });
    return Map<String, dynamic>.from(featureVariables);
  }

  //https://docs.developers.optimizely.com/full-stack/docs/run-a-b-tests
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

  //https://docs.developers.optimizely.com/full-stack/docs/track-events
  //https://docs.developers.optimizely.com/full-stack/docs/include-event-tags
  // eventTags.addAll({"revenue", 4200}); Reserved "revenue" tag
  Future trackEvent(
    String featureKey,
    userID,
    Map<String, dynamic> attributes,
    Map<String, dynamic> eventTags,
  ) async {
    await _channel.invokeMethod('trackEvent', <String, dynamic>{
      'feature_key': featureKey,
      'user_id': userID,
      'attributes': attributes,
      'event_tags': eventTags,
    });
  }
}
