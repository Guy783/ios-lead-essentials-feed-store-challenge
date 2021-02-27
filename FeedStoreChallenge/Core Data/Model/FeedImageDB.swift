//
//  FeedImageDB.swift
//  FeedStoreChallenge
//
//  Created by Tak Mazarura on 26/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import CoreData
@objc(FeedImageDB)
internal class FeedImageDB: NSManagedObject {
	@NSManaged internal var id: UUID
	@NSManaged internal var desc: String?
	@NSManaged internal var location: String?
	@NSManaged internal var url: URL
	@NSManaged internal var feedDB: FeedDB
}
