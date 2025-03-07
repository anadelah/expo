//  Copyright © 2019 650 Industries. All rights reserved.

#import <ABI45_0_0EXUpdates/ABI45_0_0EXUpdatesConfig.h>
#import <ABI45_0_0EXUpdates/ABI45_0_0EXUpdatesAppController.h>

#if __has_include(<ABI45_0_0EXUpdates/ABI45_0_0EXUpdates-Swift.h>)
#import <ABI45_0_0EXUpdates/ABI45_0_0EXUpdates-Swift.h>
#else
#import "ABI45_0_0EXUpdates-Swift.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface ABI45_0_0EXUpdatesConfig ()

@property (nonatomic, readwrite, assign) BOOL isEnabled;
@property (nonatomic, readwrite, assign) BOOL expectsSignedManifest;
@property (nonatomic, readwrite, strong) NSString *scopeKey;
@property (nonatomic, readwrite, strong) NSURL *updateUrl;
@property (nonatomic, readwrite, strong) NSDictionary *requestHeaders;
@property (nonatomic, readwrite, strong) NSString *releaseChannel;
@property (nonatomic, readwrite, strong) NSNumber *launchWaitMs;
@property (nonatomic, readwrite, assign) ABI45_0_0EXUpdatesCheckAutomaticallyConfig checkOnLaunch;
@property (nonatomic, readwrite, strong, nullable) ABI45_0_0EXUpdatesCodeSigningConfiguration *codeSigningConfiguration;

@property (nullable, nonatomic, readwrite, strong) NSString *sdkVersion;
@property (nullable, nonatomic, readwrite, strong) NSString *runtimeVersion;

@end

NSString * const ABI45_0_0EXUpdatesConfigPlistName = @"Expo";

NSString * const ABI45_0_0EXUpdatesConfigEnableAutoSetupKey = @"ABI45_0_0EXUpdatesAutoSetup";
NSString * const ABI45_0_0EXUpdatesConfigEnabledKey = @"ABI45_0_0EXUpdatesEnabled";
NSString * const ABI45_0_0EXUpdatesConfigScopeKeyKey = @"ABI45_0_0EXUpdatesScopeKey";
NSString * const ABI45_0_0EXUpdatesConfigUpdateUrlKey = @"ABI45_0_0EXUpdatesURL";
NSString * const ABI45_0_0EXUpdatesConfigRequestHeadersKey = @"ABI45_0_0EXUpdatesRequestHeaders";
NSString * const ABI45_0_0EXUpdatesConfigReleaseChannelKey = @"ABI45_0_0EXUpdatesReleaseChannel";
NSString * const ABI45_0_0EXUpdatesConfigLaunchWaitMsKey = @"ABI45_0_0EXUpdatesLaunchWaitMs";
NSString * const ABI45_0_0EXUpdatesConfigCheckOnLaunchKey = @"ABI45_0_0EXUpdatesCheckOnLaunch";
NSString * const ABI45_0_0EXUpdatesConfigSDKVersionKey = @"ABI45_0_0EXUpdatesSDKVersion";
NSString * const ABI45_0_0EXUpdatesConfigRuntimeVersionKey = @"ABI45_0_0EXUpdatesRuntimeVersion";
NSString * const ABI45_0_0EXUpdatesConfigHasEmbeddedUpdateKey = @"ABI45_0_0EXUpdatesHasEmbeddedUpdate";
NSString * const ABI45_0_0EXUpdatesConfigExpectsSignedManifestKey = @"ABI45_0_0EXUpdatesExpectsSignedManifest";
NSString * const ABI45_0_0EXUpdatesConfigCodeSigningCertificateKey = @"ABI45_0_0EXUpdatesCodeSigningCertificate";
NSString * const ABI45_0_0EXUpdatesConfigCodeSigningMetadataKey = @"ABI45_0_0EXUpdatesCodeSigningMetadata";
NSString * const ABI45_0_0EXUpdatesConfigCodeSigningIncludeManifestResponseCertificateChainKey = @"ABI45_0_0EXUpdatesCodeSigningIncludeManifestResponseCertificateChain";
NSString * const ABI45_0_0EXUpdatesConfigCodeSigningAllowUnsignedManifestsKey = @"ABI45_0_0EXUpdatesConfigCodeSigningAllowUnsignedManifests";

