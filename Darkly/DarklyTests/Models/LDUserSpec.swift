//
//  LDUserSpec.swift
//  DarklyTests
//
//  Created by Mark Pokorny on 10/23/17. +JMJ
//  Copyright © 2017 LaunchDarkly. All rights reserved.
//

import Quick
import Nimble
@testable import Darkly

final class LDUserSpec: QuickSpec {

    struct Constants {
        fileprivate static let userCount = 3
    }

    override func spec() {

        var subject: LDUser!
        describe("init") {
            context("called with optional elements") {
                beforeEach {
                    subject = LDUser(key: LDUser.StubConstants.key, name: LDUser.StubConstants.name, firstName: LDUser.StubConstants.firstName, lastName: LDUser.StubConstants.lastName,
                                     country: LDUser.StubConstants.country, ipAddress: LDUser.StubConstants.ipAddress, email: LDUser.StubConstants.email, avatar: LDUser.StubConstants.avatar,
                                     custom: LDUser.StubConstants.custom, isAnonymous: LDUser.StubConstants.isAnonymous, privateAttributes: LDUser.privatizableAttributes)
                }
                it("creates a LDUser with optional elements") {
                    expect(subject.key) == LDUser.StubConstants.key
                    expect(subject.name) == LDUser.StubConstants.name
                    expect(subject.firstName) == LDUser.StubConstants.firstName
                    expect(subject.lastName) == LDUser.StubConstants.lastName
                    expect(subject.isAnonymous) == LDUser.StubConstants.isAnonymous
                    expect(subject.country) == LDUser.StubConstants.country
                    expect(subject.ipAddress) == LDUser.StubConstants.ipAddress
                    expect(subject.email) == LDUser.StubConstants.email
                    expect(subject.avatar) == LDUser.StubConstants.avatar
                    expect(subject.device) == LDUser.StubConstants.device
                    expect(subject.operatingSystem) == LDUser.StubConstants.operatingSystem
                    expect(subject.custom).toNot(beNil())
                    if let subjectCustom = subject.custom {
                        expect(subjectCustom == LDUser.StubConstants.custom).to(beTrue())
                    }
                    expect(subject.lastUpdated).toNot(beNil())
                    expect(subject.privateAttributes).toNot(beNil())
                    if let privateAttributes = subject.privateAttributes {
                        expect(privateAttributes) == LDUser.privatizableAttributes
                    }
                }
            }
            context("called without optional elements") {
                beforeEach {
                    subject = LDUser(isAnonymous: true)
                }
                it("creates a LDUser without optional elements") {
                    expect(subject.key).toNot(beNil())
                    expect(subject.isAnonymous) == true
                    expect(subject.lastUpdated).toNot(beNil())

                    expect(subject.name).to(beNil())
                    expect(subject.firstName).to(beNil())
                    expect(subject.lastName).to(beNil())
                    expect(subject.country).to(beNil())
                    expect(subject.ipAddress).to(beNil())
                    expect(subject.email).to(beNil())
                    expect(subject.avatar).to(beNil())
                    expect(subject.device).toNot(beNil())
                    expect(subject.operatingSystem).toNot(beNil())
                    expect(subject.custom).to(beNil())
                    expect(subject.privateAttributes).to(beNil())
                }
            }
            context("called without a key multiple times") {
                var users = [LDUser]()
                beforeEach {
                    while users.count < Constants.userCount {
                        users.append(LDUser())
                    }
                }
                it("creates each LDUser with the default key and isAnonymous set") {
                    users.forEach { (user) in
                        expect(user.key) == LDUser.defaultKey
                        expect(user.isAnonymous) == true
                    }
                }
            }
        }

        describe("init from dictionary") {
            var originalUser: LDUser!
            let mockLastUpdated = "2017-10-24T17:51:49.142Z"
            context("called with config") {
                context("and optional elements") {
                    beforeEach {
                        originalUser = LDUser.stub()
                        var userDictionary = originalUser.dictionaryValue(includeFlagConfig: true, includePrivateAttributes: true, config: LDConfig())
                        userDictionary[LDUser.CodingKeys.lastUpdated.rawValue] = mockLastUpdated
                        userDictionary[LDUser.CodingKeys.privateAttributes.rawValue] = LDUser.privatizableAttributes
                        subject = LDUser(userDictionary: userDictionary)
                    }
                    it("creates a user with optional elements and feature flags") {
                        expect(subject.key) == originalUser.key
                        expect(subject.name) == originalUser.name
                        expect(subject.firstName) == originalUser.firstName
                        expect(subject.lastName) == originalUser.lastName
                        expect(subject.isAnonymous) == originalUser.isAnonymous
                        expect(subject.country) == originalUser.country
                        expect(subject.ipAddress) == originalUser.ipAddress
                        expect(subject.email) == originalUser.email
                        expect(subject.avatar) == originalUser.avatar

                        expect(originalUser.custom).toNot(beNil())
                        expect(subject.custom).toNot(beNil())
                        if let originalCustom = originalUser.custom,
                            let subjectCustom = subject.custom {
                            expect(subjectCustom == originalCustom).to(beTrue())
                        }

                        expect(subject.device) == originalUser.device
                        expect(subject.operatingSystem) == originalUser.operatingSystem
                        expect(subject.lastUpdated) == DateFormatter.ldDateFormatter.date(from: mockLastUpdated)

                        expect(subject.privateAttributes).toNot(beNil())
                        if let privateAttributes = subject.privateAttributes {
                            expect(privateAttributes) == LDUser.privatizableAttributes
                        }

                        expect(subject.flagStore.featureFlags == originalUser.flagStore.featureFlags).to(beTrue())
                    }
                }
                context("but without optional elements") {
                    beforeEach {
                        originalUser = LDUser(isAnonymous: true)
                        var userDictionary = originalUser.dictionaryValueWithAllAttributes(includeFlagConfig: true)
                        userDictionary[LDUser.CodingKeys.lastUpdated.rawValue] = mockLastUpdated
                        subject = LDUser(userDictionary: userDictionary)

                    }
                    it("creates a user without optional elements and with feature flags") {
                        expect(subject.key) == originalUser.key
                        expect(subject.isAnonymous) == originalUser.isAnonymous
                        expect(subject.lastUpdated) == DateFormatter.ldDateFormatter.date(from: mockLastUpdated)

                        expect(subject.name).to(beNil())
                        expect(subject.firstName).to(beNil())
                        expect(subject.lastName).to(beNil())
                        expect(subject.country).to(beNil())
                        expect(subject.ipAddress).to(beNil())
                        expect(subject.email).to(beNil())
                        expect(subject.avatar).to(beNil())
                        expect(subject.device).toNot(beNil())
                        expect(subject.operatingSystem).toNot(beNil())

                        expect(subject.custom).toNot(beNil())
                        if let customDictionary = subject.customWithoutSdkSetAttributes {
                            expect(customDictionary.isEmpty) == true
                        }
                        expect(subject.privateAttributes).to(beNil())

                        expect(subject.flagStore.featureFlags == originalUser.flagStore.featureFlags).to(beTrue())
                    }
                }
            }
            context("called without config") {
                context("but with optional elements") {
                    beforeEach {
                        originalUser = LDUser.stub()
                        originalUser.privateAttributes = LDUser.privatizableAttributes
                        var userDictionary = originalUser.dictionaryValueWithAllAttributes(includeFlagConfig: false)
                        userDictionary[LDUser.CodingKeys.lastUpdated.rawValue] = mockLastUpdated
                        userDictionary[LDUser.CodingKeys.privateAttributes.rawValue] = LDUser.privatizableAttributes
                        subject = LDUser(userDictionary: userDictionary)
                    }
                    it("creates a user with optional elements") {
                        expect(subject.key) == originalUser.key
                        expect(subject.name) == originalUser.name
                        expect(subject.firstName) == originalUser.firstName
                        expect(subject.lastName) == originalUser.lastName
                        expect(subject.isAnonymous) == originalUser.isAnonymous
                        expect(subject.country) == originalUser.country
                        expect(subject.ipAddress) == originalUser.ipAddress
                        expect(subject.email) == originalUser.email
                        expect(subject.avatar) == originalUser.avatar

                        expect(originalUser.custom).toNot(beNil())
                        expect(subject.custom).toNot(beNil())
                        if let originalCustom = originalUser.custom,
                            let subjectCustom = subject.custom {
                            expect(subjectCustom == originalCustom).to(beTrue())
                        }

                        expect(subject.device) == originalUser.device
                        expect(subject.operatingSystem) == originalUser.operatingSystem
                        expect(subject.lastUpdated) == DateFormatter.ldDateFormatter.date(from: mockLastUpdated)

                        expect(subject.privateAttributes).toNot(beNil())
                        if let privateAttributes = subject.privateAttributes {
                            expect(privateAttributes) == LDUser.privatizableAttributes
                        }

                        expect(subject.flagStore.featureFlags.isEmpty).to(beTrue())
                    }
                }
                context("or optional elements") {
                    beforeEach {
                        originalUser = LDUser(isAnonymous: true)
                        var userDictionary = originalUser.dictionaryValueWithAllAttributes(includeFlagConfig: false)
                        userDictionary[LDUser.CodingKeys.lastUpdated.rawValue] = mockLastUpdated
                        subject = LDUser(userDictionary: userDictionary)
                    }
                    it("creates a user without optional elements or feature flags") {
                        expect(subject.key) == originalUser.key
                        expect(subject.isAnonymous) == originalUser.isAnonymous
                        expect(subject.lastUpdated) == DateFormatter.ldDateFormatter.date(from: mockLastUpdated)

                        expect(subject.name).to(beNil())
                        expect(subject.firstName).to(beNil())
                        expect(subject.lastName).to(beNil())
                        expect(subject.country).to(beNil())
                        expect(subject.ipAddress).to(beNil())
                        expect(subject.email).to(beNil())
                        expect(subject.avatar).to(beNil())
                        expect(subject.device).toNot(beNil())
                        expect(subject.operatingSystem).toNot(beNil())
                        expect(subject.custom).toNot(beNil())
                        if let customDictionary = subject.customWithoutSdkSetAttributes {
                            expect(customDictionary.isEmpty) == true
                        }
                        expect(subject.privateAttributes).to(beNil())

                        expect(subject.flagStore.featureFlags.isEmpty).to(beTrue())
                    }
                }
                context("and with an empty dictionary") {
                    beforeEach {
                        subject = LDUser(userDictionary: [:])
                    }
                    it("creates a user without optional elements or feature flags") {
                        expect(subject.key).toNot(beNil())
                        expect(subject.key.isEmpty).to(beFalse())
                        expect(subject.isAnonymous) == false
                        expect(subject.lastUpdated).toNot(beNil())

                        expect(subject.name).to(beNil())
                        expect(subject.firstName).to(beNil())
                        expect(subject.lastName).to(beNil())
                        expect(subject.country).to(beNil())
                        expect(subject.ipAddress).to(beNil())
                        expect(subject.email).to(beNil())
                        expect(subject.avatar).to(beNil())
                        expect(subject.device).to(beNil())
                        expect(subject.operatingSystem).to(beNil())
                        expect(subject.custom).to(beNil())
                        expect(subject.privateAttributes).to(beNil())

                        expect(subject.flagStore.featureFlags.isEmpty).to(beTrue())
                    }
                }
                context("but with an incorrect last updated format") {
                    let invalidLastUpdated = "2017-10-24T17:51:49Z"
                    beforeEach {
                        subject = LDUser(userDictionary: [LDUser.CodingKeys.lastUpdated.rawValue: invalidLastUpdated])
                    }
                    it("creates a user without optional elements or feature flags") {
                        expect(subject.key).toNot(beNil())
                        expect(subject.key.isEmpty).to(beFalse())
                        expect(subject.isAnonymous) == false
                        expect(subject.lastUpdated).toNot(beNil())
                        expect(DateFormatter.ldDateFormatter.string(from: subject.lastUpdated)) != invalidLastUpdated

                        expect(subject.name).to(beNil())
                        expect(subject.firstName).to(beNil())
                        expect(subject.lastName).to(beNil())
                        expect(subject.country).to(beNil())
                        expect(subject.ipAddress).to(beNil())
                        expect(subject.email).to(beNil())
                        expect(subject.avatar).to(beNil())
                        expect(subject.device).to(beNil())
                        expect(subject.operatingSystem).to(beNil())
                        expect(subject.custom).to(beNil())
                        expect(subject.privateAttributes).to(beNil())

                        expect(subject.flagStore.featureFlags.isEmpty).to(beTrue())
                    }
                }
            }
        }

        describe("dictionaryValue") {
            var config: LDConfig!
            var userDictionary: [String: Any]!
            var privateAttributes: [String]!
            context("including private attributes") {
                context("with individual private attributes") {
                    context("contained in the config") {
                        beforeEach {
                            config = LDConfig()
                            subject = LDUser.stub()
                            privateAttributes = LDUser.privatizableAttributes + subject.customAttributes!
                        }
                        it("creates a matching dictionary") {
                            privateAttributes.forEach { (attribute) in
                                config.privateUserAttributes = [attribute]
                                [true, false].forEach { (includeFlagConfig) in
                                    userDictionary = subject.dictionaryValue(includeFlagConfig: includeFlagConfig, includePrivateAttributes: true, config: config)

                                    //creates a dictionary with matching key value pairs
                                    expect({ subject.requiredAttributeKeyValuePairsMatch(userDictionary: userDictionary) }).to(match())
                                    expect({ subject.optionalAttributePublicKeyValuePairsMatch(userDictionary: userDictionary, privateAttributes: []) }).to(match())
                                    expect({ subject.sdkSetAttributesKeyValuePairsMatch(userDictionary: userDictionary) }).to(match())
                                    expect({ subject.customDictionaryPublicKeyValuePairsMatch(userDictionary: userDictionary, privateAttributes: []) }).to(match())

                                    //creates a dictionary without redacted attributes
                                    expect(userDictionary.redactedAttributes).to(beNil())

                                    //creates a dictionary with or without a matching flag config
                                    includeFlagConfig ? expect({ subject.flagConfigMatches(userDictionary: userDictionary) }).to(match())
                                        : expect(userDictionary.flagConfig).to(beNil())
                                }
                            }
                        }
                    }
                    context("contained in the user") {
                        context("on a populated user") {
                            beforeEach {
                                config = LDConfig()
                                subject = LDUser.stub()
                                privateAttributes = LDUser.privatizableAttributes + subject.customAttributes!
                            }
                            it("creates a matching dictionary") {
                                privateAttributes.forEach { (attribute) in
                                    subject.privateAttributes = [attribute]
                                    [true, false].forEach { (includeFlagConfig) in
                                        userDictionary = subject.dictionaryValue(includeFlagConfig: includeFlagConfig, includePrivateAttributes: true, config: config)

                                        //creates a dictionary with matching key value pairs
                                        expect({ subject.requiredAttributeKeyValuePairsMatch(userDictionary: userDictionary) }).to(match())
                                        expect({ subject.optionalAttributePublicKeyValuePairsMatch(userDictionary: userDictionary, privateAttributes: []) }).to(match())
                                        expect({ subject.sdkSetAttributesKeyValuePairsMatch(userDictionary: userDictionary) }).to(match())
                                        expect({ subject.customDictionaryPublicKeyValuePairsMatch(userDictionary: userDictionary, privateAttributes: []) }).to(match())

                                        //creates a dictionary without redacted attributes
                                        expect(userDictionary.redactedAttributes).to(beNil())

                                        //creates a dictionary with or without a matching flag config
                                        includeFlagConfig ? expect({ subject.flagConfigMatches(userDictionary: userDictionary) }).to(match())
                                            : expect(userDictionary.flagConfig).to(beNil())
                                    }
                                }
                            }
                        }
                        context("on an empty user") {
                            beforeEach {
                                config = LDConfig()
                                subject = LDUser()
                                privateAttributes = LDUser.privatizableAttributes
                            }
                            it("creates a matching dictionary") {
                                privateAttributes.forEach { (attribute) in
                                    subject.privateAttributes = [attribute]
                                    [true, false].forEach { (includeFlagConfig) in
                                        userDictionary = subject.dictionaryValue(includeFlagConfig: includeFlagConfig, includePrivateAttributes: true, config: config)

                                        //creates a dictionary with matching key value pairs
                                        expect({ subject.requiredAttributeKeyValuePairsMatch(userDictionary: userDictionary) }).to(match())
                                        expect({ subject.optionalAttributeMissingValueKeysDontExist(userDictionary: userDictionary) }).to(match())
                                        expect({ subject.sdkSetAttributesKeyValuePairsMatch(userDictionary: userDictionary) }).to(match())
                                        expect({ subject.customDictionaryContainsOnlySdkSetAttributes(userDictionary: userDictionary) }).to(match())

                                        //creates a dictionary without redacted attributes
                                        expect(userDictionary.redactedAttributes).to(beNil())

                                        //creates a dictionary with or without a matching flag config
                                        includeFlagConfig ? expect({ subject.flagConfigMatches(userDictionary: userDictionary) }).to(match())
                                            : expect(userDictionary.flagConfig).to(beNil())
                                    }
                                }
                            }
                        }
                    }
                }
                context("with all private attributes") {
                    context("using the config flag") {
                        beforeEach {
                            config = LDConfig()
                            config.allUserAttributesPrivate = true
                            subject = LDUser.stub()
                        }
                        it("creates a dictionary with matching key value pairs") {
                            [true, false].forEach { (includeFlagConfig) in
                                userDictionary = subject.dictionaryValue(includeFlagConfig: includeFlagConfig, includePrivateAttributes: true, config: config)

                                expect({ subject.requiredAttributeKeyValuePairsMatch(userDictionary: userDictionary) }).to(match())
                                expect({ subject.optionalAttributePublicKeyValuePairsMatch(userDictionary: userDictionary, privateAttributes: []) }).to(match())
                                expect({ subject.sdkSetAttributesKeyValuePairsMatch(userDictionary: userDictionary) }).to(match())
                                expect({ subject.customDictionaryPublicKeyValuePairsMatch(userDictionary: userDictionary, privateAttributes: []) }).to(match())
                            }
                        }
                        it("creates a dictionary without redacted attributes") {
                            [true, false].forEach { (includeFlagConfig) in
                                userDictionary = subject.dictionaryValue(includeFlagConfig: includeFlagConfig, includePrivateAttributes: true, config: config)

                                expect(userDictionary.redactedAttributes).to(beNil())
                            }
                        }
                        it("creates a dictionary with or without a matching flag config") {
                            [true, false].forEach { (includeFlagConfig) in
                                userDictionary = subject.dictionaryValue(includeFlagConfig: includeFlagConfig, includePrivateAttributes: true, config: config)

                                includeFlagConfig ? expect({ subject.flagConfigMatches(userDictionary: userDictionary) }).to(match())
                                    : expect(userDictionary.flagConfig).to(beNil())
                            }
                        }
                    }
                    context("contained in the config") {
                        beforeEach {
                            config = LDConfig()
                            config.privateUserAttributes = LDUser.privatizableAttributes
                            subject = LDUser.stub()
                        }
                        it("creates a dictionary with matching key value pairs") {
                            [true, false].forEach { (includeFlagConfig) in
                                userDictionary = subject.dictionaryValue(includeFlagConfig: includeFlagConfig, includePrivateAttributes: true, config: config)

                                expect({ subject.requiredAttributeKeyValuePairsMatch(userDictionary: userDictionary) }).to(match())
                                expect({ subject.optionalAttributePublicKeyValuePairsMatch(userDictionary: userDictionary, privateAttributes: []) }).to(match())
                                expect({ subject.sdkSetAttributesKeyValuePairsMatch(userDictionary: userDictionary) }).to(match())
                                expect({ subject.customDictionaryPublicKeyValuePairsMatch(userDictionary: userDictionary, privateAttributes: []) }).to(match())
                            }
                        }
                        it("creates a dictionary without redacted attributes") {
                            [true, false].forEach { (includeFlagConfig) in
                                userDictionary = subject.dictionaryValue(includeFlagConfig: includeFlagConfig, includePrivateAttributes: true, config: config)

                                expect(userDictionary.redactedAttributes).to(beNil())
                            }
                        }
                        it("creates a dictionary with or without a matching flag config") {
                            [true, false].forEach { (includeFlagConfig) in
                                userDictionary = subject.dictionaryValue(includeFlagConfig: includeFlagConfig, includePrivateAttributes: true, config: config)

                                includeFlagConfig ? expect({ subject.flagConfigMatches(userDictionary: userDictionary) }).to(match())
                                    : expect(userDictionary.flagConfig).to(beNil())
                            }
                        }
                    }
                    context("contained in the user") {
                        beforeEach {
                            config = LDConfig()
                            subject = LDUser.stub()
                            subject.privateAttributes = LDUser.privatizableAttributes
                        }
                        it("creates a dictionary with matching key value pairs") {
                            [true, false].forEach { (includeFlagConfig) in
                                userDictionary = subject.dictionaryValue(includeFlagConfig: includeFlagConfig, includePrivateAttributes: true, config: config)

                                expect({ subject.requiredAttributeKeyValuePairsMatch(userDictionary: userDictionary) }).to(match())
                                expect({ subject.optionalAttributePublicKeyValuePairsMatch(userDictionary: userDictionary, privateAttributes: []) }).to(match())
                                expect({ subject.sdkSetAttributesKeyValuePairsMatch(userDictionary: userDictionary) }).to(match())
                                expect({ subject.customDictionaryPublicKeyValuePairsMatch(userDictionary: userDictionary, privateAttributes: []) }).to(match())
                            }
                        }
                        it("creates a dictionary without redacted attributes") {
                            [true, false].forEach { (includeFlagConfig) in
                                userDictionary = subject.dictionaryValue(includeFlagConfig: includeFlagConfig, includePrivateAttributes: true, config: config)

                                expect(userDictionary.redactedAttributes).to(beNil())
                            }
                        }
                        it("creates a dictionary with or without a matching flag config") {
                            [true, false].forEach { (includeFlagConfig) in
                                userDictionary = subject.dictionaryValue(includeFlagConfig: includeFlagConfig, includePrivateAttributes: true, config: config)

                                includeFlagConfig ? expect({ subject.flagConfigMatches(userDictionary: userDictionary) }).to(match())
                                    : expect(userDictionary.flagConfig).to(beNil())
                            }
                        }
                    }
                }
                context("with no private attributes") {
                    context("by setting private attributes to nil") {
                        beforeEach {
                            config = LDConfig()
                            subject = LDUser.stub()
                        }
                        it("creates a dictionary with matching key value pairs") {
                            [true, false].forEach { (includeFlagConfig) in
                                userDictionary = subject.dictionaryValue(includeFlagConfig: includeFlagConfig, includePrivateAttributes: true, config: config)

                                expect({ subject.requiredAttributeKeyValuePairsMatch(userDictionary: userDictionary) }).to(match())
                                expect({ subject.optionalAttributePublicKeyValuePairsMatch(userDictionary: userDictionary, privateAttributes: []) }).to(match())
                                expect({ subject.sdkSetAttributesKeyValuePairsMatch(userDictionary: userDictionary) }).to(match())
                                expect({ subject.customDictionaryPublicKeyValuePairsMatch(userDictionary: userDictionary, privateAttributes: []) }).to(match())
                            }
                        }
                        it("creates a dictionary without redacted attributes") {
                            [true, false].forEach { (includeFlagConfig) in
                                userDictionary = subject.dictionaryValue(includeFlagConfig: includeFlagConfig, includePrivateAttributes: true, config: config)

                                expect(userDictionary.redactedAttributes).to(beNil())
                            }
                        }
                        it("creates a dictionary with or without a matching flag config") {
                            [true, false].forEach { (includeFlagConfig) in
                                userDictionary = subject.dictionaryValue(includeFlagConfig: includeFlagConfig, includePrivateAttributes: true, config: config)

                                includeFlagConfig ? expect({ subject.flagConfigMatches(userDictionary: userDictionary) }).to(match())
                                    : expect(userDictionary.flagConfig).to(beNil())
                            }
                        }
                    }
                    context("by setting config private attributes to empty") {
                        beforeEach {
                            config = LDConfig()
                            config.privateUserAttributes = []
                            subject = LDUser.stub()
                        }
                        it("creates a dictionary with matching key value pairs") {
                            [true, false].forEach { (includeFlagConfig) in
                                userDictionary = subject.dictionaryValue(includeFlagConfig: includeFlagConfig, includePrivateAttributes: true, config: config)

                                expect({ subject.requiredAttributeKeyValuePairsMatch(userDictionary: userDictionary) }).to(match())
                                expect({ subject.optionalAttributePublicKeyValuePairsMatch(userDictionary: userDictionary, privateAttributes: []) }).to(match())
                                expect({ subject.sdkSetAttributesKeyValuePairsMatch(userDictionary: userDictionary) }).to(match())
                                expect({ subject.customDictionaryPublicKeyValuePairsMatch(userDictionary: userDictionary, privateAttributes: []) }).to(match())
                            }
                        }
                        it("creates a dictionary without redacted attributes") {
                            [true, false].forEach { (includeFlagConfig) in
                                userDictionary = subject.dictionaryValue(includeFlagConfig: includeFlagConfig, includePrivateAttributes: true, config: config)

                                expect(userDictionary.redactedAttributes).to(beNil())
                            }
                        }
                        it("creates a dictionary with or without a matching flag config") {
                            [true, false].forEach { (includeFlagConfig) in
                                userDictionary = subject.dictionaryValue(includeFlagConfig: includeFlagConfig, includePrivateAttributes: true, config: config)

                                includeFlagConfig ? expect({ subject.flagConfigMatches(userDictionary: userDictionary) }).to(match()) : expect(userDictionary.flagConfig).to(beNil())
                            }
                        }
                    }
                    context("by setting user private attributes to empty") {
                        beforeEach {
                            config = LDConfig()
                            subject = LDUser.stub()
                            subject.privateAttributes = []
                        }
                        it("creates a dictionary with matching key value pairs") {
                            [true, false].forEach { (includeFlagConfig) in
                                userDictionary = subject.dictionaryValue(includeFlagConfig: includeFlagConfig, includePrivateAttributes: true, config: config)

                                expect({ subject.requiredAttributeKeyValuePairsMatch(userDictionary: userDictionary) }).to(match())
                                expect({ subject.optionalAttributePublicKeyValuePairsMatch(userDictionary: userDictionary, privateAttributes: []) }).to(match())
                                expect({ subject.sdkSetAttributesKeyValuePairsMatch(userDictionary: userDictionary) }).to(match())
                                expect({ subject.customDictionaryPublicKeyValuePairsMatch(userDictionary: userDictionary, privateAttributes: []) }).to(match())
                            }
                        }
                        it("creates a dictionary without redacted attributes") {
                            [true, false].forEach { (includeFlagConfig) in
                                userDictionary = subject.dictionaryValue(includeFlagConfig: includeFlagConfig, includePrivateAttributes: true, config: config)
                                expect(userDictionary.redactedAttributes).to(beNil())
                            }
                        }
                        it("creates a dictionary with or without a matching flag config") {
                            [true, false].forEach { (includeFlagConfig) in
                                userDictionary = subject.dictionaryValue(includeFlagConfig: includeFlagConfig, includePrivateAttributes: true, config: config)

                                includeFlagConfig ? expect({ subject.flagConfigMatches(userDictionary: userDictionary) }).to(match())
                                    : expect(userDictionary.flagConfig).to(beNil())
                            }
                        }
                    }
                }
                context("with custom as the private attribute") {
                    context("on a user with no custom dictionary") {
                        context("with a device and os") {
                            beforeEach {
                                config = LDConfig()
                                subject = LDUser.stub()
                                subject.custom = nil
                                subject.privateAttributes = [LDUser.CodingKeys.custom.rawValue]
                            }
                            it("creates a dictionary with matching key value pairs") {
                                [true, false].forEach { (includeFlagConfig) in
                                    userDictionary = subject.dictionaryValue(includeFlagConfig: includeFlagConfig, includePrivateAttributes: true, config: config)

                                    expect({ subject.requiredAttributeKeyValuePairsMatch(userDictionary: userDictionary) }).to(match())
                                    expect({ subject.optionalAttributePublicKeyValuePairsMatch(userDictionary: userDictionary, privateAttributes: []) }).to(match())
                                    expect({ subject.sdkSetAttributesKeyValuePairsMatch(userDictionary: userDictionary) }).to(match())
                                    expect({ subject.customDictionaryContainsOnlySdkSetAttributes(userDictionary: userDictionary) }).to(match())
                                }
                            }
                            it("creates a dictionary without redacted attributes") {
                                [true, false].forEach { (includeFlagConfig) in
                                    userDictionary = subject.dictionaryValue(includeFlagConfig: includeFlagConfig, includePrivateAttributes: true, config: config)

                                    expect(userDictionary.redactedAttributes).to(beNil())
                                }
                            }
                            it("creates a dictionary with or without a matching flag config") {
                                [true, false].forEach { (includeFlagConfig) in
                                    userDictionary = subject.dictionaryValue(includeFlagConfig: includeFlagConfig, includePrivateAttributes: true, config: config)

                                    includeFlagConfig ? expect({ subject.flagConfigMatches(userDictionary: userDictionary) }).to(match())
                                        : expect(userDictionary.flagConfig).to(beNil())
                                }
                            }
                        }
                        context("without a device and os") {
                            beforeEach {
                                config = LDConfig()
                                subject = LDUser.stub()
                                subject.custom = nil
                                subject.operatingSystem = nil
                                subject.device = nil
                                subject.privateAttributes = [LDUser.CodingKeys.custom.rawValue]
                            }
                            it("creates a dictionary with matching key value pairs") {
                                [true, false].forEach { (includeFlagConfig) in
                                    userDictionary = subject.dictionaryValue(includeFlagConfig: includeFlagConfig, includePrivateAttributes: true, config: config)

                                    expect({ subject.requiredAttributeKeyValuePairsMatch(userDictionary: userDictionary) }).to(match())
                                    expect({ subject.optionalAttributePublicKeyValuePairsMatch(userDictionary: userDictionary, privateAttributes: []) }).to(match())
                                }
                            }
                            it("creates a dictionary without redacted attributes") {
                                [true, false].forEach { (includeFlagConfig) in
                                    userDictionary = subject.dictionaryValue(includeFlagConfig: includeFlagConfig, includePrivateAttributes: true, config: config)

                                    expect(userDictionary.redactedAttributes).to(beNil())
                                }
                            }
                            it("creates a dictionary without a custom dictionary") {
                                [true, false].forEach { (includeFlagConfig) in
                                    userDictionary = subject.dictionaryValue(includeFlagConfig: includeFlagConfig, includePrivateAttributes: true, config: config)

                                    expect(userDictionary.customDictionary(includeSdkSetAttributes: true)).to(beNil())
                                }
                            }
                            it("creates a dictionary with or without a matching flag config") {
                                [true, false].forEach { (includeFlagConfig) in
                                    userDictionary = subject.dictionaryValue(includeFlagConfig: includeFlagConfig, includePrivateAttributes: true, config: config)

                                    includeFlagConfig ? expect({ subject.flagConfigMatches(userDictionary: userDictionary) }).to(match())
                                        : expect(userDictionary.flagConfig).to(beNil())
                                }
                            }
                        }
                    }
                    context("on a user with a custom dictionary") {
                        context("without a device and os") {
                            beforeEach {
                                config = LDConfig()
                                subject = LDUser.stub() //The user stub puts device & operating system in both the user attributes and the custom dictionary
                                subject.custom = subject.customWithoutSdkSetAttributes
                                subject.device = nil
                                subject.operatingSystem = nil
                                subject.privateAttributes = [LDUser.CodingKeys.custom.rawValue]
                            }
                            it("creates a dictionary with matching key value pairs") {
                                [true, false].forEach { (includeFlagConfig) in
                                    userDictionary = subject.dictionaryValue(includeFlagConfig: includeFlagConfig, includePrivateAttributes: true, config: config)

                                    expect({ subject.requiredAttributeKeyValuePairsMatch(userDictionary: userDictionary) }).to(match())
                                    expect({ subject.optionalAttributePublicKeyValuePairsMatch(userDictionary: userDictionary, privateAttributes: []) }).to(match())
                                    expect({ subject.sdkSetAttributesDontExist(userDictionary: userDictionary) }).to(match())
                                    expect({ subject.customDictionaryPublicKeyValuePairsMatch(userDictionary: userDictionary, privateAttributes: []) }).to(match())
                                }
                            }
                            it("creates a dictionary without redacted attributes") {
                                [true, false].forEach { (includeFlagConfig) in
                                    userDictionary = subject.dictionaryValue(includeFlagConfig: includeFlagConfig, includePrivateAttributes: true, config: config)

                                    expect(userDictionary.redactedAttributes).to(beNil())
                                }
                            }
                            it("creates a dictionary with or without a matching flag config") {
                                [true, false].forEach { (includeFlagConfig) in
                                    userDictionary = subject.dictionaryValue(includeFlagConfig: includeFlagConfig, includePrivateAttributes: true, config: config)

                                    includeFlagConfig ? expect({ subject.flagConfigMatches(userDictionary: userDictionary) }).to(match())
                                        : expect(userDictionary.flagConfig).to(beNil())
                                }
                            }
                        }
                    }
                }
            }
            context("excluding private attributes") {
                context("with individual private attributes") {
                    context("contained in the config") {
                        beforeEach {
                            config = LDConfig()
                            subject = LDUser.stub()
                            privateAttributes = LDUser.privatizableAttributes + subject.customAttributes!
                        }
                        it("creates a matching dictionary") {
                            privateAttributes.forEach { (attribute) in
                                let privateAttributesForTest = [attribute]
                                config.privateUserAttributes = privateAttributesForTest
                                [true, false].forEach { (includeFlagConfig) in
                                    userDictionary = subject.dictionaryValue(includeFlagConfig: includeFlagConfig, includePrivateAttributes: false, config: config)

                                    //creates a dictionary with matching key value pairs
                                    expect({ subject.requiredAttributeKeyValuePairsMatch(userDictionary: userDictionary) }).to(match())
                                    expect({ subject.optionalAttributePublicKeyValuePairsMatch(userDictionary: userDictionary, privateAttributes: privateAttributesForTest) }).to(match())
                                    expect({ subject.sdkSetAttributesKeyValuePairsMatch(userDictionary: userDictionary) }).to(match())

                                    //creates a dictionary without private keys
                                    expect({ subject.optionalAttributePrivateKeysDontExist(userDictionary: userDictionary, privateAttributes: privateAttributesForTest) }).to(match())

                                    //creates a dictionary with redacted attributes
                                    expect({ subject.optionalAttributePrivateKeysAppearInPrivateAttrsWhenRedacted(userDictionary: userDictionary,
                                                                                                                  privateAttributes: privateAttributesForTest) }).to(match())
                                    expect({ subject.optionalAttributePublicOrMissingKeysDontAppearInPrivateAttrs(userDictionary: userDictionary,
                                                                                                                  privateAttributes: privateAttributesForTest) }).to(match())

                                    //creates a custom dictionary with matching key value pairs, without private keys, and with redacted attributes
                                    if privateAttributesForTest.contains(LDUser.CodingKeys.custom.rawValue) {
                                        expect({ subject.customDictionaryContainsOnlySdkSetAttributes(userDictionary: userDictionary) }).to(match())
                                        expect(subject.privateAttrsContainsCustom(userDictionary: userDictionary)).to(beTrue())
                                    } else {
                                        expect({ subject.customDictionaryPublicKeyValuePairsMatch(userDictionary: userDictionary, privateAttributes: privateAttributesForTest) }).to(match())
                                        expect({ subject.customDictionaryPrivateKeysDontExist(userDictionary: userDictionary, privateAttributes: privateAttributesForTest) }).to(match())

                                        expect({ subject.customPrivateKeysAppearInPrivateAttrsWhenRedacted(userDictionary: userDictionary,
                                                                                                           privateAttributes: privateAttributesForTest) }).to(match())
                                        expect({ subject.customPublicOrMissingKeysDontAppearInPrivateAttrs(userDictionary: userDictionary,
                                                                                                           privateAttributes: privateAttributesForTest) }).to(match())
                                    }

                                    //creates a dictionary with or without matching flag config
                                    includeFlagConfig ? expect({ subject.flagConfigMatches(userDictionary: userDictionary) }).to(match())
                                        : expect(userDictionary.flagConfig).to(beNil())
                                }
                            }
                        }
                    }
                    context("contained in the user") {
                        context("on a populated user") {
                            beforeEach {
                                config = LDConfig()
                                subject = LDUser.stub()
                                privateAttributes = LDUser.privatizableAttributes + subject.customAttributes!
                            }
                            it("creates a matching dictionary") {
                                privateAttributes.forEach { (attribute) in
                                    let privateAttributesForTest = [attribute]
                                    subject.privateAttributes = privateAttributesForTest
                                    [true, false].forEach { (includeFlagConfig) in
                                        userDictionary = subject.dictionaryValue(includeFlagConfig: includeFlagConfig, includePrivateAttributes: false, config: config)

                                        //creates a dictionary with matching key value pairs
                                        expect({ subject.requiredAttributeKeyValuePairsMatch(userDictionary: userDictionary) }).to(match())
                                        expect({ subject.optionalAttributePublicKeyValuePairsMatch(userDictionary: userDictionary, privateAttributes: privateAttributesForTest) }).to(match())
                                        expect({ subject.sdkSetAttributesKeyValuePairsMatch(userDictionary: userDictionary) }).to(match())

                                        //creates a dictionary without private keys
                                        expect({ subject.optionalAttributePrivateKeysDontExist(userDictionary: userDictionary, privateAttributes: privateAttributesForTest) }).to(match())

                                        //creates a dictionary with redacted attributes
                                        expect({ subject.optionalAttributePrivateKeysAppearInPrivateAttrsWhenRedacted(userDictionary: userDictionary,
                                                                                                                      privateAttributes: privateAttributesForTest) }).to(match())
                                        expect({ subject.optionalAttributePublicOrMissingKeysDontAppearInPrivateAttrs(userDictionary: userDictionary,
                                                                                                                      privateAttributes: privateAttributesForTest) }).to(match())

                                        //creates a custom dictionary with matching key value pairs, without private keys, and with redacted attributes
                                        if privateAttributesForTest.contains(LDUser.CodingKeys.custom.rawValue) {
                                            expect({ subject.customDictionaryContainsOnlySdkSetAttributes(userDictionary: userDictionary) }).to(match())
                                            expect(subject.privateAttrsContainsCustom(userDictionary: userDictionary)).to(beTrue())
                                        } else {
                                            expect({ subject.customDictionaryPublicKeyValuePairsMatch(userDictionary: userDictionary,
                                                                                                      privateAttributes: privateAttributesForTest) }).to(match())
                                            expect({ subject.customDictionaryPrivateKeysDontExist(userDictionary: userDictionary,
                                                                                                  privateAttributes: privateAttributesForTest) }).to(match())

                                            expect({ subject.customPrivateKeysAppearInPrivateAttrsWhenRedacted(userDictionary: userDictionary,
                                                                                                               privateAttributes: privateAttributesForTest) }).to(match())
                                            expect({ subject.customPublicOrMissingKeysDontAppearInPrivateAttrs(userDictionary: userDictionary,
                                                                                                               privateAttributes: privateAttributesForTest) }).to(match())
                                        }

                                        //creates a dictionary with or without matching flag config
                                        includeFlagConfig ? expect({ subject.flagConfigMatches(userDictionary: userDictionary) }).to(match())
                                            : expect(userDictionary.flagConfig).to(beNil())
                                    }
                                }
                            }
                        }
                        context("on an empty user") {
                            beforeEach {
                                config = LDConfig()
                                subject = LDUser()
                                privateAttributes = LDUser.privatizableAttributes
                            }
                            it("creates a matching dictionary") {
                                privateAttributes.forEach { (attribute) in
                                    let privateAttributesForTest = [attribute]
                                    subject.privateAttributes = privateAttributesForTest
                                    [true, false].forEach { (includeFlagConfig) in
                                        userDictionary = subject.dictionaryValue(includeFlagConfig: includeFlagConfig, includePrivateAttributes: false, config: config)

                                        //creates a dictionary with matching key value pairs
                                        expect({ subject.requiredAttributeKeyValuePairsMatch(userDictionary: userDictionary) }).to(match())
                                        expect({ subject.optionalAttributeMissingValueKeysDontExist(userDictionary: userDictionary) }).to(match())
                                        expect({ subject.sdkSetAttributesKeyValuePairsMatch(userDictionary: userDictionary) }).to(match())

                                        //creates a dictionary without private keys
                                        expect({ subject.customDictionaryContainsOnlySdkSetAttributes(userDictionary: userDictionary) }).to(match())

                                        //creates a dictionary without redacted attributes
                                        expect(userDictionary.redactedAttributes).to(beNil())

                                        //creates a dictionary with or without matching flag config
                                        includeFlagConfig ? expect({ subject.flagConfigMatches(userDictionary: userDictionary) }).to(match())
                                            : expect(userDictionary.flagConfig).to(beNil())
                                    }
                                }
                            }
                        }
                    }
                }
                context("with all private attributes") {
                    context("using the config flag") {
                        beforeEach {
                            config = LDConfig()
                            config.allUserAttributesPrivate = true
                            subject = LDUser.stub()
                        }
                        it("creates a dictionary with matching key value pairs") {
                            [true, false].forEach { (includeFlagConfig) in
                                userDictionary = subject.dictionaryValue(includeFlagConfig: includeFlagConfig, includePrivateAttributes: false, config: config)

                                expect({ subject.requiredAttributeKeyValuePairsMatch(userDictionary: userDictionary) }).to(match())
                                expect({ subject.optionalAttributePublicKeyValuePairsMatch(userDictionary: userDictionary, privateAttributes: LDUser.privatizableAttributes) }).to(match())
                                expect({ subject.sdkSetAttributesKeyValuePairsMatch(userDictionary: userDictionary) }).to(match())
                            }
                        }
                        it("creates a dictionary without private keys") {
                            [true, false].forEach { (includeFlagConfig) in
                                userDictionary = subject.dictionaryValue(includeFlagConfig: includeFlagConfig, includePrivateAttributes: false, config: config)

                                expect({ subject.optionalAttributePrivateKeysDontExist(userDictionary: userDictionary, privateAttributes: LDUser.privatizableAttributes) }).to(match())
                                expect({ subject.customDictionaryContainsOnlySdkSetAttributes(userDictionary: userDictionary) }).to(match())
                            }
                        }
                        it("creates a dictionary with redacted attributes") {
                            [true, false].forEach { (includeFlagConfig) in
                                userDictionary = subject.dictionaryValue(includeFlagConfig: includeFlagConfig, includePrivateAttributes: false, config: config)

                                expect({ subject.optionalAttributePrivateKeysAppearInPrivateAttrsWhenRedacted(userDictionary: userDictionary,
                                                                                                              privateAttributes: LDUser.privatizableAttributes) }).to(match())
                                expect({ subject.optionalAttributePublicOrMissingKeysDontAppearInPrivateAttrs(userDictionary: userDictionary,
                                                                                                              privateAttributes: LDUser.privatizableAttributes) }).to(match())
                                expect(subject.privateAttrsContainsCustom(userDictionary: userDictionary)).to(beTrue())
                            }
                        }
                        it("creates a dictionary with or without matching flag config") {
                            [true, false].forEach { (includeFlagConfig) in
                                userDictionary = subject.dictionaryValue(includeFlagConfig: includeFlagConfig, includePrivateAttributes: false, config: config)

                                includeFlagConfig ? expect({ subject.flagConfigMatches(userDictionary: userDictionary) }).to(match())
                                    : expect(userDictionary.flagConfig).to(beNil())
                            }
                        }
                    }
                    context("contained in the config") {
                        beforeEach {
                            config = LDConfig()
                            config.privateUserAttributes = LDUser.privatizableAttributes
                            subject = LDUser.stub()
                        }
                        it("creates a dictionary with matching key value pairs") {
                            [true, false].forEach { (includeFlagConfig) in
                                userDictionary = subject.dictionaryValue(includeFlagConfig: includeFlagConfig, includePrivateAttributes: false, config: config)

                                expect({ subject.requiredAttributeKeyValuePairsMatch(userDictionary: userDictionary) }).to(match())
                                expect({ subject.optionalAttributePublicKeyValuePairsMatch(userDictionary: userDictionary, privateAttributes: LDUser.privatizableAttributes) }).to(match())
                                expect({ subject.sdkSetAttributesKeyValuePairsMatch(userDictionary: userDictionary) }).to(match())
                            }
                        }
                        it("creates a dictionary without private keys") {
                            [true, false].forEach { (includeFlagConfig) in
                                userDictionary = subject.dictionaryValue(includeFlagConfig: includeFlagConfig, includePrivateAttributes: false, config: config)

                                expect({ subject.optionalAttributePrivateKeysDontExist(userDictionary: userDictionary, privateAttributes: LDUser.privatizableAttributes) }).to(match())
                                expect({ subject.customDictionaryContainsOnlySdkSetAttributes(userDictionary: userDictionary) }).to(match())
                            }
                        }
                        it("creates a dictionary with redacted attributes") {
                            [true, false].forEach { (includeFlagConfig) in
                                userDictionary = subject.dictionaryValue(includeFlagConfig: includeFlagConfig, includePrivateAttributes: false, config: config)

                                expect({ subject.optionalAttributePrivateKeysAppearInPrivateAttrsWhenRedacted(userDictionary: userDictionary,
                                                                                                              privateAttributes: LDUser.privatizableAttributes) }).to(match())
                                expect({ subject.optionalAttributePublicOrMissingKeysDontAppearInPrivateAttrs(userDictionary: userDictionary,
                                                                                                              privateAttributes: LDUser.privatizableAttributes) }).to(match())
                                expect(subject.privateAttrsContainsCustom(userDictionary: userDictionary)).to(beTrue())
                            }
                        }
                        it("creates a dictionary with or without matching flag config") {
                            [true, false].forEach { (includeFlagConfig) in
                                userDictionary = subject.dictionaryValue(includeFlagConfig: includeFlagConfig, includePrivateAttributes: false, config: config)

                                includeFlagConfig ? expect({ subject.flagConfigMatches(userDictionary: userDictionary) }).to(match())
                                    : expect(userDictionary.flagConfig).to(beNil())
                            }
                        }
                    }
                    context("contained in the user") {
                        beforeEach {
                            config = LDConfig()
                            subject = LDUser.stub()
                            subject.privateAttributes = LDUser.privatizableAttributes
                        }
                        it("creates a dictionary with matching key value pairs") {
                            [true, false].forEach { (includeFlagConfig) in
                                userDictionary = subject.dictionaryValue(includeFlagConfig: includeFlagConfig, includePrivateAttributes: false, config: config)

                                expect({ subject.requiredAttributeKeyValuePairsMatch(userDictionary: userDictionary) }).to(match())
                                expect({ subject.optionalAttributePublicKeyValuePairsMatch(userDictionary: userDictionary, privateAttributes: LDUser.privatizableAttributes) }).to(match())
                                expect({ subject.sdkSetAttributesKeyValuePairsMatch(userDictionary: userDictionary) }).to(match())
                            }
                        }
                        it("creates a dictionary without private keys") {
                            [true, false].forEach { (includeFlagConfig) in
                                userDictionary = subject.dictionaryValue(includeFlagConfig: includeFlagConfig, includePrivateAttributes: false, config: config)

                                expect({ subject.optionalAttributePrivateKeysDontExist(userDictionary: userDictionary, privateAttributes: LDUser.privatizableAttributes) }).to(match())
                                expect({ subject.customDictionaryContainsOnlySdkSetAttributes(userDictionary: userDictionary) }).to(match())
                            }
                        }
                        it("creates a dictionary with redacted attributes") {
                            [true, false].forEach { (includeFlagConfig) in
                                userDictionary = subject.dictionaryValue(includeFlagConfig: includeFlagConfig, includePrivateAttributes: false, config: config)

                                expect({ subject.optionalAttributePrivateKeysAppearInPrivateAttrsWhenRedacted(userDictionary: userDictionary,
                                                                                                              privateAttributes: LDUser.privatizableAttributes) }).to(match())
                                expect({ subject.optionalAttributePublicOrMissingKeysDontAppearInPrivateAttrs(userDictionary: userDictionary,
                                                                                                              privateAttributes: LDUser.privatizableAttributes) }).to(match())
                                expect(subject.privateAttrsContainsCustom(userDictionary: userDictionary)).to(beTrue())
                            }
                        }
                        it("creates a dictionary with or without matching flag config") {
                            [true, false].forEach { (includeFlagConfig) in
                                userDictionary = subject.dictionaryValue(includeFlagConfig: includeFlagConfig, includePrivateAttributes: false, config: config)

                                includeFlagConfig ? expect({ subject.flagConfigMatches(userDictionary: userDictionary) }).to(match()) : expect(userDictionary.flagConfig).to(beNil())
                            }
                        }
                    }
                }
                context("with no private attributes") {
                    context("by setting private attributes to nil") {
                        beforeEach {
                            config = LDConfig()
                            subject = LDUser.stub()
                        }
                        it("creates a dictionary with matching key value pairs") {
                            [true, false].forEach { (includeFlagConfig) in
                                userDictionary = subject.dictionaryValue(includeFlagConfig: includeFlagConfig, includePrivateAttributes: false, config: config)

                                expect({ subject.requiredAttributeKeyValuePairsMatch(userDictionary: userDictionary) }).to(match())
                                expect({ subject.optionalAttributePublicKeyValuePairsMatch(userDictionary: userDictionary, privateAttributes: []) }).to(match())
                                expect({ subject.sdkSetAttributesKeyValuePairsMatch(userDictionary: userDictionary) }).to(match())
                                expect({ subject.customDictionaryPublicKeyValuePairsMatch(userDictionary: userDictionary, privateAttributes: []) }).to(match())
                            }
                        }
                        it("creates a dictionary without redacted attributes") {
                            [true, false].forEach { (includeFlagConfig) in
                                userDictionary = subject.dictionaryValue(includeFlagConfig: includeFlagConfig, includePrivateAttributes: false, config: config)

                                expect(userDictionary.redactedAttributes).to(beNil())
                            }
                        }
                        it("creates a dictionary with or without matching flag config") {
                            [true, false].forEach { (includeFlagConfig) in
                                userDictionary = subject.dictionaryValue(includeFlagConfig: includeFlagConfig, includePrivateAttributes: false, config: config)

                                includeFlagConfig ? expect({ subject.flagConfigMatches(userDictionary: userDictionary) }).to(match())
                                    : expect(userDictionary.flagConfig).to(beNil())
                            }
                        }
                    }
                    context("by setting config private attributes to empty") {
                        beforeEach {
                            config = LDConfig()
                            config.privateUserAttributes = []
                            subject = LDUser.stub()
                        }
                        it("creates a dictionary with matching key value pairs") {
                            [true, false].forEach { (includeFlagConfig) in
                                userDictionary = subject.dictionaryValue(includeFlagConfig: includeFlagConfig, includePrivateAttributes: false, config: config)

                                expect({ subject.requiredAttributeKeyValuePairsMatch(userDictionary: userDictionary) }).to(match())
                                expect({ subject.optionalAttributePublicKeyValuePairsMatch(userDictionary: userDictionary, privateAttributes: []) }).to(match())
                                expect({ subject.sdkSetAttributesKeyValuePairsMatch(userDictionary: userDictionary) }).to(match())
                                expect({ subject.customDictionaryPublicKeyValuePairsMatch(userDictionary: userDictionary, privateAttributes: []) }).to(match())
                            }
                        }
                        it("creates a dictionary without redacted attributes") {
                            [true, false].forEach { (includeFlagConfig) in
                                userDictionary = subject.dictionaryValue(includeFlagConfig: includeFlagConfig, includePrivateAttributes: false, config: config)

                                expect(userDictionary.redactedAttributes).to(beNil())
                            }
                        }
                        it("creates a dictionary with or without matching flag config") {
                            [true, false].forEach { (includeFlagConfig) in
                                userDictionary = subject.dictionaryValue(includeFlagConfig: includeFlagConfig, includePrivateAttributes: false, config: config)

                                includeFlagConfig ? expect({ subject.flagConfigMatches(userDictionary: userDictionary) }).to(match())
                                    : expect(userDictionary.flagConfig).to(beNil())
                            }
                        }
                    }
                    context("by setting user private attributes to empty") {
                        beforeEach {
                            config = LDConfig()
                            subject = LDUser.stub()
                            subject.privateAttributes = []
                        }
                        it("creates a dictionary with matching key value pairs") {
                            [true, false].forEach { (includeFlagConfig) in
                                userDictionary = subject.dictionaryValue(includeFlagConfig: includeFlagConfig, includePrivateAttributes: false, config: config)

                                expect({ subject.requiredAttributeKeyValuePairsMatch(userDictionary: userDictionary) }).to(match())
                                expect({ subject.optionalAttributePublicKeyValuePairsMatch(userDictionary: userDictionary, privateAttributes: []) }).to(match())
                                expect({ subject.sdkSetAttributesKeyValuePairsMatch(userDictionary: userDictionary) }).to(match())
                                expect({ subject.customDictionaryPublicKeyValuePairsMatch(userDictionary: userDictionary, privateAttributes: []) }).to(match())
                            }
                        }
                        it("creates a dictionary without redacted attributes") {
                            [true, false].forEach { (includeFlagConfig) in
                                userDictionary = subject.dictionaryValue(includeFlagConfig: includeFlagConfig, includePrivateAttributes: false, config: config)

                                expect(userDictionary.redactedAttributes).to(beNil())
                            }
                        }
                        it("creates a dictionary with or without matching flag config") {
                            [true, false].forEach { (includeFlagConfig) in
                                userDictionary = subject.dictionaryValue(includeFlagConfig: includeFlagConfig, includePrivateAttributes: false, config: config)

                                includeFlagConfig ? expect({ subject.flagConfigMatches(userDictionary: userDictionary) }).to(match())
                                    : expect(userDictionary.flagConfig).to(beNil())
                            }
                        }
                    }
                }
                context("with custom as the private attribute") {
                    context("on a user with no custom dictionary") {
                        context("with a device and os") {
                            beforeEach {
                                config = LDConfig()
                                subject = LDUser.stub()
                                subject.custom = nil
                                subject.privateAttributes = [LDUser.CodingKeys.custom.rawValue]
                            }
                            it("creates a dictionary with matching key value pairs") {
                                [true, false].forEach { (includeFlagConfig) in
                                    userDictionary = subject.dictionaryValue(includeFlagConfig: includeFlagConfig, includePrivateAttributes: false, config: config)

                                    expect({ subject.requiredAttributeKeyValuePairsMatch(userDictionary: userDictionary) }).to(match())
                                    expect({ subject.optionalAttributePublicKeyValuePairsMatch(userDictionary: userDictionary, privateAttributes: []) }).to(match())
                                    expect({ subject.sdkSetAttributesKeyValuePairsMatch(userDictionary: userDictionary) }).to(match())
                                    expect({ subject.customDictionaryContainsOnlySdkSetAttributes(userDictionary: userDictionary) }).to(match())
                                }
                            }
                            it("creates a dictionary without redacted attributes") {
                                [true, false].forEach { (includeFlagConfig) in
                                    userDictionary = subject.dictionaryValue(includeFlagConfig: includeFlagConfig, includePrivateAttributes: false, config: config)

                                    expect(userDictionary.redactedAttributes).to(beNil())
                                }
                            }
                            it("creates a dictionary with or without matching flag config") {
                                [true, false].forEach { (includeFlagConfig) in
                                    userDictionary = subject.dictionaryValue(includeFlagConfig: includeFlagConfig, includePrivateAttributes: false, config: config)

                                    includeFlagConfig ? expect({ subject.flagConfigMatches(userDictionary: userDictionary) }).to(match())
                                        : expect(userDictionary.flagConfig).to(beNil())
                                }
                            }
                        }
                        context("without a device and os") {
                            beforeEach {
                                config = LDConfig()
                                subject = LDUser.stub()
                                subject.custom = nil
                                subject.operatingSystem = nil
                                subject.device = nil
                                subject.privateAttributes = [LDUser.CodingKeys.custom.rawValue]
                            }
                            it("creates a dictionary with matching key value pairs") {
                                [true, false].forEach { (includeFlagConfig) in
                                    userDictionary = subject.dictionaryValue(includeFlagConfig: includeFlagConfig, includePrivateAttributes: false, config: config)

                                    expect({ subject.requiredAttributeKeyValuePairsMatch(userDictionary: userDictionary) }).to(match())
                                    expect({ subject.optionalAttributePublicKeyValuePairsMatch(userDictionary: userDictionary, privateAttributes: []) }).to(match())
                                }
                            }
                            it("creates a dictionary without redacted attributes") {
                                [true, false].forEach { (includeFlagConfig) in
                                    userDictionary = subject.dictionaryValue(includeFlagConfig: includeFlagConfig, includePrivateAttributes: false, config: config)

                                    expect(userDictionary.redactedAttributes).to(beNil())
                                }
                            }
                            it("creates a dictionary without a custom dictionary") {
                                [true, false].forEach { (includeFlagConfig) in
                                    userDictionary = subject.dictionaryValue(includeFlagConfig: includeFlagConfig, includePrivateAttributes: false, config: config)

                                    expect(userDictionary.customDictionary(includeSdkSetAttributes: true)).to(beNil())
                                }
                            }
                            it("creates a dictionary with or without matching flag config") {
                                [true, false].forEach { (includeFlagConfig) in
                                    userDictionary = subject.dictionaryValue(includeFlagConfig: includeFlagConfig, includePrivateAttributes: false, config: config)

                                    includeFlagConfig ? expect({ subject.flagConfigMatches(userDictionary: userDictionary) }).to(match())
                                        : expect(userDictionary.flagConfig).to(beNil())
                                }
                            }
                        }
                    }
                    context("on a user with a custom dictionary") {
                        context("without a device and os") {
                            beforeEach {
                                config = LDConfig()
                                subject = LDUser.stub() //The user stub puts device & operating system in both the user attributes and the custom dictionary
                                subject.custom = subject.customWithoutSdkSetAttributes
                                subject.device = nil
                                subject.operatingSystem = nil
                                subject.privateAttributes = [LDUser.CodingKeys.custom.rawValue]
                            }
                            it("creates a dictionary with matching key value pairs") {
                                [true, false].forEach { (includeFlagConfig) in
                                    userDictionary = subject.dictionaryValue(includeFlagConfig: includeFlagConfig, includePrivateAttributes: false, config: config)
                                    
                                    expect({ subject.requiredAttributeKeyValuePairsMatch(userDictionary: userDictionary) }).to(match())
                                    expect({ subject.optionalAttributePublicKeyValuePairsMatch(userDictionary: userDictionary, privateAttributes: []) }).to(match())
                                    expect({ subject.sdkSetAttributesDontExist(userDictionary: userDictionary) }).to(match())
                                }
                            }
                            it("creates a dictionary with custom redacted") {
                                [true, false].forEach { (includeFlagConfig) in
                                    userDictionary = subject.dictionaryValue(includeFlagConfig: includeFlagConfig, includePrivateAttributes: false, config: config)

                                    expect(subject.privateAttrsContainsOnlyCustom(userDictionary: userDictionary)) == true
                                }
                            }
                            it("creates a dictionary without a custom dictionary") {
                                [true, false].forEach { (includeFlagConfig) in
                                    userDictionary = subject.dictionaryValue(includeFlagConfig: includeFlagConfig, includePrivateAttributes: false, config: config)

                                    expect(userDictionary.customDictionary(includeSdkSetAttributes: true)).to(beNil())
                                }
                            }
                            it("creates a dictionary with or without matching flag config") {
                                [true, false].forEach { (includeFlagConfig) in
                                    userDictionary = subject.dictionaryValue(includeFlagConfig: includeFlagConfig, includePrivateAttributes: false, config: config)

                                    includeFlagConfig ? expect({ subject.flagConfigMatches(userDictionary: userDictionary) }).to(match())
                                        : expect(userDictionary.flagConfig).to(beNil())
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

extension LDUser {
    static var requiredAttributes: [String] { return [CodingKeys.key.rawValue, CodingKeys.lastUpdated.rawValue, CodingKeys.isAnonymous.rawValue] }
    static var optionalAttributes: [String] { return [CodingKeys.name.rawValue, CodingKeys.firstName.rawValue, CodingKeys.lastName.rawValue, CodingKeys.country.rawValue, CodingKeys.ipAddress.rawValue, CodingKeys.email.rawValue, CodingKeys.avatar.rawValue] }
    var customAttributes: [String]? { return custom?.keys.filter { (key) in !LDUser.sdkSetAttributes.contains(key) } }

    struct MatcherMessages {
        static let valuesDontMatch = "dictionary does not match attribute "
        static let dictionaryShouldNotContain = "dictionary contains attribute "
        static let dictionaryShouldContain = "dictionary does not contain attribute "
        static let attributeListShouldNotContain = "private attributes list contains attribute "
        static let attributeListShouldContain = "private attributes list does not contain attribute "
    }

    fileprivate func requiredAttributeKeyValuePairsMatch(userDictionary: [String: Any]) -> ToMatchResult {
        var messages = [String]()

        LDUser.requiredAttributes.forEach { (attribute) in
            if let message = messageIfMissingValue(in: userDictionary, for: attribute) { messages.append(message) }

            let value = attribute == CodingKeys.lastUpdated.rawValue ? DateFormatter.ldDateFormatter.string(from: lastUpdated) : self.value(forAttribute: attribute)
            if let message = messageIfValueDoesntMatch(value: value, in: userDictionary, for: attribute) { messages.append(message) }
        }

        return messages.isEmpty ? .matched : .failed(reason: messages.joined(separator: ", "))
    }

    fileprivate func optionalAttributePublicKeyValuePairsMatch(userDictionary: [String: Any], privateAttributes: [String]) -> ToMatchResult {
        var messages = [String]()

        LDUser.optionalAttributes.forEach { (attribute) in
            if !privateAttributes.contains(attribute) {
                if let message = messageIfValueDoesntMatch(value: value(forAttribute: attribute), in: userDictionary, for: attribute) { messages.append(message) }
            }
        }

        return messages.isEmpty ? .matched : .failed(reason: messages.joined(separator: ", "))
    }

    fileprivate func optionalAttributePrivateKeysDontExist(userDictionary: [String: Any], privateAttributes: [String]) -> ToMatchResult {
        var messages = [String]()

        LDUser.optionalAttributes.forEach { (attribute) in
            if privateAttributes.contains(attribute) {
                if let message = messageIfAttributeExists(in: userDictionary, for: attribute) { messages.append(message) }
            }
        }

        return messages.isEmpty ? .matched : .failed(reason: messages.joined(separator: ", "))
    }

    fileprivate func optionalAttributeMissingValueKeysDontExist(userDictionary: [String: Any]) -> ToMatchResult {
        var messages = [String]()

        LDUser.optionalAttributes.forEach { (attribute) in
            if value(forAttribute: attribute) == nil {
                if let message = messageIfAttributeExists(in: userDictionary, for: attribute) { messages.append(message) }
            }
        }

        return messages.isEmpty ? .matched : .failed(reason: messages.joined(separator: ", "))
    }

    fileprivate func optionalAttributePrivateKeysAppearInPrivateAttrsWhenRedacted(userDictionary: [String: Any], privateAttributes: [String]) -> ToMatchResult {
        var messages = [String]()

        let redactedAttributes = userDictionary.redactedAttributes

        LDUser.optionalAttributes.forEach { (attribute) in
            if value(forAttribute: attribute) != nil && privateAttributes.contains(attribute) {
                if let message = messageIfRedactedAttributeDoesNotExist(in: redactedAttributes, for: attribute) { messages.append(message) }
            }
        }

        return messages.isEmpty ? .matched : .failed(reason: messages.joined(separator: ", "))
    }

    fileprivate func optionalAttributeKeysDontAppearInPrivateAttrs(userDictionary: [String: Any]) -> ToMatchResult {
        var messages = [String]()

        let redactedAttributes = userDictionary.redactedAttributes

        LDUser.optionalAttributes.forEach { (attribute) in
            if let message = messageIfAttributeExists(in: redactedAttributes, for: attribute) { messages.append(message) }
        }

        return messages.isEmpty ? .matched : .failed(reason: messages.joined(separator: ", "))
    }

    fileprivate func optionalAttributePublicOrMissingKeysDontAppearInPrivateAttrs(userDictionary: [String: Any], privateAttributes: [String]) -> ToMatchResult {
        var messages = [String]()

        let redactedAttributes = userDictionary.redactedAttributes

        LDUser.optionalAttributes.forEach { (attribute) in
            if value(forAttribute: attribute) == nil || !privateAttributes.contains(attribute) {
                if let message = messageIfPublicOrMissingAttributeIsRedacted(in: redactedAttributes, for: attribute) { messages.append(message) }
            }
        }

        return messages.isEmpty ? .matched : .failed(reason: messages.joined(separator: ", "))
    }

    fileprivate func sdkSetAttributesKeyValuePairsMatch(userDictionary: [String: Any]) -> ToMatchResult {
        guard let customDictionary = userDictionary.customDictionary(includeSdkSetAttributes: true)
        else { return .failed(reason: MatcherMessages.dictionaryShouldContain + CodingKeys.custom.rawValue) }

        var messages = [String]()

        LDUser.sdkSetAttributes.forEach { (attribute) in
            if let message = messageIfMissingValue(in: customDictionary, for: attribute) { messages.append(message) }
            if let message = messageIfValueDoesntMatch(value: value(forAttribute: attribute), in: customDictionary, for: attribute) { messages.append(message) }
        }

        return messages.isEmpty ? .matched : .failed(reason: messages.joined(separator: ", "))
    }

    fileprivate func sdkSetAttributesDontExist(userDictionary: [String: Any]) -> ToMatchResult {
        guard let customDictionary = userDictionary.customDictionary(includeSdkSetAttributes: true) else { return .matched }

        var messages = [String]()

        LDUser.sdkSetAttributes.forEach { (attribute) in
            if let message = messageIfAttributeExists(in: customDictionary, for: attribute) { messages.append(message) }
        }

        return messages.isEmpty ? .matched : .failed(reason: messages.joined(separator: ", "))
    }

    fileprivate func customDictionaryContainsOnlySdkSetAttributes(userDictionary: [String: Any]) -> ToMatchResult {
        guard let customDictionary = userDictionary.customDictionary(includeSdkSetAttributes: false)
        else { return .failed(reason: MatcherMessages.dictionaryShouldContain + CodingKeys.custom.rawValue) }

        if !customDictionary.isEmpty { return .failed(reason: MatcherMessages.dictionaryShouldNotContain + CodingKeys.custom.rawValue) }

        return .matched
    }

    fileprivate func privateAttrsContainsCustom(userDictionary: [String: Any]) -> Bool {
        guard let redactedAttributes = userDictionary.redactedAttributes else { return false }
        return redactedAttributes.contains(CodingKeys.custom.rawValue)
    }

    fileprivate func privateAttrsContainsOnlyCustom(userDictionary: [String: Any]) -> Bool {
        guard let redactedAttributes = userDictionary.redactedAttributes, redactedAttributes.contains(CodingKeys.custom.rawValue) else { return false }
        return redactedAttributes.count == 1
    }

    fileprivate func customDictionaryPublicKeyValuePairsMatch(userDictionary: [String: Any], privateAttributes: [String]) -> ToMatchResult {
        guard let custom = custom
        else { return userDictionary.customDictionary(includeSdkSetAttributes: false).isNilOrEmpty ? .matched
            : .failed(reason: MatcherMessages.dictionaryShouldNotContain + CodingKeys.custom.rawValue) }
        guard let customDictionary = userDictionary.customDictionary(includeSdkSetAttributes: false)
        else { return .failed(reason: MatcherMessages.dictionaryShouldContain + CodingKeys.custom.rawValue) }

        var messages = [String]()

        customAttributes?.forEach { (customAttribute) in
            if !privateAttributes.contains(customAttribute) {
                if let message = messageIfMissingValue(in: customDictionary, for: customAttribute) { messages.append(message) }
                if let message = messageIfValueDoesntMatch(value: custom[customAttribute], in: customDictionary, for: customAttribute) { messages.append(message) }
            }
        }

        return messages.isEmpty ? .matched : .failed(reason: messages.joined(separator: ", "))
    }

    fileprivate func customDictionaryPrivateKeysDontExist(userDictionary: [String: Any], privateAttributes: [String]) -> ToMatchResult {
        guard let customDictionary = userDictionary.customDictionary(includeSdkSetAttributes: false)
        else { return .failed(reason: MatcherMessages.dictionaryShouldContain + CodingKeys.custom.rawValue) }

        var messages = [String]()

        customAttributes?.forEach { (customAttribute) in
            if privateAttributes.contains(customAttribute) {
                if let message = messageIfAttributeExists(in: customDictionary, for: customAttribute) { messages.append(message) }
            }
        }

        return messages.isEmpty ? .matched : .failed(reason: messages.joined(separator: ", "))
    }

    fileprivate func customPrivateKeysAppearInPrivateAttrsWhenRedacted(userDictionary: [String: Any], privateAttributes: [String]) -> ToMatchResult {
        guard let custom = custom
        else { return userDictionary.customDictionary(includeSdkSetAttributes: false).isNilOrEmpty ? .matched
            : .failed(reason: MatcherMessages.dictionaryShouldNotContain + CodingKeys.custom.rawValue) }

        var messages = [String]()

        customAttributes?.forEach { (customAttribute) in
            if privateAttributes.contains(customAttribute) && custom[customAttribute] != nil {
                if let message = messageIfRedactedAttributeDoesNotExist(in: userDictionary.redactedAttributes, for: customAttribute) { messages.append(message) }
            }
        }

        return messages.isEmpty ? .matched : .failed(reason: messages.joined(separator: ", "))
    }

    fileprivate func customPublicOrMissingKeysDontAppearInPrivateAttrs(userDictionary: [String: Any], privateAttributes: [String]) -> ToMatchResult {
        guard let custom = custom
        else { return userDictionary.customDictionary(includeSdkSetAttributes: false).isNilOrEmpty ? .matched
            : .failed(reason: MatcherMessages.dictionaryShouldNotContain + CodingKeys.custom.rawValue) }

        var messages = [String]()

        customAttributes?.forEach { (customAttribute) in
            if !privateAttributes.contains(customAttribute) || custom[customAttribute] == nil {
                if let message = messageIfPublicOrMissingAttributeIsRedacted(in: userDictionary.redactedAttributes, for: customAttribute) { messages.append(message) }
            }
        }

        return messages.isEmpty ? .matched : .failed(reason: messages.joined(separator: ", "))
    }

    fileprivate func flagConfigMatches(userDictionary: [String: Any]) -> ToMatchResult {
        let flagConfig = flagStore.featureFlags
        guard let flagConfigDictionary = userDictionary.flagConfig
        else { return .failed(reason: MatcherMessages.dictionaryShouldContain + CodingKeys.config.rawValue) }
        if flagConfig != flagConfigDictionary { return .failed(reason: MatcherMessages.valuesDontMatch + CodingKeys.config.rawValue)}
        return .matched
    }

    private func messageIfMissingValue(in dictionary: [String: Any], for attribute: String) -> String? {
        guard dictionary[attribute] != nil else { return MatcherMessages.dictionaryShouldContain + attribute }
        return nil
    }

    private func messageIfValueDoesntMatch(value: Any?, in dictionary: [String: Any], for attribute: String) -> String? {
        if !AnyComparer.isEqual(value, to: dictionary[attribute], considerNilEqual: true) { return MatcherMessages.valuesDontMatch + attribute }
        return nil
    }

    private func messageIfAttributeExists(in dictionary: [String: Any], for attribute: String) -> String? {
        if dictionary[attribute] != nil { return MatcherMessages.dictionaryShouldNotContain + attribute }
        return nil
    }

    private func messageIfRedactedAttributeDoesNotExist(in redactedAttributes: [String]?, for attribute: String) -> String? {
        guard let redactedAttributes = redactedAttributes else { return MatcherMessages.dictionaryShouldContain + CodingKeys.privateAttributes.rawValue }
        if !redactedAttributes.contains(attribute) { return MatcherMessages.attributeListShouldContain + attribute }
        return nil
    }

    private func messageIfAttributeExists(in redactedAttributes: [String]?, for attribute: String) -> String? {
        guard let redactedAttributes = redactedAttributes else { return nil }
        if redactedAttributes.contains(attribute) { return MatcherMessages.attributeListShouldNotContain + attribute }
        return nil
    }

    private func messageIfPublicOrMissingAttributeIsRedacted(in redactedAttributes: [String]?, for attribute: String) -> String? {
        guard let redactedAttributes = redactedAttributes else { return nil }
        if redactedAttributes.contains(attribute) { return MatcherMessages.attributeListShouldNotContain + attribute }
        return nil
    }

    public func dictionaryValueWithAllAttributes(includeFlagConfig: Bool) -> [String: Any] {
        var dictionary = dictionaryValue(includeFlagConfig: includeFlagConfig, includePrivateAttributes: true, config: LDConfig())
        dictionary[CodingKeys.privateAttributes.rawValue] = privateAttributes
        return dictionary
    }
}

extension AnyComparer {
    static func isEqual(_ value: Any?, to other: Any?, considerNilEqual: Bool = false) -> Bool {
        if value == nil && other == nil { return considerNilEqual }
        return isEqual(value, to: other)
    }
}

extension Dictionary where Key == String, Value == Any {
    fileprivate var redactedAttributes: [String]? { return self[LDUser.CodingKeys.privateAttributes.rawValue] as? [String] }
    fileprivate func customDictionary(includeSdkSetAttributes: Bool) -> [String: Any]? {
        var customDictionary = self[LDUser.CodingKeys.custom.rawValue] as? [String: Any]
        if !includeSdkSetAttributes {
            customDictionary = customDictionary?.filter { (key, _) in !LDUser.sdkSetAttributes.contains(key) }
        }
        return customDictionary
    }
    fileprivate var flagConfig: [String: Any]? { return self[LDUser.CodingKeys.config.rawValue] as? [LDFlagKey: Any] }
}
