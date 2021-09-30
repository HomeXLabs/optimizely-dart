import Flutter
import Optimizely

enum InitResult {
  case success
  case failure(Error)
}

public class OptimizelyPlugin: NSObject, FlutterPlugin {
    
    typealias GetFeatureItems = (featureKey: String, userId: String, attributes: OptimizelyAttributes?, eventTags: OptimizelyEventTags?)
    var client: OptimizelyClient?
    var user: OptimizelyUserContext?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "optimizely_plugin",
            binaryMessenger: registrar.messenger()
        )
        let instance = OptimizelyPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any] else {
            result(FlutterError(
                code: "arguments",
                message: "Missing or invalid arguments",
                details: nil
            ))
            return
        }
        
        switch call.method {
        case "initOptimizelyManager":
            do {
                let sdkKey: String = try arguments.argument(for: "sdk_key")
                let dataFile: String? = try arguments.optionalArgument(for: "datafile")
                let client = OptimizelyClient(
                    sdkKey: sdkKey,
                    periodicDownloadInterval: 60
                )
              
                try client.start(datafile: dataFile!)
                self.client = client
              
                result(nil)
            } catch {
              result(error.localizedDescription)
            }
        case "initOptimizelyManagerAsync":
          do {
            let sdkKey: String = try arguments.argument(for: "sdk_key")
            let client = OptimizelyClient(
              sdkKey: sdkKey,
              periodicDownloadInterval: 60
            )
            
            client.start { initResult in
              switch initResult {
                case .failure(let error):
                  result(error.localizedDescription)
                case .success:
                  result(nil)
              }
            }
            
            self.client = client
          } catch {
            result(error.localizedDescription)
          }
        case "isFeatureEnabled":
            do {
                let user = try ensureUser()
                let featureKey: String = try arguments.argument(for: "feature_key")
                let decision = user.decide(key: featureKey)
                let enabled = decision.enabled
                result(enabled)
            } catch {
              result(error.localizedDescription)
            }
        case "setUser":
            do {
                let client = try ensureClient()
                let userId: String = try arguments.argument(for: "user_id")
                let attributes: OptimizelyAttributes? = try arguments.optionalArgument(for: "attributes")
                if(attributes != nil && !attributes!.isEmpty){
                    self.user = client.createUserContext(userId: userId, attributes: attributes! as [String : Any])
                }
                else{
                    self.user = client.createUserContext(userId: userId)
                }
            } catch {
              result(error.localizedDescription)
            }
        case "getAllFeatureVariables":
            do {
                let user = try ensureUser()
                let featureKey: String = try arguments.argument(for: "feature_key")
                let decision = user.decide(key: featureKey)
                let json: OptimizelyJSON = decision.variables
                result(json.toMap())
            } catch {
              result(error.localizedDescription)
            }
        case "getVariation":
            do {
                let client = try ensureClient()
                let userId: String = try arguments.argument(for: "user_id")
                let attributes: OptimizelyAttributes? = try arguments.optionalArgument(for: "attributes")
                let featureKey: String = try arguments.argument(for: "feature_key")
                let res: String = try client.getVariationKey(
                    experimentKey: featureKey,
                    userId: userId,
                    attributes: attributes
                )
                result(res)
            } catch {
              result(error.localizedDescription)
            }
        case "activateGetVariation":
            do {
                let user = try ensureUser()
                let featureKey: String = try arguments.argument(for: "feature_key")
                let decision = user.decide(key: featureKey)
                result(decision.variationKey)
            } catch {
              result(error.localizedDescription)
            }
        case "getAllEnabledFeatures":
            do {
                let user = try ensureUser()
                let decisions = user.decideAll(options: [.enabledFlagsOnly])
                let enabledFlags = decisions.keys
                result(enabledFlags)
            } catch {
              result(error.localizedDescription)
            }
        case "trackEvent":
            do {
                let user = try ensureUser()
                let eventKey: String = try arguments.argument(for: "event_key")
                let eventTags: OptimizelyEventTags? = try arguments.argument(for: "event_tags")
                try? user.trackEvent(eventKey: eventKey,
                                     eventTags: eventTags )
            } catch {
              result(error.localizedDescription)
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    func ensureClient() throws -> OptimizelyClient {
        guard let client = self.client else {
            throw FlutterError(
                code: "client",
                message: "Optimizely client not initialized",
                details: nil
            )
        }
        return client
    }
    
    func ensureUser() throws -> OptimizelyUserContext {
        guard let user = self.user else {
            throw FlutterError(
                code: "user",
                message: "Optimizely user not initialized",
                details: nil
            )
        }
        return user
    }

    func startClient(_ client: OptimizelyClient, dataFile: String?) throws {
        if let dataFile = dataFile {
            try client.start(datafile: dataFile)
        } else {
            client.start()
        }
    }
  
  func startClient(_ client: OptimizelyClient, completion: @escaping (InitResult) -> Void) throws {
      client.start { clientResult in
        switch clientResult {
          case .failure(let error):
            completion(.failure(error))
          case .success(_):
            completion(.success)
          }
      }
    }
}

// MARK: - Arguments

fileprivate extension Dictionary where Key == String, Value == Any {
    func argument<T>(for key: String) throws -> T {
        if self[key] == nil {
            throw FlutterError.missingArgument(for: key)
        }
        if let argument = self[key] as? T {
            return argument
        } else {
            throw FlutterError.invalidType(for: key)
        }
    }
    
    func optionalArgument<T>(for key: String) throws -> T? {
        if self[key] == nil {
            return nil
        }
        if let argument = self[key] as? T {
            return argument
        } else {
            throw FlutterError.invalidType(for: key)
        }
    }
}

// MARK: - Flutter Error

extension FlutterError: Error { }

fileprivate extension FlutterError {
    static func missingArgument(for key: String) -> FlutterError {
        return FlutterError(
            code: "argument",
            message: "Missing argument for key: \(key)",
            details: nil
        )
    }
    
    static func invalidType(for key: String) -> FlutterError {
        return FlutterError(
            code: "argument",
            message: "Invalid type for argument with key: \(key)",
            details: nil
        )
    }
}
