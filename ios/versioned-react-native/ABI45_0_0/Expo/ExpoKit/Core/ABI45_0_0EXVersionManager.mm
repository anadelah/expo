// Copyright 2015-present 650 Industries. All rights reserved.

#import "ABI45_0_0EXAppState.h"
#import "ABI45_0_0EXDevSettings.h"
#import "ABI45_0_0EXDisabledDevLoadingView.h"
#import "ABI45_0_0EXDisabledDevMenu.h"
#import "ABI45_0_0EXDisabledRedBox.h"
#import "ABI45_0_0EXVersionManager.h"
#import "ABI45_0_0EXScopedBridgeModule.h"
#import "ABI45_0_0EXStatusBarManager.h"
#import "ABI45_0_0EXUnversioned.h"
#import "ABI45_0_0EXScopedFileSystemModule.h"
#import "ABI45_0_0EXTest.h"

#import <ABI45_0_0React/ABI45_0_0RCTAssert.h>
#import <ABI45_0_0React/ABI45_0_0RCTBridge.h>
#import <ABI45_0_0React/ABI45_0_0RCTBridge+Private.h>
#import <ABI45_0_0React/ABI45_0_0RCTDevMenu.h>
#import <ABI45_0_0React/ABI45_0_0RCTDevSettings.h>
#import <ABI45_0_0React/ABI45_0_0RCTExceptionsManager.h>
#import <ABI45_0_0React/ABI45_0_0RCTLog.h>
#import <ABI45_0_0React/ABI45_0_0RCTRedBox.h>
#import <ABI45_0_0React/ABI45_0_0RCTPackagerConnection.h>
#import <ABI45_0_0React/ABI45_0_0RCTModuleData.h>
#import <ABI45_0_0React/ABI45_0_0RCTUtils.h>
#import <ABI45_0_0React/ABI45_0_0RCTDataRequestHandler.h>
#import <ABI45_0_0React/ABI45_0_0RCTFileRequestHandler.h>
#import <ABI45_0_0React/ABI45_0_0RCTHTTPRequestHandler.h>
#import <ABI45_0_0React/ABI45_0_0RCTNetworking.h>
#import <ABI45_0_0React/ABI45_0_0RCTLocalAssetImageLoader.h>
#import <ABI45_0_0React/ABI45_0_0RCTGIFImageDecoder.h>
#import <ABI45_0_0React/ABI45_0_0RCTImageLoader.h>
#import <ABI45_0_0React/ABI45_0_0RCTAsyncLocalStorage.h>
#import <ABI45_0_0React/ABI45_0_0RCTJSIExecutorRuntimeInstaller.h>

#import <objc/message.h>

#import <ABI45_0_0ExpoModulesCore/ABI45_0_0EXDefines.h>
#import <ABI45_0_0ExpoModulesCore/ABI45_0_0EXModuleRegistry.h>
#import <ABI45_0_0ExpoModulesCore/ABI45_0_0EXModuleRegistryDelegate.h>
#import <ABI45_0_0ExpoModulesCore/ABI45_0_0EXNativeModulesProxy.h>
#import <ABI45_0_0EXMediaLibrary/ABI45_0_0EXMediaLibraryImageLoader.h>
#import <ABI45_0_0EXFileSystem/ABI45_0_0EXFileSystem.h>
#import "ABI45_0_0EXScopedModuleRegistry.h"
#import "ABI45_0_0EXScopedModuleRegistryAdapter.h"
#import "ABI45_0_0EXScopedModuleRegistryDelegate.h"

#import <ABI45_0_0RNReanimated/ABI45_0_0REAModule.h>
#import <ABI45_0_0RNReanimated/ABI45_0_0REAEventDispatcher.h>
#import <ABI45_0_0RNReanimated/ABI45_0_0REAUIManager.h>
#import <ABI45_0_0RNReanimated/NativeProxy.h>

#import <ABI45_0_0React/ABI45_0_0RCTCxxBridgeDelegate.h>
#import <ABI45_0_0React/ABI45_0_0CoreModulesPlugins.h>
#import <ABI45_0_0ReactCommon/ABI45_0_0RCTTurboModuleManager.h>
#import <ABI45_0_0React/ABI45_0_0JSCExecutorFactory.h>
#import <strings.h>

