package com.homexlabs.optimizely_dart

import android.app.Activity
import androidx.annotation.NonNull
import com.optimizely.ab.OptimizelyUserContext
import com.optimizely.ab.android.sdk.OptimizelyClient
import com.optimizely.ab.android.sdk.OptimizelyManager
import com.optimizely.ab.config.Variation
import com.optimizely.ab.optimizelydecision.OptimizelyDecideOption
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import java.util.concurrent.TimeUnit


/** OptimizelyPlugin */
class OptimizelyPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var activity: Activity

  private lateinit var optimizelyClient: OptimizelyClient
  private lateinit var user: OptimizelyUserContext

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "optimizely_plugin")
    channel.setMethodCallHandler(this)
  }

  // This static function is optional and equivalent to onAttachedToEngine. It supports the old
  // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
  // plugin registration via this function while apps migrate to use the new Android APIs
  // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
  //
  // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
  // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
  // depending on the user's project. onAttachedToEngine or registerWith must both be defined
  // in the same class.
  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val channel = MethodChannel(registrar.messenger(), "optimizely_plugin")
      channel.setMethodCallHandler(OptimizelyPlugin())
    }
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "initOptimizelyManager" -> {
        val sdkKey = call.argument<String>("sdk_key")
        val dataFile = call.argument<String>("datafile")
        initOptimizelyManager(sdkKey!!, dataFile!!)
        result.success("")
      }
      "initOptimizelyManagerAsync" -> {
        val sdkKey = call.argument<String>("sdk_key")
        initOptimizelyManagerAsync(sdkKey!!)
        result.success("")
      }
      "setUser" -> {
        val userId = call.argument<String>("user_id")
        val attributes = call.argument<MutableMap<String, Any>>("attributes")
        setUser(userId!!, attributes!!)
      }
      "isFeatureEnabled" -> {
        val featureKey = call.argument<String>("feature_key")
        val flag = isFeatureEnabled(featureKey!!)
        result.success(flag)
      }
      "getAllFeatureVariables" -> {
        val featureKey = call.argument<String>("feature_key")
        val variables = getAllFeatureVariables(featureKey!!)
        result.success(variables)
      }
      "getAllEnabledFeatures" -> {
        val features = getAllEnabledFeatures()
        result.success(features)
      }
      "activateGetVariation" -> {
        val featureKey = call.argument<String>("feature_key")
        val variation = activateGetVariation(featureKey!!)
        result.success(variation)
      }
      "getVariation"-> {
        val featureKey = call.argument<String>("feature_key")
        val userId = call.argument<String>("user_id")
        val attributes = call.argument<MutableMap<String, Any>>("attributes")
        val variation = getVariation(featureKey!!, userId!!, attributes!!)
        result.success(variation?.key)
      }
      "trackEvent" -> {
        val featureKey = call.argument<String>("feature_key")
        val eventTags = call.argument<MutableMap<String, Any>>("event_tags")
        trackEvent(featureKey!!, eventTags!!)
        result.success("")
      }
      else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onDetachedFromActivity() {
    TODO("Not yet implemented")
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    TODO("Not yet implemented")
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {
    TODO("Not yet implemented")
  }

  private fun initOptimizelyManager(sdkKey: String, dataFile: String) {
    val optimizelyManager = OptimizelyManager.builder()
            .withSDKKey(sdkKey)
            .withDatafileDownloadInterval(15, TimeUnit.MINUTES)
            .withEventDispatchInterval(30, TimeUnit.SECONDS)
            .build(activity.applicationContext)

    optimizelyClient = optimizelyManager.initialize(activity.applicationContext, dataFile, true, true)
  }

  private fun initOptimizelyManagerAsync(sdkKey: String) {
    val optimizelyManager = OptimizelyManager.builder()
            .withSDKKey(sdkKey)
            .withDatafileDownloadInterval(15, TimeUnit.MINUTES)
            .withEventDispatchInterval(30, TimeUnit.SECONDS)
            .build(activity.applicationContext)

    optimizelyManager.initialize(activity.applicationContext, null) {
      client -> optimizelyClient = client
    }
  }

  private fun setUser(userId: String, attributes: MutableMap<String, Any>){
    val userTemp = optimizelyClient.createUserContext(userId, attributes)
    if(userTemp != null){
      user = userTemp
    }
  }

  private fun isFeatureEnabled(featureKey: String): Boolean{
    val decision = user.decide(featureKey)
    return decision.enabled
  }

  private fun getAllFeatureVariables(featureKey: String): Map<String, Any>? {
    val decision = user.decide(featureKey)
    return decision.variables.toMap()
  }

  private fun getAllEnabledFeatures(): MutableSet<String> {
    val options: List<OptimizelyDecideOption> = listOf(OptimizelyDecideOption.ENABLED_FLAGS_ONLY)
    val decisions = user.decideAll(options)
    return decisions.keys
  }

  private fun getVariation(featureKey: String, userId: String, attributes: MutableMap<String, Any>): Variation? {
    return optimizelyClient.getVariation(featureKey, userId, attributes)
  }

  private fun activateGetVariation(featureKey: String): String? {
    val decision = user.decide(featureKey)
    return decision.variationKey
  }

  private fun trackEvent(eventKey: String, eventTags: MutableMap<String, Any>) {
    user.trackEvent(eventKey, eventTags)
  }
}
