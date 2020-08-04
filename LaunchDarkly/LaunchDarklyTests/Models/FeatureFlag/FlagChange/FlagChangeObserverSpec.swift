//
//  FlagObserverSpec.swift
//  LaunchDarklyTests
//
//  Created by Mark Pokorny on 3/6/18. +JMJ
//  Copyright © 2018 Catamorphic Co. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import LaunchDarkly

final class FlagChangeObserverSpec: QuickSpec {
    override func spec() {
        equalsSpec()
    }

    private func equalsSpec() {
        var leftObserver: FlagChangeObserver!
        var rightObserver: FlagChangeObserver!
        var ownerMock: FlagChangeHandlerOwnerMock!
        var otherOwnerMock: FlagChangeHandlerOwnerMock!

        describe("equals") {
            beforeEach {
                ownerMock = FlagChangeHandlerOwnerMock()
                otherOwnerMock = FlagChangeHandlerOwnerMock()
            }
            context("when observers are the same item") {
                beforeEach {
                    leftObserver = FlagChangeObserver(key: DarklyServiceMock.FlagKeys.bool, owner: ownerMock, flagChangeHandler: { _ in })
                }
                it("returns true") {
                    expect(leftObserver) == leftObserver
                }
            }
            context("when observers have the same key and owner") {
                beforeEach {
                    leftObserver = FlagChangeObserver(key: DarklyServiceMock.FlagKeys.bool, owner: ownerMock, flagChangeHandler: { _ in })
                    rightObserver = FlagChangeObserver(key: DarklyServiceMock.FlagKeys.bool, owner: ownerMock, flagChangeHandler: { _ in })
                }
                it("returns true") {
                    expect(leftObserver) == rightObserver
                }
            }
            context("when observers has a different key and the same owner") {
                beforeEach {
                    leftObserver = FlagChangeObserver(key: DarklyServiceMock.FlagKeys.bool, owner: ownerMock, flagChangeHandler: { _ in })
                    rightObserver = FlagChangeObserver(key: DarklyServiceMock.FlagKeys.int, owner: ownerMock, flagChangeHandler: { _ in })
                }
                it("returns false") {
                    expect(leftObserver) != rightObserver
                }
            }
            context("when observers have the same key and different owner") {
                beforeEach {
                    leftObserver = FlagChangeObserver(key: DarklyServiceMock.FlagKeys.bool, owner: ownerMock, flagChangeHandler: { _ in })
                    rightObserver = FlagChangeObserver(key: DarklyServiceMock.FlagKeys.bool, owner: otherOwnerMock, flagChangeHandler: { _ in })
                }
                it("returns false") {
                    expect(leftObserver) != rightObserver
                }
            }
            context("when observers have the same keys and owner") {
                beforeEach {
                    leftObserver = FlagChangeObserver(keys: DarklyServiceMock.FlagKeys.knownFlags, owner: ownerMock, flagCollectionChangeHandler: { _ in })
                    rightObserver = FlagChangeObserver(keys: DarklyServiceMock.FlagKeys.knownFlags, owner: ownerMock, flagCollectionChangeHandler: { _ in })
                }
                it("returns true") {
                    expect(leftObserver) == rightObserver
                }
            }
            context("when observers have different keys and the same owner") {
                beforeEach {
                    leftObserver = FlagChangeObserver(keys: DarklyServiceMock.FlagKeys.knownFlags, owner: ownerMock, flagCollectionChangeHandler: { _ in })
                    rightObserver = FlagChangeObserver(keys: [DarklyServiceMock.FlagKeys.bool], owner: ownerMock, flagCollectionChangeHandler: { _ in })
                }
                it("returns false") {
                    expect(leftObserver) != rightObserver
                }
            }
            context("when observers have the same keys and a different owner") {
                beforeEach {
                    leftObserver = FlagChangeObserver(keys: DarklyServiceMock.FlagKeys.knownFlags, owner: ownerMock, flagCollectionChangeHandler: { _ in })
                    rightObserver = FlagChangeObserver(keys: DarklyServiceMock.FlagKeys.knownFlags, owner: otherOwnerMock, flagCollectionChangeHandler: { _ in })
                }
                it("returns false") {
                    expect(leftObserver) != rightObserver
                }
            }
        }
    }
}

final class FlagChangeHandlerOwnerMock { }
