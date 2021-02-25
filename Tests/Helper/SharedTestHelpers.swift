//
//  SharedTestHelpers.swift
//  Tests
//
//  Created by Tak Mazarura on 25/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import CoreData
import FeedStoreChallenge
import XCTest

func clearCoreDataStore() {
	let persistentContainer = PersistentContainer(name: "FeedStoreDataModel")
	persistentContainer.loadPersistentStores { description, error in
		if let error = error {
			fatalError("Unable to load persistent stores: \(error)")
		}
	}

	let managedObjectContext = persistentContainer.newBackgroundContext()
	let coreDataFeedFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: CoreDataFeed.self))
	let coreDataFeedBatchDeleteRequest = NSBatchDeleteRequest(fetchRequest: coreDataFeedFetchRequest)
	do {
		try managedObjectContext.execute(coreDataFeedBatchDeleteRequest)
	} catch {
		XCTFail("Could not batch delete CoreDataFeedImage's ")
	}
}