NSString * const ABI45_0_0EXUpdatesConfigReleaseChannelDefaultValue = @"default";

NSString * const ABI45_0_0EXUpdatesConfigCheckOnLaunchValueAlways = @"ALWAYS";
NSString * const ABI45_0_0EXUpdatesConfigCheckOnLaunchValueWifiOnly = @"WIFI_ONLY";
NSString * const ABI45_0_0EXUpdatesConfigCheckOnLaunchValueErrorRecoveryOnly = @"ERROR_RECOVERY_ONLY";
NSString * const ABI45_0_0EXUpdatesConfigCheckOnLaunchValueNever = @"NEVER";

@implementation ABI45_0_0EXUpdatesConfig

- (instancetype)init
{
  if (self = [super init]) {
    _isEnabled = YES;
    _expectsSignedManifest = NO;
    _requestHeaders = @{};
    _releaseChannel = ABI45_0_0EXUpdatesConfigReleaseChannelDefaultValue;
    _launchWaitMs = @(0);
    _checkOnLaunch = ABI45_0_0EXUpdatesCheckAutomaticallyConfigAlways;
    _hasEmbeddedUpdate = YES;
  }
  return self;
}

+ (instancetype)configWithDictionary:(NSDictionary *)config
{
  ABI45_0_0EXUpdatesConfig *updatesConfig = [[ABI45_0_0EXUpdatesConfig alloc] init];
  [updatesConfig loadConfigFromDictionary:config];
  return updatesConfig;
}

+ (instancetype)configWithExpoPlist
{
  NSString *configPath = [[NSBundle mainBundle] pathForResource:ABI45_0_0EXUpdatesConfigPlistName ofType:@"plist"];
  if (!configPath) {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"Cannot load configuration from Expo.plist. Please ensure you've followed the setup and installation instructions for expo-updates to create Expo.plist and add it to your Xcode project."
                                 userInfo:@{}];
  }
  return [[self class] configWithDictionary:[NSDictionary dictionaryWithContentsOfFile:configPath]];
}

