//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import XCTest
import FeedStoreChallenge

class FeedStoreChallengeTests: XCTestCase, FeedStoreSpecs {
	
	//  ***********************
	//
	//  Follow the TDD process:
	//
	//  1. Uncomment and run one test at a time (run tests with CMD+U).
	//  2. Do the minimum to make the test pass and commit.
	//  3. Refactor if needed and commit again.
	//
	//  Repeat this process until all tests are passing.
	//
	//  ***********************
	
	func test_retrieve_deliversEmptyOnEmptyCache() throws {
		let sut = try makeSUT()
		
		assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
	}
	
	func test_retrieve_hasNoSideEffectsOnEmptyCache() throws {
		let sut = try makeSUT()

		assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
	}
	
	func test_retrieve_deliversFoundValuesOnNonEmptyCache() throws {
		let sut = try makeSUT()

		assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: sut)
	}
	
	func test_retrieve_hasNoSideEffectsOnNonEmptyCache() throws {
		let sut = try makeSUT()

		assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on: sut)
	}
	
	func test_insert_deliversNoErrorOnEmptyCache() throws {
		let sut = try makeSUT()

		assertThatInsertDeliversNoErrorOnEmptyCache(on: sut)
	}
	
	func test_insert_deliversNoErrorOnNonEmptyCache() throws {
		let sut = try makeSUT()

		assertThatInsertDeliversNoErrorOnNonEmptyCache(on: sut)
	}
	
	func test_insert_overridesPreviouslyInsertedCacheValues() throws {
		let sut = try makeSUT()

		assertThatInsertOverridesPreviouslyInsertedCacheValues(on: sut)
	}
	
	func test_delete_deliversNoErrorOnEmptyCache() throws {
		let sut = try makeSUT()

		assertThatDeleteDeliversNoErrorOnEmptyCache(on: sut)
	}
	
	func test_delete_hasNoSideEffectsOnEmptyCache() throws {
		let sut = try makeSUT()

		assertThatDeleteHasNoSideEffectsOnEmptyCache(on: sut)
	}
	
	func test_delete_deliversNoErrorOnNonEmptyCache() throws {
		let sut = try makeSUT()

		assertThatDeleteDeliversNoErrorOnNonEmptyCache(on: sut)
	}
	
	func test_delete_emptiesPreviouslyInsertedCache() throws {
		let sut = try makeSUT()

		assertThatDeleteEmptiesPreviouslyInsertedCache(on: sut)
	}
	
	func test_storeSideEffects_runSerially() throws {
		let sut = try makeSUT()

		assertThatSideEffectsRunSerially(on: sut)
	}
	
	// - MARK: Helpers
	
	private func makeSUT() throws -> FeedStore {
		clearCoreDataStore()
		let sut = CoreDataFeedStore()
		trackForMemoryLeaks(sut)
		return sut
	}
}

//  ***********************
//
//  Uncomment the following tests if your implementation has failable operations.
//
//  Otherwise, delete the commented out code!
//
//  ***********************

//extension FeedStoreChallengeTests: FailableRetrieveFeedStoreSpecs {
//
//	func test_retrieve_deliversFailureOnRetrievalError() throws {
////		let sut = try makeSUT()
////
////		assertThatRetrieveDeliversFailureOnRetrievalError(on: sut)
//	}
//
//	func test_retrieve_hasNoSideEffectsOnFailure() throws {
////		let sut = try makeSUT()
////
////		assertThatRetrieveHasNoSideEffectsOnFailure(on: sut)
//	}
//
//}

//extension FeedStoreChallengeTests: FailableInsertFeedStoreSpecs {
//
//	func test_insert_deliversErrorOnInsertionError() throws {
////		let sut = try makeSUT()
////
////		assertThatInsertDeliversErrorOnInsertionError(on: sut)
//	}
//
//	func test_insert_hasNoSideEffectsOnInsertionError() throws {
////		let sut = try makeSUT()
////
////		assertThatInsertHasNoSideEffectsOnInsertionError(on: sut)
//	}
//
//}

//extension FeedStoreChallengeTests: FailableDeleteFeedStoreSpecs {
//
//	func test_delete_deliversErrorOnDeletionError() throws {
////		let sut = try makeSUT()
////
////		assertThatDeleteDeliversErrorOnDeletionError(on: sut)
//	}
//
//	func test_delete_hasNoSideEffectsOnDeletionError() throws {
////		let sut = try makeSUT()
////
////		assertThatDeleteHasNoSideEffectsOnDeletionError(on: sut)
//	}
//
//}


XCTAssertEqual failed: ("[FeedStoreChallenge.LocalFeedImage(id: 77C6FFD5-0DDE-466D-A890-B1A2CBB7C216, description: Optional("<FeedImageDB: 0x100c57250> (entity: FeedImageDB; id: 0x15d0bad38027bfd9 <x-coredata://5A1DA095-7B0A-410F-8858-FE31D6EF0DC9/FeedImageDB/p64>; data: {\n    desc = \"any description\";\n    feedDB = \"0x15d0bad396a7bff9 <x-coredata://5A1DA095-7B0A-410F-8858-FE31D6EF0DC9/FeedDB/p26>\";\n    id = \"77C6FFD5-0DDE-466D-A890-B1A2CBB7C216\";\n    location = \"any location\";\n    url = \"http://any-url.com\";\n})"), location: Optional("any location"), url: http://any-url.com),

"FeedStoreChallenge.LocalFeedImage(id: FAD1ED49-8D72-46A4-AF1A-3532249FF668, description: Optional("<FeedImageDB: 0x100c51450> (entity: FeedImageDB; id: 0x15d0bad39fe7bfd9 <x-coredata://5A1DA095-7B0A-410F-8858-FE31D6EF0DC9/FeedImageDB/p63>; data: {\n    desc = \"any description\";\n    feedDB = \"0x15d0bad396a7bff9 <x-coredata://5A1DA095-7B0A-410F-8858-FE31D6EF0DC9/FeedDB/p26>\";\n    id = \"FAD1ED49-8D72-46A4-AF1A-3532249FF668\";\n    location = \"any location\";\n    url = \"http://any-url.com\";\n})"), location: Optional("any location"), url: http://any-url.com)]") is not equal to
"[FeedStoreChallenge.LocalFeedImage(id: 77C6FFD5-0DDE-466D-A890-B1A2CBB7C216, description: Optional("any description"), location: Optional("any location"), url: http://any-url.com), FeedStoreChallenge.LocalFeedImage(id: FAD1ED49-8D72-46A4-AF1A-3532249FF668, description: Optional("any description"), location: Optional("any location"), url: http://any-url.com)]")
