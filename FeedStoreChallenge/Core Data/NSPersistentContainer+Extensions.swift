//
//  NSPersistentContainer+Extensions.swift
//  FeedStoreChallenge
//
//  Created by Tak Mazarura on 27/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import CoreData

internal extension NSPersistentContainer {
	internal enum LoadingError: Swift.Error {
		case modelNotFound
		case failedToLoadPersistentStores(Swift.Error)
	}
	
	internal static func load(modelName name: String, url: URL? = nil, in bundle: Bundle) throws -> NSPersistentContainer {
		guard let model = NSManagedObjectModel.with(name: name, in: bundle) else {
			throw LoadingError.modelNotFound
		}
		
		let container = NSPersistentContainer(name: name, managedObjectModel: model)
		if let url = url {
			let description = NSPersistentStoreDescription(url: url)
			container.persistentStoreDescriptions = [description]
		}
		
		var loadError: Swift.Error?
		container.loadPersistentStores { loadError = $1 }
		try loadError.map { throw LoadingError.failedToLoadPersistentStores($0) }
		
		return container
	}
}

private extension NSManagedObjectModel {
	static func with(name: String, in bundle: Bundle) -> NSManagedObjectModel? {
		return bundle
			.url(forResource: name, withExtension: "momd")
			.flatMap { NSManagedObjectModel(contentsOf: $0) }
	}
}
