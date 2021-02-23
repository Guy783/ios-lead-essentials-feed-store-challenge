//
//  CoreDataFeed+Extensions.swift
//  FeedStoreChallenge
//
//  Created by Tak Mazarura on 23/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import CoreData

extension CoreDataFeed {
	@nonobjc public class func createFetchRequest() -> NSFetchRequest<CoreDataFeed> {
		return NSFetchRequest<CoreDataFeed>(entityName: String(describing: CoreDataFeed.self))
	}
	
	var localFeedImages: [LocalFeedImage]? {
		guard let coreDataFeedImagesSet = coreDataFeedImage,
			  let coreDataFeedImages = coreDataFeedImagesSet.allObjects as? [CoreDataFeedImage] else {
			return nil
		}
		return coreDataFeedImages.compactMap { coreDataFeedImage -> LocalFeedImage? in
			guard let id = coreDataFeedImage.id, let url = coreDataFeedImage.url else { return nil }
			let feed = LocalFeedImage(id: id,
									  description: coreDataFeedImage.feedDescription,
									  location: coreDataFeedImage.location,
									  url: url)
			return feed
		}
	}
}

fileprivate extension Set {
	var array: [Element] {
		return Array(self)
	}
}
