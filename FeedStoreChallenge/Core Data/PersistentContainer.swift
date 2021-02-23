//
//  PersistentContainer.swift
//  FeedStoreChallenge
//
//  Created by Tak Mazarura on 23/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import CoreData

public class PersistentContainer: NSPersistentContainer {
	func saveContext(backgroundContext: NSManagedObjectContext? = nil) {
		let context = backgroundContext ?? viewContext
		guard context.hasChanges else { return }
		do {
			try context.save()
		} catch let error as NSError {
			print("Error: \(error), \(error.userInfo)")
		}
	}
}