// Import 3rd party modules that need to be scoped.
#import "ABI45_0_0RNCWebViewManager.h"

ABI45_0_0RCT_EXTERN NSDictionary<NSString *, NSDictionary *> *ABI45_0_0EXGetScopedModuleClasses(void);
ABI45_0_0RCT_EXTERN void ABI45_0_0EXRegisterScopedModule(Class, ...);

@interface ABI45_0_0RCTEventDispatcher (ABI45_0_0REAnimated)

- (void)setBridge:(ABI45_0_0RCTBridge*)bridge;

@end

// this is needed because ABI45_0_0RCTPerfMonitor does not declare a public interface
// anywhere that we can import.
@interface ABI45_0_0RCTPerfMonitorDevSettingsHack <NSObject>

- (void)hide;
- (void)show;

@end

@interface ABI45_0_0RCTBridgeHack <NSObject>

- (void)reload;

@end

@interface ABI45_0_0EXVersionManager () <ABI45_0_0RCTTurboModuleManagerDelegate>

// is this the first time this ABI has been touched at runtime?
@property (nonatomic, assign) BOOL isFirstLoad;
@property (nonatomic, strong) NSDictionary *params;
@property (nonatomic, strong) ABI45_0_0EXManifestsManifest *manifest;
@property (nonatomic, strong) ABI45_0_0RCTTurboModuleManager *turboModuleManager;

@end

@implementation ABI45_0_0EXVersionManager

/**
 *  Expected params:
 *    NSDictionary *constants
 *    NSURL *initialUri
 *    @BOOL isDeveloper
 *    @BOOL isStandardDevMenuAllowed
 *    @ABI45_0_0EXTestEnvironment testEnvironment
 *    NSDictionary *services
 *
 * Kernel-only:
 *    ABI45_0_0EXKernel *kernel
 *    NSArray *supportedSdkVersions
 *    id exceptionsManagerDelegate
 */
- (instancetype)initWithParams:(NSDictionary *)params
                      manifest:(ABI45_0_0EXManifestsManifest *)manifest
                  fatalHandler:(void (^)(NSError *))fatalHandler
                   logFunction:(ABI45_0_0RCTLogFunction)logFunction
                  logThreshold:(NSInteger)threshold
{
  if (self = [super init]) {
    _params = params;
    _manifest = manifest;
    [self configureABIWithFatalHandler:fatalHandler logFunction:logFunction logThreshold:threshold];
  }
  return self;
}

+ (void)load
{
  // Register scoped 3rd party modules. Some of them are separate pods that
  // don't have access to ABI45_0_0EXScopedModuleRegistry and so they can't register themselves.
  ABI45_0_0EXRegisterScopedModule([ABI45_0_0RNCWebViewManager class], ABI45_0_0EX_KERNEL_SERVICE_NONE, nil);
}

- (void)bridgeWillStartLoading:(id)bridge
{
  // We need to check DEBUG flag here because in ejected projects ABI45_0_0RCT_DEV is set only for ABI45_0_0React and not for ExpoKit to which this file belongs to.
  // It can be changed to just ABI45_0_0RCT_DEV once we deprecate ExpoKit and set that flag for the entire standalone project.
#if DEBUG || ABI45_0_0RCT_DEV
  if ([self _isDevModeEnabledForBridge:bridge]) {
    // Set the bundle url for the packager connection manually
    NSURL *bundleURL = [bridge bundleURL];
    NSString *packagerServerHostPort = [NSString stringWithFormat:@"%@:%@", bundleURL.host, bundleURL.port];
    [[ABI45_0_0RCTPackagerConnection sharedPackagerConnection] reconnect:packagerServerHostPort];
  }
#endif

  // Manually send a "start loading" notif, since the real one happened uselessly inside the ABI45_0_0RCTBatchedBridge constructor
  [[NSNotificationCenter defaultCenter]
   postNotificationName:ABI45_0_0RCTJavaScriptWillStartLoadingNotification object:bridge];
}

- (void)bridgeFinishedLoading:(id)bridge
{
  // Override the "Reload" button from Redbox to reload the app from manifest
  // Keep in mind that it is possible this will return a ABI45_0_0EXDisabledRedBox
  ABI45_0_0RCTRedBox *redBox = [self _moduleInstanceForBridge:bridge named:@"RedBox"];
  [redBox setOverrideReloadAction:^{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"EXReloadActiveAppRequest" object:nil];
  }];
}

