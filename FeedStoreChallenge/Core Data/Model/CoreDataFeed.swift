//
//  CoreDataFeed+Extensions.swift
//  FeedStoreChallenge
//
//  Created by Tak Mazarura on 23/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import CoreData

@objc(CoreDataFeed)
internal class CoreDataFeed: NSManagedObject {
	@NSManaged internal var timestamp: Date
	@NSManaged internal var coreDataFeedImages: NSOrderedSet
}

// MARK: - Convenience init
extension CoreDataFeed {
	convenience init(context: NSManagedObjectContext, timestamp: Date) {
		self.init(context: context)
		self.timestamp = timestamp
	}
}

// MARK: - Fetch
extension CoreDataFeed {
	private static func createFetchRequest() -> NSFetchRequest<CoreDataFeed> {
		return NSFetchRequest<CoreDataFeed>(entityName: String(describing: CoreDataFeed.self))
	}
	
	internal static func fetch(in context: NSManagedObjectContext) throws -> CoreDataFeed? {
		let request = CoreDataFeed.createFetchRequest()
		return try context.fetch(request).first
	}
}