- (void)loadConfigFromDictionary:(NSDictionary *)config
{
  id isEnabled = config[ABI45_0_0EXUpdatesConfigEnabledKey];
  if (isEnabled && [isEnabled isKindOfClass:[NSNumber class]]) {
    _isEnabled = [(NSNumber *)isEnabled boolValue];
  }
  
  id expectsSignedManifest = config[ABI45_0_0EXUpdatesConfigExpectsSignedManifestKey];
  if (expectsSignedManifest && [expectsSignedManifest isKindOfClass:[NSNumber class]]) {
    _expectsSignedManifest = [(NSNumber *)expectsSignedManifest boolValue];
  }
  
  id updateUrl = config[ABI45_0_0EXUpdatesConfigUpdateUrlKey];
  if (updateUrl && [updateUrl isKindOfClass:[NSString class]]) {
    NSURL *url = [NSURL URLWithString:(NSString *)updateUrl];
    _updateUrl = url;
  }

  id scopeKey = config[ABI45_0_0EXUpdatesConfigScopeKeyKey];
  if (scopeKey && [scopeKey isKindOfClass:[NSString class]]) {
    _scopeKey = (NSString *)scopeKey;
  }

  // set updateUrl as the default value if none is provided
  if (!_scopeKey) {
    if (_updateUrl) {
      _scopeKey = [[self class] normalizedURLOrigin:_updateUrl];
    }
  }

  id requestHeaders = config[ABI45_0_0EXUpdatesConfigRequestHeadersKey];
  if (requestHeaders) {
    if(![requestHeaders isKindOfClass:[NSDictionary class]]){
      @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                     reason:[NSString stringWithFormat:@"Plist key \"%@\" must be a string-valued Dictionary.", ABI45_0_0EXUpdatesConfigRequestHeadersKey]
                                   userInfo:@{}];
    }
    _requestHeaders = (NSDictionary *)requestHeaders;
    
    for (id key in _requestHeaders){
      if (![_requestHeaders[key] isKindOfClass:[NSString class]]){
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:[NSString stringWithFormat:@"Plist key \"%@\" must be a string-valued Dictionary.", ABI45_0_0EXUpdatesConfigRequestHeadersKey]
                                     userInfo:@{}];
      }
    }
  }

  id releaseChannel = config[ABI45_0_0EXUpdatesConfigReleaseChannelKey];
  if (releaseChannel && [releaseChannel isKindOfClass:[NSString class]]) {
    _releaseChannel = (NSString *)releaseChannel;
  }

  id launchWaitMs = config[ABI45_0_0EXUpdatesConfigLaunchWaitMsKey];
  if (launchWaitMs && [launchWaitMs isKindOfClass:[NSNumber class]]) {
    _launchWaitMs = (NSNumber *)launchWaitMs;
  } else if (launchWaitMs && [launchWaitMs isKindOfClass:[NSString class]]) {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterNoStyle;
    _launchWaitMs = [formatter numberFromString:(NSString *)launchWaitMs];
  }

  id checkOnLaunch = config[ABI45_0_0EXUpdatesConfigCheckOnLaunchKey];
  if (checkOnLaunch && [checkOnLaunch isKindOfClass:[NSString class]]) {
    if ([ABI45_0_0EXUpdatesConfigCheckOnLaunchValueNever isEqualToString:(NSString *)checkOnLaunch]) {
      _checkOnLaunch = ABI45_0_0EXUpdatesCheckAutomaticallyConfigNever;
    } else if ([ABI45_0_0EXUpdatesConfigCheckOnLaunchValueErrorRecoveryOnly isEqualToString:(NSString *)checkOnLaunch]) {
      _checkOnLaunch = ABI45_0_0EXUpdatesCheckAutomaticallyConfigErrorRecoveryOnly;
    } else if ([ABI45_0_0EXUpdatesConfigCheckOnLaunchValueWifiOnly isEqualToString:(NSString *)checkOnLaunch]) {
      _checkOnLaunch = ABI45_0_0EXUpdatesCheckAutomaticallyConfigWifiOnly;
    } else if ([ABI45_0_0EXUpdatesConfigCheckOnLaunchValueAlways isEqualToString:(NSString *)checkOnLaunch]) {
      _checkOnLaunch = ABI45_0_0EXUpdatesCheckAutomaticallyConfigAlways;
    }
  }

  id sdkVersion = config[ABI45_0_0EXUpdatesConfigSDKVersionKey];
  if (sdkVersion && [sdkVersion isKindOfClass:[NSString class]]) {
    _sdkVersion = (NSString *)sdkVersion;
  }

  id runtimeVersion = config[ABI45_0_0EXUpdatesConfigRuntimeVersionKey];
  if (runtimeVersion && [runtimeVersion isKindOfClass:[NSString class]]) {
    _runtimeVersion = (NSString *)runtimeVersion;
  }

  id hasEmbeddedUpdate = config[ABI45_0_0EXUpdatesConfigHasEmbeddedUpdateKey];
  if (hasEmbeddedUpdate && [hasEmbeddedUpdate isKindOfClass:[NSNumber class]]) {
    _hasEmbeddedUpdate = [(NSNumber *)hasEmbeddedUpdate boolValue];
  }
  
  NSString *codeSigningCertificate;
  id codeSigningCertificateRaw = config[ABI45_0_0EXUpdatesConfigCodeSigningCertificateKey];
  if (codeSigningCertificateRaw && [codeSigningCertificateRaw isKindOfClass:[NSString class]]) {
    codeSigningCertificate = (NSString *)codeSigningCertificateRaw;
  }
  
  NSDictionary *codeSigningMetadata;
  id codeSigningMetadataRaw = config[ABI45_0_0EXUpdatesConfigCodeSigningMetadataKey];
  if (codeSigningMetadataRaw) {
    if(![codeSigningMetadataRaw isKindOfClass:[NSDictionary class]]){
      @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                     reason:[NSString stringWithFormat:@"Plist key \"%@\" must be a string-valued Dictionary.", ABI45_0_0EXUpdatesConfigCodeSigningMetadataKey]
                                   userInfo:@{}];
    }
    codeSigningMetadata = (NSDictionary *)codeSigningMetadataRaw;
    for (id key in codeSigningMetadata){
      if (![codeSigningMetadata[key] isKindOfClass:[NSString class]]){
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:[NSString stringWithFormat:@"Plist key \"%@\" must be a string-valued Dictionary.", ABI45_0_0EXUpdatesConfigCodeSigningMetadataKey]
                                     userInfo:@{}];
      }
    }
  }
  
  BOOL codeSigningIncludeManifestResponseCertificateChain = NO;
  id codeSigningIncludeManifestResponseCertificateChainRaw = config[ABI45_0_0EXUpdatesConfigCodeSigningIncludeManifestResponseCertificateChainKey];
  if (codeSigningIncludeManifestResponseCertificateChainRaw && [codeSigningIncludeManifestResponseCertificateChainRaw isKindOfClass:[NSNumber class]]) {
    codeSigningIncludeManifestResponseCertificateChain = [(NSNumber *)codeSigningIncludeManifestResponseCertificateChainRaw boolValue];
  }
  
  BOOL codeSigningAllowUnsignedManifests = NO;
  id codeSigningAllowUnsignedManifestsRaw = config[ABI45_0_0EXUpdatesConfigCodeSigningAllowUnsignedManifestsKey];
  if (codeSigningAllowUnsignedManifestsRaw && [codeSigningAllowUnsignedManifestsRaw isKindOfClass:[NSNumber class]]) {
    codeSigningAllowUnsignedManifests = [(NSNumber *)codeSigningAllowUnsignedManifestsRaw boolValue];
  }
  
  if (codeSigningCertificate) {
    _codeSigningConfiguration = [ABI45_0_0EXUpdatesConfig codeSigningConfigurationForCodeSigningCertificate:codeSigningCertificate
                                                                               codeSigningMetadata:codeSigningMetadata
                                                codeSigningIncludeManifestResponseCertificateChain:codeSigningIncludeManifestResponseCertificateChain
                                                                 codeSigningAllowUnsignedManifests:codeSigningAllowUnsignedManifests];
  }
}