- (void)invalidate {}

- (NSDictionary<NSString *, NSString *> *)devMenuItemsForBridge:(id)bridge
{
  ABI45_0_0RCTDevSettings *devSettings = (ABI45_0_0RCTDevSettings *)[self _moduleInstanceForBridge:bridge named:@"DevSettings"];
  BOOL isDevModeEnabled = [self _isDevModeEnabledForBridge:bridge];
  NSMutableDictionary *items = [NSMutableDictionary new];

  if (isDevModeEnabled) {
    items[@"dev-inspector"] = @{
      @"label": devSettings.isElementInspectorShown ? @"Hide Element Inspector" : @"Show Element Inspector",
      @"isEnabled": @YES
    };
  } else {
    items[@"dev-inspector"] = @{
      @"label": @"Element Inspector Unavailable",
      @"isEnabled": @NO
    };
  }

  if (devSettings.isRemoteDebuggingAvailable && isDevModeEnabled) {
    items[@"dev-remote-debug"] = @{
      @"label": (devSettings.isDebuggingRemotely) ? @"Stop Remote Debugging" : @"Debug Remote JS",
      @"isEnabled": @YES
    };
  } else {
    items[@"dev-remote-debug"] =  @{
      @"label": @"Remote Debugger Unavailable",
      @"isEnabled": @NO,
      @"detail": ABI45_0_0RCTTurboModuleEnabled() ? @"Remote debugging is unavailable while Turbo Modules are enabled. To debug remotely, please set `turboModules` to false in app.json." : [NSNull null]
    };
  }

  if (devSettings.isHotLoadingAvailable && isDevModeEnabled) {
    items[@"dev-hmr"] = @{
      @"label": (devSettings.isHotLoadingEnabled) ? @"Disable Fast Refresh" : @"Enable Fast Refresh",
      @"isEnabled": @YES,
    };
  } else {
    items[@"dev-hmr"] =  @{
      @"label": @"Fast Refresh Unavailable",
      @"isEnabled": @NO,
      @"detail": @"Use the Reload button above to reload when in production mode. Switch back to development mode to use Fast Refresh."
    };
  }

  id perfMonitor = [self _moduleInstanceForBridge:bridge named:@"PerfMonitor"];
  if (perfMonitor && isDevModeEnabled) {
    items[@"dev-perf-monitor"] = @{
      @"label": devSettings.isPerfMonitorShown ? @"Hide Performance Monitor" : @"Show Performance Monitor",
      @"isEnabled": @YES,
    };
  } else {
    items[@"dev-perf-monitor"] = @{
      @"label": @"Performance Monitor Unavailable",
      @"isEnabled": @NO,
    };
  }

  return items;
}

- (void)selectDevMenuItemWithKey:(NSString *)key onBridge:(id)bridge
{
  ABI45_0_0RCTAssertMainQueue();
  ABI45_0_0RCTDevSettings *devSettings = (ABI45_0_0RCTDevSettings *)[self _moduleInstanceForBridge:bridge named:@"DevSettings"];
  if ([key isEqualToString:@"dev-reload"]) {
    // bridge could be an ABI45_0_0RCTBridge of any version and we need to cast it since ARC needs to know
    // the return type
    [(ABI45_0_0RCTBridgeHack *)bridge reload];
  } else if ([key isEqualToString:@"dev-remote-debug"]) {
    devSettings.isDebuggingRemotely = !devSettings.isDebuggingRemotely;
  } else if ([key isEqualToString:@"dev-profiler"]) {
    devSettings.isProfilingEnabled = !devSettings.isProfilingEnabled;
  } else if ([key isEqualToString:@"dev-hmr"]) {
    devSettings.isHotLoadingEnabled = !devSettings.isHotLoadingEnabled;
  } else if ([key isEqualToString:@"dev-inspector"]) {
    [devSettings toggleElementInspector];
  } else if ([key isEqualToString:@"dev-perf-monitor"]) {
    id perfMonitor = [self _moduleInstanceForBridge:bridge named:@"PerfMonitor"];
    if (perfMonitor) {
      if (devSettings.isPerfMonitorShown) {
        [perfMonitor hide];
        devSettings.isPerfMonitorShown = NO;
      } else {
        [perfMonitor show];
        devSettings.isPerfMonitorShown = YES;
      }
    }
  }
}

