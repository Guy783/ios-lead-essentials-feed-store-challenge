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
	private let container: PersistentContainer
	private let context: NSManagedObjectContext
	
	public init () {
		container = CoreDataFeedStore.setupContainer()
		context = container.newBackgroundContext()
	}
	
	static func setupContainer() -> PersistentContainer {
		let container = PersistentContainer(name: "FeedStoreDataModel")
		container.loadPersistentStores { description, error in
			if let error = error {
				fatalError("Unable to load persistent stores: \(error)")
			}
		}
		return container
	}
}

// MARK: - Create, Insert and Delete Functions
extension CoreDataFeedStore {
	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		perform { context in
			do {
				try FeedDB.fetch(in: context).map(context.delete)
				try context.save()
				completion(nil)
			} catch {
				completion(error)
			}
		}
	}
	
	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		perform { context in
			do {
				try CoreDataFeedStore.createFeedDB(for: feed, timestamp: timestamp, context: context)
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
				let feedDB = try FeedDB.fetch(in: context)
				if let localFeedImages = feedDB?.localFeedImages, let timestamp = feedDB?.timestamp {
					completion(.found(feed: localFeedImages, timestamp: timestamp))
				} else {
					completion(.empty)
				}
			} catch {
				completion(.failure(error))
			}
		}
	}
}

// MARK: Creation Methods
extension CoreDataFeedStore {
	@discardableResult
	private static func createFeedDB(for localFeedImages: [LocalFeedImage], timestamp: Date, context: NSManagedObjectContext) throws -> FeedDB {
		try FeedDB.fetch(in: context).map(context.delete)
		
		let feedDB = FeedDB(context: context, timestamp: timestamp)
		feedDB.feedImageDBs = FeedImageDB.feedImageDBs(from: localFeedImages, withContext: context)
		feedDB.timestamp = timestamp
		return feedDB
	}
}

// MARK: Helpers
extension CoreDataFeedStore {
	private func perform(action: @escaping (NSManagedObjectContext) -> Void) {
		context.perform { [weak self] in
			guard let self = self else { return }
			action(self.context)
		}
	}
}

// MARK: FeedDB Extension
fileprivate extension FeedDB {
	var localFeedImages: [LocalFeedImage]? {
		guard let coreDataFeedImages = feedImageDBs.array as? [FeedImageDB] else {
			return nil
		}
		return coreDataFeedImages.compactMap { coreDataFeedImage -> LocalFeedImage? in
			let feed = LocalFeedImage(id: coreDataFeedImage.id,
									  description: coreDataFeedImage.desc,
									  location: coreDataFeedImage.location,
									  url: coreDataFeedImage.url)
			return feed
		}
	}
}

// MARK: FeedImageDB Extension
fileprivate extension FeedImageDB {
	static func feedImageDBs(from localFeedImages: [LocalFeedImage], withContext context: NSManagedObjectContext) -> NSOrderedSet {
		NSOrderedSet(array: localFeedImages.map { localFeedImage in
			let coreDataFeedImage = FeedImageDB(context: context)
			coreDataFeedImage.id = localFeedImage.id
			coreDataFeedImage.desc = localFeedImage.description
			coreDataFeedImage.location = localFeedImage.location
			coreDataFeedImage.url = localFeedImage.url
			return coreDataFeedImage
		})
	}
}
