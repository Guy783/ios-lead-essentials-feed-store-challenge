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
	
	private let container: PersistentContainer
	private let context: NSManagedObjectContext
	private let queue = DispatchQueue(label: "\(CoreDataFeedStore.self)Queue",
									  qos: .userInitiated)
	
	public init () {
		container = CoreDataFeedStore.setupContainer()
		context = container.newBackgroundContext()
	}
	
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

// MARK: Helpers
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

extension CoreDataFeedStore {
	@discardableResult
	private static func feedDB(for localFeedImages: [LocalFeedImage], timestamp: Date, context: NSManagedObjectContext) throws -> FeedDB {
		try FeedDB.fetch(in: context).map(context.delete)
		
		let feedDB = FeedDB(context: context, timestamp: timestamp)
		feedDB.feedImageDBs = createFeedDBImages(from: localFeedImages, withContext: context)
		feedDB.timestamp = timestamp
		return feedDB
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
