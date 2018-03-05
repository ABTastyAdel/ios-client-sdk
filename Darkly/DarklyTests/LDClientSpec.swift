//
//  LDClientSpec.swift
//  DarklyTests
//
//  Created by Mark Pokorny on 11/13/17. +JMJ
//  Copyright © 2017 LaunchDarkly. All rights reserved.
//

import Quick
import Nimble
@testable import Darkly

final class LDClientSpec: QuickSpec {
    struct Constants {
        fileprivate static let mockMobileKey = "mockMobileKey"
        fileprivate static let alternateMockUrl = URL(string: "https://dummy.alternate.com")!
    }

    //swiftlint:disable function_body_length
    override func spec() {
        var subject: LDClient!
        var user: LDUser!
        var config: LDConfig!

        beforeEach {
            subject = LDClient(serviceFactory: ClientServiceMockFactory())

            config = LDConfig.stub
            config.startOnline = false
            config.eventFlushIntervalMillis = 300_000   //5 min...don't want this to trigger

            user = LDUser.stub()
        }

        describe("start") {
            context("when configured to start online") {
                beforeEach {
                    subject = LDClient(serviceFactory: ClientServiceMockFactory())
                    config.startOnline = true

                    subject.start(mobileKey: Constants.mockMobileKey, config: config, user: user)
                }
                it("takes the client and service objects online") {
                    expect(subject.isOnline) == true
                    expect(subject.flagSynchronizer.isOnline) == subject.isOnline
                    expect(subject.eventReporter.isOnline) == subject.isOnline
                }
                it("saves the config") {
                    expect(subject.config) == config
                    expect(subject.service.config) == config
                    expect(subject.flagSynchronizer.streamingMode) == config.streamingMode
                    expect(subject.flagSynchronizer.pollingInterval) == config.flagPollingInterval(runMode: subject.runMode)
                    expect(subject.eventReporter.config) == config
                }
            }
            context("when configured to start offline") {
                beforeEach {
                    subject.start(mobileKey: Constants.mockMobileKey, config: config, user: user)
                }
                it("leaves the client and service objects offline") {
                    expect(subject.isOnline) == false
                    expect(subject.flagSynchronizer.isOnline) == subject.isOnline
                    expect(subject.eventReporter.isOnline) == subject.isOnline
                }
                it("saves the config") {
                    expect(subject.config) == config
                    expect(subject.service.config) == config
                    expect(subject.flagSynchronizer.streamingMode) == config.streamingMode
                    expect(subject.flagSynchronizer.pollingInterval) == config.flagPollingInterval(runMode: subject.runMode)
                    expect(subject.eventReporter.config) == config
                }
            }
            context("when configured to allow background updates and running in background mode") {
                beforeEach {
                    subject = LDClient(serviceFactory: ClientServiceMockFactory(), runMode: .background)
                    config.startOnline = true

                    subject.start(mobileKey: Constants.mockMobileKey, config: config, user: user)
                }
                it("takes the client and service objects online") {
                    expect(subject.isOnline) == true
                    expect(subject.flagSynchronizer.isOnline) == subject.isOnline
                    expect(subject.eventReporter.isOnline) == subject.isOnline
                }
                it("saves the config") {
                    expect(subject.config) == config
                    expect(subject.service.config) == config
                    expect(subject.flagSynchronizer.streamingMode) == LDStreamingMode.polling
                    expect(subject.flagSynchronizer.pollingInterval) == config.flagPollingInterval(runMode: .background)
                    expect(subject.eventReporter.config) == config
                }
            }
            context("when configured to not allow background updates and running in background mode") {
                beforeEach {
                    subject = LDClient(serviceFactory: ClientServiceMockFactory(), runMode: .background)
                    config.startOnline = true
                    config.enableBackgroundUpdates = false

                    subject.start(mobileKey: Constants.mockMobileKey, config: config, user: user)
                }
                it("leaves the client and service objects offline") {
                    expect(subject.isOnline) == false
                    expect(subject.flagSynchronizer.isOnline) == subject.isOnline
                    expect(subject.eventReporter.isOnline) == subject.isOnline
                }
                it("saves the config") {
                    expect(subject.config) == config
                    expect(subject.service.config) == config
                    expect(subject.flagSynchronizer.streamingMode) == LDStreamingMode.polling
                    expect(subject.flagSynchronizer.pollingInterval) == config.flagPollingInterval(runMode: .foreground)
                    expect(subject.eventReporter.config) == config
                }
            }
        }

        describe("change config and user") {
            var flagSynchronizerMock: LDFlagSynchronizingMock!
            var eventReporterMock: LDEventReportingMock!
            var setIsOnlineCount: (flagSync: Int, event: Int) = (0, 0)
            beforeEach {
                flagSynchronizerMock = subject.flagSynchronizer as? LDFlagSynchronizingMock
                eventReporterMock = subject.eventReporter as? LDEventReportingMock
            }
            context("when config and user values are the same") {
                beforeEach {
                    subject.start(mobileKey: Constants.mockMobileKey, config: config, user: user)
                    setIsOnlineCount = (flagSynchronizerMock.isOnlineSetCount, eventReporterMock.isOnlineSetCount)

                    subject.change(config: config, user: user)
                }
                it("retains the config and user values") {
                    expect(subject.config) == config
                    expect(subject.user) == user
                }
                it("doesn't try to change service object isOnline state") {
                    expect(flagSynchronizerMock.isOnlineSetCount) == setIsOnlineCount.flagSync
                    expect(eventReporterMock.isOnlineSetCount) == setIsOnlineCount.event
                }
            }
            context("when config and user values are nil") {
                beforeEach {
                    subject.start(mobileKey: Constants.mockMobileKey, config: config, user: user)
                    setIsOnlineCount = (flagSynchronizerMock.isOnlineSetCount, eventReporterMock.isOnlineSetCount)

                    subject.change(config: nil, user: nil)
                }
                it("retains the config and user values") {
                    expect(subject.config) == config
                    expect(subject.user) == user
                }
                it("doesn't try to change service object isOnline state") {
                    expect(flagSynchronizerMock.isOnlineSetCount) == setIsOnlineCount.flagSync
                    expect(eventReporterMock.isOnlineSetCount) == setIsOnlineCount.event
                }
            }
            context("when config values differ") {
                var newConfig: LDConfig!
                context("with run mode set to foreground") {
                    beforeEach {
                        subject.start(mobileKey: Constants.mockMobileKey, config: config, user: user)
                        newConfig = config
                        newConfig.baseUrl = Constants.alternateMockUrl
                        newConfig.pollIntervalMillis += 1
                        newConfig.eventFlushIntervalMillis += 1

                        subject.change(config: newConfig)
                    }
                    it("changes to the new config values") {
                        expect(subject.config) == newConfig
                        expect(subject.service.config) == newConfig
                        expect(subject.flagSynchronizer.streamingMode) == newConfig.streamingMode
                        expect(subject.flagSynchronizer.pollingInterval) == newConfig.flagPollingInterval(runMode: subject.runMode)
                        expect(subject.eventReporter.config) == newConfig
                    }
                }
                context("with run mode set to background") {
                    beforeEach {
                        subject = LDClient(serviceFactory: ClientServiceMockFactory(), runMode: .background)
                        subject.start(mobileKey: Constants.mockMobileKey, config: config, user: user)
                        newConfig = config
                        newConfig.baseUrl = Constants.alternateMockUrl
                        newConfig.backgroundPollIntervalMillis += 1
                        newConfig.eventFlushIntervalMillis += 1

                        subject.change(config: newConfig)
                    }
                    it("changes to the new config values") {
                        expect(subject.config) == newConfig
                        expect(subject.service.config) == newConfig
                        expect(subject.flagSynchronizer.streamingMode) == LDStreamingMode.polling
                        expect(subject.flagSynchronizer.pollingInterval) == newConfig.flagPollingInterval(runMode: subject.runMode)
                        expect(subject.eventReporter.config) == newConfig
                    }
                }
            }
            context("when user values differ") {
                var newUser: LDUser!
                context("different user") {
                    beforeEach {
                        subject.start(mobileKey: Constants.mockMobileKey, config: config, user: user)
                        newUser = LDUser.stub()

                        subject.change(user: newUser)
                    }
                    it("retains the config and updates the user") {
                        expect(subject.config) == config
                        expect(subject.user) == newUser
                    }
                }
            }
        }

        describe("change isOnline") {
            context("when the client is offline") {
                context("setting online") {
                    beforeEach {
                        subject.start(mobileKey: Constants.mockMobileKey, config: config, user: user)
                        subject.isOnline = false

                        subject.isOnline = true
                    }
                    it("sets the client and service objects online") {
                        expect(subject.isOnline) == true
                        expect(subject.flagSynchronizer.isOnline) == subject.isOnline
                        expect(subject.eventReporter.isOnline) == subject.isOnline
                    }
                }
            }
            context("when the client is online") {
                context("setting offline") {
                    beforeEach {
                        subject.start(mobileKey: Constants.mockMobileKey, config: config, user: user)

                        subject.isOnline = false
                    }
                    it("takes the client and service objects offline") {
                        expect(subject.isOnline) == false
                        expect(subject.flagSynchronizer.isOnline) == subject.isOnline
                        expect(subject.eventReporter.isOnline) == subject.isOnline
                    }
                }
            }
            context("when the client has not been started") {
                beforeEach {
                    subject.isOnline = true
                }
                it("leaves the client and service objects offline") {
                    expect(subject.isOnline) == false
                    expect(subject.flagSynchronizer.isOnline) == subject.isOnline
                    expect(subject.eventReporter.isOnline) == subject.isOnline
                }
            }
            context("when the client runs in the background") {
                beforeEach {
                    subject = LDClient(serviceFactory: ClientServiceMockFactory(), runMode: .background)
                }
                context("while configured to enable background updates") {
                    beforeEach {
                        subject.start(mobileKey: Constants.mockMobileKey, config: config, user: user)
                    }
                    context("and setting online") {
                        beforeEach {
                            subject.isOnline = true
                        }
                        it("takes the client and service objects online") {
                            expect(subject.isOnline) == true
                            expect(subject.flagSynchronizer.isOnline) == subject.isOnline
                            expect(subject.flagSynchronizer.streamingMode) == LDStreamingMode.polling
                            expect(subject.flagSynchronizer.pollingInterval) == config.flagPollingInterval(runMode: subject.runMode)
                            expect(subject.eventReporter.isOnline) == subject.isOnline
                        }
                    }
                }
                context("while configured to disable background updates") {
                    beforeEach {
                        config.enableBackgroundUpdates = false
                        subject.start(mobileKey: Constants.mockMobileKey, config: config, user: user)
                    }
                    context("and setting online") {
                        beforeEach {
                            subject.isOnline = true
                        }
                        it("leaves the client and service objects offline") {
                            expect(subject.isOnline) == false
                            expect(subject.flagSynchronizer.isOnline) == subject.isOnline
                            expect(subject.flagSynchronizer.streamingMode) == LDStreamingMode.polling
                            expect(subject.flagSynchronizer.pollingInterval) == config.flagPollingInterval(runMode: .foreground)
                            expect(subject.eventReporter.isOnline) == subject.isOnline
                        }
                    }
                }
            }
        }

        //TODO: When implementing background mode, verify switching background modes affects the service objects
    }
}
