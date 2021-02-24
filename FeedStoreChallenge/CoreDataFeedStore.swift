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
		let context = self.persistentContainer.newBackgroundContext()
		let coreDataFeedFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: CoreDataFeed.self))
			let coreDataFeedBatchDeleteRequest = NSBatchDeleteRequest(fetchRequest: coreDataFeedFetchRequest)
			
			do {
				try context.execute(coreDataFeedBatchDeleteRequest)
				completion(nil)
			} catch {
				completion(error)
			}
	}
	
	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		let context = self.persistentContainer.newBackgroundContext()
		var coreDataFeed: CoreDataFeed
		
		do {
			let request = CoreDataFeed.createFetchRequest()
			let coreDataFeeds = try context.fetch(request)
			
			if let returnedCoreDataFeed = coreDataFeeds.first {
				coreDataFeed = returnedCoreDataFeed
				coreDataFeed = addFeedImagesToCoreDataFeed(for: coreDataFeed, from: feed, withContext: context)
			} else {
				coreDataFeed = createCoreDataFeed(for: feed, timestamp: timestamp, context: context)
			}
			coreDataFeed.timestamp = timestamp
		
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
			completion(.found(feed: localFeedImages, timestamp: timestamp))
		} catch {
			completion(.failure(error))
		}
	}
}

extension CoreDataFeedStore {
	func createCoreDataFeed(for localFeedImages: [LocalFeedImage], timestamp: Date, context: NSManagedObjectContext) -> CoreDataFeed {
		let coreDataFeed = CoreDataFeed(context: context, timestamp: timestamp)
		coreDataFeed.timestamp = timestamp
		coreDataFeed.coreDataFeedImage = createCoreDataFeedImages(from: localFeedImages, withContext: context)
		return coreDataFeed
	}
	
	private func addFeedImagesToCoreDataFeed(for coreDataFeed: CoreDataFeed, from localFeedImages: [LocalFeedImage], withContext context: NSManagedObjectContext)  -> CoreDataFeed {
		coreDataFeed.coreDataFeedImage = nil
		coreDataFeed.coreDataFeedImage = createCoreDataFeedImages(from: localFeedImages, withContext: context)
		return coreDataFeed
	}
	
	private func createCoreDataFeedImages(from localFeedImages: [LocalFeedImage], withContext context: NSManagedObjectContext) -> NSOrderedSet {
		NSOrderedSet(array: localFeedImages.map { localFeedImage in
			let coreDataFeedImage = CoreDataFeedImage(context: context)
			coreDataFeedImage.id = localFeedImage.id
			coreDataFeedImage.feedDescription = localFeedImage.description ?? ""
			coreDataFeedImage.location = localFeedImage.location
			coreDataFeedImage.url = localFeedImage.url
			return coreDataFeedImage
		})
	}
}