- (void)showDevMenuForBridge:(id)bridge
{
  ABI45_0_0RCTAssertMainQueue();
  id devMenu = [self _moduleInstanceForBridge:bridge named:@"DevMenu"];
  // respondsToSelector: check is required because it's possible this bridge
  // was instantiated with a `disabledDevMenu` instance and the gesture preference was recently updated.
  if ([devMenu respondsToSelector:@selector(show)]) {
    [((ABI45_0_0RCTDevMenu *)devMenu) show];
  }
}

- (void)disableRemoteDebuggingForBridge:(id)bridge
{
  ABI45_0_0RCTDevSettings *devSettings = (ABI45_0_0RCTDevSettings *)[self _moduleInstanceForBridge:bridge named:@"DevSettings"];
  devSettings.isDebuggingRemotely = NO;
}

- (void)toggleRemoteDebuggingForBridge:(id)bridge
{
  ABI45_0_0RCTDevSettings *devSettings = (ABI45_0_0RCTDevSettings *)[self _moduleInstanceForBridge:bridge named:@"DevSettings"];
  devSettings.isDebuggingRemotely = !devSettings.isDebuggingRemotely;
}

- (void)togglePerformanceMonitorForBridge:(id)bridge
{
  ABI45_0_0RCTDevSettings *devSettings = (ABI45_0_0RCTDevSettings *)[self _moduleInstanceForBridge:bridge named:@"DevSettings"];
  id perfMonitor = [self _moduleInstanceForBridge:bridge named:@"PerfMonitor"];
  if (perfMonitor) {
    if (devSettings.isPerfMonitorShown) {
      [perfMonitor hide];
      devSettings.isPerfMonitorShown = NO;
    } else {
      [perfMonitor show];
      devSettings.isPerfMonitorShown = YES;
    }
  }
}

- (void)toggleElementInspectorForBridge:(id)bridge
{
  ABI45_0_0RCTDevSettings *devSettings = (ABI45_0_0RCTDevSettings *)[self _moduleInstanceForBridge:bridge named:@"DevSettings"];
  [devSettings toggleElementInspector];
}

#if DEBUG || ABI45_0_0RCT_DEV
- (uint32_t)addWebSocketNotificationHandler:(void (^)(NSDictionary<NSString *, id> *))handler
                                    queue:(dispatch_queue_t)queue
                                forMethod:(NSString *)method
{
  return [[ABI45_0_0RCTPackagerConnection sharedPackagerConnection] addNotificationHandler:handler queue:queue forMethod:method];
}
#endif

#pragma mark - internal

- (BOOL)_isDevModeEnabledForBridge:(id)bridge
{
  return ([ABI45_0_0RCTGetURLQueryParam([bridge bundleURL], @"dev") boolValue]);
}

- (id<ABI45_0_0RCTBridgeModule>)_moduleInstanceForBridge:(id)bridge named:(NSString *)name
{
  return [bridge moduleForClass:[self getModuleClassFromName:[name UTF8String]]];
}

- (void)configureABIWithFatalHandler:(void (^)(NSError *))fatalHandler
                         logFunction:(ABI45_0_0RCTLogFunction)logFunction
                        logThreshold:(NSInteger)threshold
{
  ABI45_0_0RCTEnableTurboModule([self.manifest.experiments[@"turboModules"] boolValue]);
  ABI45_0_0RCTSetFatalHandler(fatalHandler);
  ABI45_0_0RCTSetLogThreshold((ABI45_0_0RCTLogLevel) threshold);
  ABI45_0_0RCTSetLogFunction(logFunction);
}

