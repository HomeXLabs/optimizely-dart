# optimizely_dart ![Flutter 2.10.0](https://img.shields.io/badge/Flutter-2.10.0-blue)

Flutter/Dart plugin for Optimizely native SDKs,

## Getting Started

Currently [Optimizely](https://www.optimizely.com/) does not offer a dedicated flutter SDK. This flutter plugin is bridging the gap between a flutter application and the native optimizely [FULL STACK SDKs](https://docs.developers.optimizely.com/full-stack/docs) for [Android](https://docs.developers.optimizely.com/full-stack/docs/android-sdk) and [iOS](https://docs.developers.optimizely.com/full-stack/docs/swift-sdk). 

## Usage

**You need to init and set up user before using any functions**

functions supported:
[`isFeatureEnabled`](https://docs.developers.optimizely.com/full-stack/docs/is-feature-enabled-android) 
[`getAllFeatureVariables`](https://docs.developers.optimizely.com/full-stack/docs/get-all-feature-variables-android).
[`getAllEnabledFeatures`](https://docs.developers.optimizely.com/full-stack/docs/get-all-feature-variables-android).
[`activategetVariable`](https://docs.developers.optimizely.com/full-stack/docs/get-all-feature-variables-android).
[`getVariable`](https://docs.developers.optimizely.com/full-stack/docs/get-all-feature-variables-android).
[`trackEvent`](https://docs.developers.optimizely.com/full-stack/docs/get-all-feature-variables-android).
 
```dart
import 'package:optimizely_dart/optimizely_dart.dart';
await OptimizelyPlugin.initOptimizelyManager('your_optimizely_sdk_key');
...
  unawaited(OptimizelyPlugin().setUser(_personManager.person?.id, {'isLoggedIn':true}));
...
bool featureEnabled = await OptimizelyPlugin.isFeatureEnabled('your_flag', 'some_user@xyz.com');

 var variation = await OptimizelyPlugin().getVariation('your_flag', 'some_user@xyz.com',{});

await OptimizelyPlugin().trackEvent('name', 'some_user@xyz.com',{});
```

## Installation

Add `optimizely_dart` as a dependency in your project's `pubspec.yaml`

```
dependencies:
  optimizely_dart: ^0.1.0
```

Then run `flutter pub get` in your project directory

Note:
The plugin is open source with contribution form HOMEX

Thanks:
This plugin is derived from optimizely_plugin repo
