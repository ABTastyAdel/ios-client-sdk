//
//  ClientServiceFactory.swift
//  LaunchDarkly
//
//  Copyright © 2017 Catamorphic Co. All rights reserved.
//

import Foundation
import DarklyEventSource

protocol ClientServiceCreating {
    func makeKeyedValueCache() -> KeyedValueCaching
    func makeFeatureFlagCache(maxCachedUsers: Int) -> FeatureFlagCaching
    func makeCacheConverter(maxCachedUsers: Int) -> CacheConverting
    func makeDeprecatedCacheModel(_ model: DeprecatedCacheModel) -> DeprecatedCache
    func makeDarklyServiceProvider(config: LDConfig, user: LDUser) -> DarklyServiceProvider
    func makeFlagSynchronizer(streamingMode: LDStreamingMode, pollingInterval: TimeInterval, useReport: Bool, service: DarklyServiceProvider) -> LDFlagSynchronizing
    func makeFlagSynchronizer(streamingMode: LDStreamingMode,
                              pollingInterval: TimeInterval,
                              useReport: Bool,
                              service: DarklyServiceProvider,
                              onSyncComplete: FlagSyncCompleteClosure?) -> LDFlagSynchronizing
    func makeFlagChangeNotifier() -> FlagChangeNotifying
    func makeEventReporter(config: LDConfig, service: DarklyServiceProvider) -> EventReporting
    func makeEventReporter(config: LDConfig, service: DarklyServiceProvider, onSyncComplete: EventSyncCompleteClosure?) -> EventReporting
    func makeStreamingProvider(url: URL, httpHeaders: [String: String]) -> DarklyStreamingProvider
    func makeStreamingProvider(url: URL, httpHeaders: [String: String], connectMethod: String?, connectBody: Data?) -> DarklyStreamingProvider
    func makeEnvironmentReporter() -> EnvironmentReporting
    func makeThrottler(maxDelay: TimeInterval, environmentReporter: EnvironmentReporting) -> Throttling
    func makeErrorNotifier() -> ErrorNotifying
    func makeConnectionInformation() -> ConnectionInformation
}

final class ClientServiceFactory: ClientServiceCreating {
    func makeKeyedValueCache() -> KeyedValueCaching {
        UserDefaults.standard
    }

    func makeFeatureFlagCache(maxCachedUsers: Int) -> FeatureFlagCaching {
        UserEnvironmentFlagCache(withKeyedValueCache: makeKeyedValueCache(), maxCachedUsers: maxCachedUsers)
    }

    func makeCacheConverter(maxCachedUsers: Int) -> CacheConverting {
        CacheConverter(serviceFactory: self, maxCachedUsers: maxCachedUsers)
    }

    func makeDeprecatedCacheModel(_ model: DeprecatedCacheModel) -> DeprecatedCache {
        switch model {
        case .version2: return DeprecatedCacheModelV2(keyedValueCache: makeKeyedValueCache())
        case .version3: return DeprecatedCacheModelV3(keyedValueCache: makeKeyedValueCache())
        case .version4: return DeprecatedCacheModelV4(keyedValueCache: makeKeyedValueCache())
        case .version5: return DeprecatedCacheModelV5(keyedValueCache: makeKeyedValueCache())
        case .version6: return DeprecatedCacheModelV6(keyedValueCache: makeKeyedValueCache())
        }
    }

    func makeDarklyServiceProvider(config: LDConfig, user: LDUser) -> DarklyServiceProvider {
        DarklyService(config: config, user: user, serviceFactory: self)
    }

    func makeFlagSynchronizer(streamingMode: LDStreamingMode, pollingInterval: TimeInterval, useReport: Bool, service: DarklyServiceProvider) -> LDFlagSynchronizing {
        makeFlagSynchronizer(streamingMode: streamingMode, pollingInterval: pollingInterval, useReport: useReport, service: service, onSyncComplete: nil)
    }

    func makeFlagSynchronizer(streamingMode: LDStreamingMode,
                              pollingInterval: TimeInterval,
                              useReport: Bool,
                              service: DarklyServiceProvider,
                              onSyncComplete: FlagSyncCompleteClosure?) -> LDFlagSynchronizing {
        FlagSynchronizer(streamingMode: streamingMode, pollingInterval: pollingInterval, useReport: useReport, service: service, onSyncComplete: onSyncComplete)
    }

    func makeFlagChangeNotifier() -> FlagChangeNotifying {
        FlagChangeNotifier()
    }

    func makeEventReporter(config: LDConfig, service: DarklyServiceProvider) -> EventReporting {
        makeEventReporter(config: config, service: service, onSyncComplete: nil)
    }

    func makeEventReporter(config: LDConfig, service: DarklyServiceProvider, onSyncComplete: EventSyncCompleteClosure? = nil) -> EventReporting {
        EventReporter(config: config, service: service, onSyncComplete: onSyncComplete)
    }

    func makeStreamingProvider(url: URL, httpHeaders: [String: String]) -> DarklyStreamingProvider {
        LDEventSource(url: url, httpHeaders: httpHeaders)
    }

    func makeStreamingProvider(url: URL, httpHeaders: [String: String], connectMethod: String?, connectBody: Data?) -> DarklyStreamingProvider {
        LDEventSource(url: url, httpHeaders: httpHeaders, connectMethod: connectMethod, connectBody: connectBody)
    }

    func makeEnvironmentReporter() -> EnvironmentReporting {
        EnvironmentReporter()
    }

    func makeThrottler(maxDelay: TimeInterval, environmentReporter: EnvironmentReporting) -> Throttling {
        Throttler(maxDelay: maxDelay, environmentReporter: environmentReporter)
    }

    func makeErrorNotifier() -> ErrorNotifying {
        ErrorNotifier()
    }
    
    func makeConnectionInformation() -> ConnectionInformation {
        ConnectionInformation(currentConnectionMode: .offline, lastConnectionFailureReason: .none)
    }
}