- (NSArray *)extraModulesForBridge:(id)bridge
{
  NSDictionary *params = _params;
  NSDictionary *services = params[@"services"];

  NSMutableArray *extraModules = [NSMutableArray arrayWithArray:
                                  @[
                                    [[ABI45_0_0EXAppState alloc] init],
                                    [[ABI45_0_0EXDisabledDevLoadingView alloc] init],
                                    [[ABI45_0_0EXStatusBarManager alloc] init],
                                    ]];

  // add scoped modules
  [extraModules addObjectsFromArray:[self _newScopedModulesForServices:services params:params]];

  if (params[@"testEnvironment"]) {
    ABI45_0_0EXTestEnvironment testEnvironment = (ABI45_0_0EXTestEnvironment)[params[@"testEnvironment"] unsignedIntegerValue];
    if (testEnvironment != ABI45_0_0EXTestEnvironmentNone) {
      ABI45_0_0EXTest *testModule = [[ABI45_0_0EXTest alloc] initWithEnvironment:testEnvironment];
      [extraModules addObject:testModule];
    }
  }

  if (params[@"browserModuleClass"]) {
    Class browserModuleClass = params[@"browserModuleClass"];
    id homeModule = [[browserModuleClass alloc] initWithExperienceStableLegacyId:self.manifest.stableLegacyId
                                                                        scopeKey:self.manifest.scopeKey
                                                                    easProjectId:self.manifest.easProjectId
                                                           kernelServiceDelegate:services[@"EXHomeModuleManager"]
                                                                          params:params];
    [extraModules addObject:homeModule];
  }

  ABI45_0_0EXModuleRegistryProvider *moduleRegistryProvider = [[ABI45_0_0EXModuleRegistryProvider alloc] initWithSingletonModules:params[@"singletonModules"]];

  Class resolverClass = [ABI45_0_0EXScopedModuleRegistryDelegate class];
  if (params[@"moduleRegistryDelegateClass"] && params[@"moduleRegistryDelegateClass"] != [NSNull null]) {
    resolverClass = params[@"moduleRegistryDelegateClass"];
  }

  id<ABI45_0_0EXModuleRegistryDelegate> moduleRegistryDelegate = [[resolverClass alloc] initWithParams:params];
  [moduleRegistryProvider setModuleRegistryDelegate:moduleRegistryDelegate];

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
  ABI45_0_0EXScopedModuleRegistryAdapter *moduleRegistryAdapter = [[ABI45_0_0EXScopedModuleRegistryAdapter alloc] initWithModuleRegistryProvider:moduleRegistryProvider];
#pragma clang diagnostic pop

  ABI45_0_0EXModuleRegistry *moduleRegistry = [moduleRegistryAdapter moduleRegistryForParams:params
                                                        forExperienceStableLegacyId:self.manifest.stableLegacyId
                                                                           scopeKey:self.manifest.scopeKey
                                                                           manifest:self.manifest
                                                                 withKernelServices:services];
  NSArray<id<ABI45_0_0RCTBridgeModule>> *expoModules = [moduleRegistryAdapter extraModulesForModuleRegistry:moduleRegistry];
  [extraModules addObjectsFromArray:expoModules];

  if (!ABI45_0_0RCTTurboModuleEnabled()) {
    [extraModules addObject:[self getModuleInstanceFromClass:[self getModuleClassFromName:"DevSettings"]]];
    id exceptionsManager = [self getModuleInstanceFromClass:ABI45_0_0RCTExceptionsManagerCls()];
    if (exceptionsManager) {
      [extraModules addObject:exceptionsManager];
    }
    [extraModules addObject:[self getModuleInstanceFromClass:[self getModuleClassFromName:"DevMenu"]]];
    [extraModules addObject:[self getModuleInstanceFromClass:[self getModuleClassFromName:"RedBox"]]];
    [extraModules addObject:[self getModuleInstanceFromClass:ABI45_0_0RCTAsyncLocalStorageCls()]];
  }

  return extraModules;
}

