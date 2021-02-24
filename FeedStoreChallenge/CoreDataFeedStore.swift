//
//  CoreDataFeedStore.swift
//  FeedStoreChallenge
//
//  Created by Tak Mazarura on 18/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import CoreData

public final class CoreDataFeedStore: FeedStore {
	
	lazy var persistentContainer: PersistentContainer = {
		let container = PersistentContainer(name: "FeedStoreDataModel")
		container.loadPersistentStores { description, error in
			if let error = error {
				fatalError("Unable to load persistent stores: \(error)")
			}
		}
		return container
	}()
	
	public init () {}
	
	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
	}
	
	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		let context = self.persistentContainer.newBackgroundContext()
		let coreDataFeed = CoreDataFeed(context: context, timestamp: timestamp)
		let feedSortedAlphabetically = feed.sorted { $0.id.uuidString < $1.id.uuidString }
		self.createCoreDataFeedImages(for: coreDataFeed, from: feedSortedAlphabetically, withContext: context)
		do {
			try context.save()
			completion(nil)
		} catch {
			completion(error)
		}
	}
	
	public func retrieve(completion: @escaping RetrievalCompletion) {
		let request = CoreDataFeed.createFetchRequest()
		do {
			let coreDataFeeds = try persistentContainer.viewContext.fetch(request)
			guard
				let coreDataFeed = coreDataFeeds.first,
				let timestamp = coreDataFeed.timestamp,
				let localFeedImages = coreDataFeed.localFeedImages else {
				completion(.empty)
				return
			}
			let feedSortedAlphabetically = localFeedImages.sorted { $0.id.uuidString < $1.id.uuidString }
			completion(.found(feed: feedSortedAlphabetically, timestamp: timestamp))
		} catch {
			completion(.failure(error))
		}
	}
}

extension CoreDataFeedStore {
	private func createCoreDataFeedImages(for coreDataFeed: CoreDataFeed, from localFeedImages: [LocalFeedImage], withContext context: NSManagedObjectContext) {
		coreDataFeed.coreDataFeedImage = nil
		
		for localFeedImage in localFeedImages {
			let coreDataFeedImage = CoreDataFeedImage(context: context)
			coreDataFeedImage.id = localFeedImage.id
			coreDataFeedImage.feedDescription = localFeedImage.description ?? ""
			coreDataFeedImage.location = localFeedImage.location
			coreDataFeedImage.url = localFeedImage.url
			coreDataFeedImage.coreDataFeed = coreDataFeed
		}
	}
}
