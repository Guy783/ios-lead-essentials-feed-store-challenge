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
	private let container: NSPersistentContainer
	private let context: NSManagedObjectContext
	
	public init(storeURL: URL? = nil, bundle: Bundle = .main) throws {
		container = try NSPersistentContainer.load(modelName: "FeedStoreDataModel", url: storeURL, in: bundle)
		context = container.newBackgroundContext()
	}
}

// MARK: - Create, Insert and Delete Functions
extension CoreDataFeedStore {
	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		perform { context in
			do {
				try CoreDataFeed.fetch(in: context).map(context.delete)
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
				try CoreDataFeedStore.createCoreDataFeed(for: feed, timestamp: timestamp, context: context)
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
				let coreDataFeed = try CoreDataFeed.fetch(in: context)
				if let localFeedImages = coreDataFeed?.localFeedImages, let timestamp = coreDataFeed?.timestamp {
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
	private static func createCoreDataFeed(for localFeedImages: [LocalFeedImage], timestamp: Date, context: NSManagedObjectContext) throws -> CoreDataFeed {
		try CoreDataFeed.fetch(in: context).map(context.delete)
		
		let coreDataFeed = CoreDataFeed(context: context, timestamp: timestamp)
		coreDataFeed.coreDataFeedImages = CoreDataFeedImage.coreDataFeedImages(from: localFeedImages, withContext: context)
		coreDataFeed.timestamp = timestamp
		return coreDataFeed
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

// MARK: CoreDataFeed Extension
fileprivate extension CoreDataFeed {
	var localFeedImages: [LocalFeedImage]? {
		guard let coreDataFeedImages = coreDataFeedImages.array as? [CoreDataFeedImage] else {
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

// MARK: CoreDataFeedImage Extension
fileprivate extension CoreDataFeedImage {
	static func coreDataFeedImages(from localFeedImages: [LocalFeedImage], withContext context: NSManagedObjectContext) -> NSOrderedSet {
		NSOrderedSet(array: localFeedImages.map { localFeedImage in
			let coreDataFeedImage = CoreDataFeedImage(context: context)
			coreDataFeedImage.id = localFeedImage.id
			coreDataFeedImage.desc = localFeedImage.description
			coreDataFeedImage.location = localFeedImage.location
			coreDataFeedImage.url = localFeedImage.url
			return coreDataFeedImage
		})
	}
}