- (NSArray *)_newScopedModulesForServices:(NSDictionary *)services params:(NSDictionary *)params
{
  NSMutableArray *result = [NSMutableArray array];
  NSDictionary<NSString *, NSDictionary *> *ABI45_0_0EXScopedModuleClasses = ABI45_0_0EXGetScopedModuleClasses();
  if (ABI45_0_0EXScopedModuleClasses) {
    [ABI45_0_0EXScopedModuleClasses enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull scopedModuleClassName, NSDictionary * _Nonnull kernelServiceClassNames, BOOL * _Nonnull stop) {
      NSMutableDictionary *moduleServices = [[NSMutableDictionary alloc] init];
      for (id kernelServiceClassName in kernelServiceClassNames) {
        NSString *kernelSerivceName = kernelServiceClassNames[kernelServiceClassName];
        id service = ([kernelSerivceName isEqualToString:ABI45_0_0EX_KERNEL_SERVICE_NONE]) ? [NSNull null] : services[kernelSerivceName];
        moduleServices[kernelServiceClassName] = service;
      }

      id scopedModule;
      Class scopedModuleClass = NSClassFromString(scopedModuleClassName);
      if (moduleServices.count > 1) {
        scopedModule = [[scopedModuleClass alloc] initWithExperienceStableLegacyId:self.manifest.stableLegacyId
                                                                          scopeKey:self.manifest.scopeKey
                                                                      easProjectId:self.manifest.easProjectId
                                                            kernelServiceDelegates:moduleServices
                                                                            params:params];
      } else if (moduleServices.count == 0) {
        scopedModule = [[scopedModuleClass alloc] initWithExperienceStableLegacyId:self.manifest.stableLegacyId
                                                                          scopeKey:self.manifest.scopeKey
                                                                      easProjectId:self.manifest.easProjectId
                                                             kernelServiceDelegate:nil
                                                                            params:params];
      } else {
        scopedModule = [[scopedModuleClass alloc] initWithExperienceStableLegacyId:self.manifest.stableLegacyId
                                                                          scopeKey:self.manifest.scopeKey
                                                                      easProjectId:self.manifest.easProjectId
                                                             kernelServiceDelegate:moduleServices[[moduleServices allKeys][0]]
                                                                            params:params];
      }

      if (scopedModule) {
        [result addObject:scopedModule];
      }
    }];
  }
  return result;
}

- (Class)getModuleClassFromName:(const char *)name
{
  if (std::string(name) == "DevSettings") {
    return ABI45_0_0EXDevSettings.class;
  }
  if (std::string(name) == "DevMenu") {
    if (![_params[@"isStandardDevMenuAllowed"] boolValue] || ![_params[@"isDeveloper"] boolValue]) {
      // non-kernel, or non-development kernel, uses expo menu instead of ABI45_0_0RCTDevMenu
      return ABI45_0_0EXDisabledDevMenu.class;
    }
  }
  if (std::string(name) == "RedBox") {
    if (![_params[@"isDeveloper"] boolValue]) {
      // user-facing (not debugging).
      // additionally disable ABI45_0_0RCTRedBox
      return ABI45_0_0EXDisabledRedBox.class;
    }
  }
  return ABI45_0_0RCTCoreModulesClassProvider(name);
}

/**
 Returns a pure C++ object wrapping an exported unimodule instance.
 */
- (std::shared_ptr<ABI45_0_0facebook::ABI45_0_0React::TurboModule>)getTurboModule:(const std::string &)name
                                                      jsInvoker:(std::shared_ptr<ABI45_0_0facebook::ABI45_0_0React::CallInvoker>)jsInvoker
{
  return nullptr;
}

- (id<ABI45_0_0RCTTurboModule>)getModuleInstanceFromClass:(Class)moduleClass
{
  // Standard
  if (moduleClass == ABI45_0_0RCTImageLoader.class) {
    return [[moduleClass alloc] initWithRedirectDelegate:nil loadersProvider:^NSArray<id<ABI45_0_0RCTImageURLLoader>> *(ABI45_0_0RCTModuleRegistry *) {
      return @[[ABI45_0_0RCTLocalAssetImageLoader new], [ABI45_0_0EXMediaLibraryImageLoader new]];
    } decodersProvider:^NSArray<id<ABI45_0_0RCTImageDataDecoder>> *(ABI45_0_0RCTModuleRegistry *) {
      return @[[ABI45_0_0RCTGIFImageDecoder new]];
    }];
  } else if (moduleClass == ABI45_0_0RCTNetworking.class) {
    return [[moduleClass alloc] initWithHandlersProvider:^NSArray<id<ABI45_0_0RCTURLRequestHandler>> *(ABI45_0_0RCTModuleRegistry *) {
      return @[
        [ABI45_0_0RCTHTTPRequestHandler new],
        [ABI45_0_0RCTDataRequestHandler new],
        [ABI45_0_0RCTFileRequestHandler new],
      ];
    }];
  }

  // Expo-specific
  if (moduleClass == ABI45_0_0EXDevSettings.class) {
    BOOL isDevelopment = ![self _isOpeningHomeInProductionMode] && [_params[@"isDeveloper"] boolValue];
    return [[moduleClass alloc] initWithScopeKey:self.manifest.scopeKey isDevelopment:isDevelopment];
  } else if (moduleClass == ABI45_0_0RCTExceptionsManagerCls()) {
    id exceptionsManagerDelegate = _params[@"exceptionsManagerDelegate"];
    if (exceptionsManagerDelegate) {
      return [[moduleClass alloc] initWithDelegate:exceptionsManagerDelegate];
    } else {
      ABI45_0_0RCTLogWarn(@"No exceptions manager provided when building extra modules for bridge.");
    }
  } else if (moduleClass == ABI45_0_0RCTAsyncLocalStorageCls()) {
    NSString *documentDirectory;
    if (_params[@"fileSystemDirectories"]) {
      documentDirectory = _params[@"fileSystemDirectories"][@"documentDirectory"];
    } else {
      NSArray<NSString *> *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
      documentDirectory = [documentPaths objectAtIndex:0];
    }
    NSString *localStorageDirectory = [documentDirectory stringByAppendingPathComponent:@"RCTAsyncLocalStorage"];
    return [[moduleClass alloc] initWithStorageDirectory:localStorageDirectory];
  }

  return [moduleClass new];
}

