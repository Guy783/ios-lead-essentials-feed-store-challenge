//
//  XCTest+MemoryLeakTracking.swift
//  Tests
//
//  Created by Tak Mazarura on 25/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import Foundation

extension XCTestCase {
	public func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
		addTeardownBlock { [weak instance] in
			XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
		}
	}
}