- (BOOL)isMissingRuntimeVersion
{
  return (!_runtimeVersion || !_runtimeVersion.length) && (!_sdkVersion || !_sdkVersion.length);
}

+ (nullable ABI45_0_0EXUpdatesCodeSigningConfiguration *)codeSigningConfigurationForCodeSigningCertificate:(NSString *)codeSigningCertificate
                                                                              codeSigningMetadata:(nullable NSDictionary *)codeSigningMetadata
                                               codeSigningIncludeManifestResponseCertificateChain:(BOOL)codeSigningIncludeManifestResponseCertificateChain
                                                                codeSigningAllowUnsignedManifests:(BOOL)codeSigningAllowUnsignedManifests {
  NSError *error;
  ABI45_0_0EXUpdatesCodeSigningConfiguration *codeSigningConfiguration = [[ABI45_0_0EXUpdatesCodeSigningConfiguration alloc] initWithEmbeddedCertificateString:codeSigningCertificate
                                                                                                                                    metadata:codeSigningMetadata
                                                                                                     includeManifestResponseCertificateChain:codeSigningIncludeManifestResponseCertificateChain
                                                                                                                      allowUnsignedManifests:codeSigningAllowUnsignedManifests
                                                                                                                                       error:&error];
  if (error) {
    NSString *message = [ABI45_0_0EXUpdatesCodeSigningErrorUtils messageForError:error.code];
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:message userInfo:nil];
  }
  
  return codeSigningConfiguration;
}

+ (NSString *)normalizedURLOrigin:(NSURL *)url
{
  NSString *scheme = url.scheme;
  NSNumber *port = url.port;
  if (port && port.integerValue > -1 && [port isEqual:[[self class] defaultPortForScheme:scheme]]) {
    port = nil;
  }

  return (port && port.integerValue > -1)
    ? [NSString stringWithFormat:@"%@://%@:%ld", scheme, url.host, (long)port.integerValue]
    : [NSString stringWithFormat:@"%@://%@", scheme, url.host];
}

+ (nullable NSNumber *)defaultPortForScheme:(NSString *)scheme
{
  if ([@"http" isEqualToString:scheme] || [@"ws" isEqualToString:scheme]) {
    return @(80);
  } else if ([@"https" isEqualToString:scheme] || [@"wss" isEqualToString:scheme]) {
    return @(443);
  } else if ([@"ftp" isEqualToString:scheme]) {
    return @(21);
  }
  return nil;
}

@end

NS_ASSUME_NONNULL_END