- (std::shared_ptr<ABI45_0_0facebook::ABI45_0_0React::TurboModule>)getTurboModule:(const std::string &)name
                                                     initParams:(const ABI45_0_0facebook::ABI45_0_0React::ObjCTurboModule::InitParams &)params
{
  // TODO: ADD
  return nullptr;
}

- (BOOL)_isOpeningHomeInProductionMode
{
  return _params[@"browserModuleClass"] && !self.manifest.developer;
}

- (void *)versionedJsExecutorFactoryForBridge:(ABI45_0_0RCTBridge *)bridge
{
  [bridge moduleForClass:[ABI45_0_0RCTUIManager class]];
  ABI45_0_0REAUIManager *reaUiManager = [ABI45_0_0REAUIManager new];
  [reaUiManager setBridge:bridge];
  ABI45_0_0RCTUIManager *uiManager = reaUiManager;
  [bridge updateModuleWithInstance:uiManager];

  [bridge moduleForClass:[ABI45_0_0RCTEventDispatcher class]];
  ABI45_0_0RCTEventDispatcher *eventDispatcher = [ABI45_0_0REAEventDispatcher new];
  ABI45_0_0RCTCallableJSModules *callableJSModules = [ABI45_0_0RCTCallableJSModules new];
  [bridge setValue:callableJSModules forKey:@"_callableJSModules"];
  [callableJSModules setBridge:bridge];
  [eventDispatcher setValue:callableJSModules forKey:@"_callableJSModules"];
  [eventDispatcher setValue:bridge forKey:@"_bridge"];
  [eventDispatcher initialize];
  [bridge updateModuleWithInstance:eventDispatcher];

  ABI45_0_0EX_WEAKIFY(self);
  const auto executor = [ABI45_0_0EXWeak_self, bridge](ABI45_0_0facebook::jsi::Runtime &runtime) {
    if (!bridge) {
      return;
    }
    ABI45_0_0EX_ENSURE_STRONGIFY(self);
    auto reanimatedModule = ABI45_0_0reanimated::createReanimatedModule(bridge, bridge.jsCallInvoker);
    auto workletRuntimeValue = runtime
        .global()
        .getProperty(runtime, "ArrayBuffer")
        .asObject(runtime)
        .asFunction(runtime)
        .callAsConstructor(runtime, {static_cast<double>(sizeof(void*))});
    uintptr_t* workletRuntimeData = reinterpret_cast<uintptr_t*>(
        workletRuntimeValue.getObject(runtime).getArrayBuffer(runtime).data(runtime));
    workletRuntimeData[0] = reinterpret_cast<uintptr_t>(reanimatedModule->runtime.get());
    runtime.global().setProperty(
        runtime,
        "_WORKLET_RUNTIME",
        workletRuntimeValue);

    runtime.global().setProperty(
         runtime,
         jsi::PropNameID::forAscii(runtime, "__reanimatedModuleProxy"),
         jsi::Object::createFromHostObject(runtime, reanimatedModule));
  };
  return new ABI45_0_0facebook::ABI45_0_0React::JSCExecutorFactory(ABI45_0_0RCTJSIExecutorRuntimeInstaller(executor));
}

@end
