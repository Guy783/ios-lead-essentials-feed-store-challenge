//
//  CoreDataFeedStore.swift
//  FeedStoreChallenge
//
//  Created by Tak Mazarura on 18/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import CoreData

protocol CoreDataManager {
	var managedObjectContext: NSManagedObjectContext { get set }
	var persistentContainer: PersistentContainer { get set }
}

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
	
	private let queue = DispatchQueue(label: "\(CoreDataFeedStore.self)Queue",
									  qos: .userInitiated)
	
	public init () {}
	
	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		perform { context in
			let feedFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: FeedDB.self))
			let feedBatchDeleteRequest = NSBatchDeleteRequest(fetchRequest: feedFetchRequest)
			do {
				try context.execute(feedBatchDeleteRequest)
				completion(nil)
			} catch {
				completion(error)
			}
		}
	}
	
	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		perform { context in
			do {
				try CoreDataFeedStore.feedDB(for: feed, timestamp: timestamp, context: context)
				try context.save()
				completion(nil)
			} catch {
				completion(error)
			}
		}
	}
	
	public func retrieve(completion: @escaping RetrievalCompletion) {
		perform { context in
			do {
				let feedDBs = try CoreDataFeedStore.fetchFeedDBs(withContext: context)
				guard
					let feedDB = feedDBs.first,
					let timestamp = feedDB.timestamp,
					let localFeedImages = feedDB.localFeedImages else {
					completion(.empty)
					return
				}
				completion(.found(feed: localFeedImages, timestamp: timestamp))
			} catch {
				completion(.failure(error))
			}
		}
	}
}

// MARK
extension CoreDataFeedStore {
	private func perform(action: @escaping (NSManagedObjectContext) -> Void) {
		let context = self.persistentContainer.newBackgroundContext()
		context.perform { [weak self] in
			guard let self = self else { return }
			self.queue.async(flags: .barrier) {
				action(context)
			}
		}
	}
}

extension CoreDataFeedStore {
	@discardableResult
	private static func feedDB(for localFeedImages: [LocalFeedImage], timestamp: Date, context: NSManagedObjectContext) throws -> FeedDB {
		var feedDB: FeedDB
		let feedDBs = try CoreDataFeedStore.fetchFeedDBs(withContext: context)
		
		if let returnedFeedDB = feedDBs.first {
			feedDB = returnedFeedDB
			feedDB = addFeedImagesToFeedDB(for: feedDB, from: localFeedImages, withContext: context)
		} else {
			feedDB = createFeedDB(for: localFeedImages, timestamp: timestamp, context: context)
		}
		
		feedDB.timestamp = timestamp
		return feedDB
	}
	
	private static func createFeedDB(for localFeedImages: [LocalFeedImage], timestamp: Date, context: NSManagedObjectContext) -> FeedDB {
		let coreDataFeed = FeedDB(context: context, timestamp: timestamp)
		coreDataFeed.timestamp = timestamp
		coreDataFeed.feedImageDBs = createFeedDBImages(from: localFeedImages, withContext: context)
		return coreDataFeed
	}
	
	private static func addFeedImagesToFeedDB(for coreDataFeed: FeedDB, from localFeedImages: [LocalFeedImage], withContext context: NSManagedObjectContext) -> FeedDB {
		coreDataFeed.feedImageDBs = nil
		coreDataFeed.feedImageDBs = createFeedDBImages(from: localFeedImages, withContext: context)
		return coreDataFeed
	}
	
	private static func createFeedDBImages(from localFeedImages: [LocalFeedImage], withContext context: NSManagedObjectContext) -> NSOrderedSet {
		NSOrderedSet(array: localFeedImages.map { localFeedImage in
			let coreDataFeedImage = FeedImageDB(context: context)
			coreDataFeedImage.id = localFeedImage.id
			coreDataFeedImage.desc = localFeedImage.description ?? ""
			coreDataFeedImage.location = localFeedImage.location
			coreDataFeedImage.url = localFeedImage.url
			return coreDataFeedImage
		})
	}
}

// MARK: - Fetch Methods
extension CoreDataFeedStore {
	private static func fetchFeedDBs(withContext context: NSManagedObjectContext) throws -> [FeedDB] {
		let request = FeedDB.createFetchRequest()
		return try context.fetch(request)
	}
}


fileprivate extension Set {
	var array: [Element] {
		return Array(self)
	}
}

fileprivate extension FeedDB {
	var localFeedImages: [LocalFeedImage]? {
		guard let coreDataFeedImagesSet = feedImageDBs,
			  let coreDataFeedImages = coreDataFeedImagesSet.array as? [FeedImageDB] else {
			return nil
		}
		return coreDataFeedImages.compactMap { coreDataFeedImage -> LocalFeedImage? in
			guard let id = coreDataFeedImage.id, let url = coreDataFeedImage.url else { return nil }
			let feed = LocalFeedImage(id: id,
									  description: coreDataFeedImage.desc,
									  location: coreDataFeedImage.location,
									  url: url)
			return feed
		}
	}
}
