//
//  FeedDB+Extensions.swift
//  FeedStoreChallenge
//
//  Created by Tak Mazarura on 23/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import CoreData

extension FeedDB {
	convenience init(context: NSManagedObjectContext, id: UUID = UUID(), timestamp: Date) {
		self.init(context: context)
		self.id = UUID()
		self.timestamp = timestamp
	}
	
	@nonobjc public class func createFetchRequest() -> NSFetchRequest<FeedDB> {
		return NSFetchRequest<FeedDB>(entityName: String(describing: FeedDB.self))
	}
}
