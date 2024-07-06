//
//  ItemService.swift
//  GPSLogger2
//
//  Created by Yu on 2024/07/04.
//

import Foundation
import SwiftData

class Persistance {
    static var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("error create sharedModelContainer: \(error)")
        }
    }()
    
}

actor PersistanceActor: ModelActor {
    let modelContainer: ModelContainer
    let modelExecutor: any ModelExecutor
    
    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        let context = ModelContext(modelContainer)
        modelExecutor = DefaultSerialModelExecutor(modelContext: context)
    }
    
    func save() {
        do {
            try modelContext.save()
        }catch {
            print("error save")
        }
    }

    func insert<T:PersistentModel>(_ value:T) {
        do {
            modelContext.insert(value)
            try modelContext.save()
        }catch {
            print("error insert")
        }
    }
    
    func delete<T:PersistentModel>(_ value:T) {
        do {
            modelContext.delete(value)
            try modelContext.save()
        }catch {
            print("error delete")
        }
    }
    
    func get<T:PersistentModel>(_ descriptor:FetchDescriptor<T>)->[T]? {
        var fetched:[T]?
        do {
            fetched = try modelContext.fetch(descriptor)
        }catch {
            print("error get")
        }
        return fetched
    }
    
}

final class ItemService {
    static let shared = ItemService()
    
    lazy var actor = {
        return PersistanceActor(modelContainer: Persistance.sharedModelContainer)
    }()
    
    func createItem(
        title: String,
        notes: String,
        latitude: Double,
        longitude: Double,
        altitude: Double,
        hAccuracy: Double,
        vAccuracy: Double,
        course: Double,
        speed: Double,
        timestamp: Date,
        address: String
    ) async -> Item {
        let item = Item(
            title: title,
            notes: notes,
            latitude: latitude,
            longitude: longitude,
            altitude: altitude,
            hAccuracy: hAccuracy,
            vAccuracy: vAccuracy,
            course: course,
            speed: speed,
            timestamp: timestamp,
            address: address
        )
        await actor.insert(item)
        return item
    }
    
    func createItemLastSeen() async {
        
        guard let location = await getLastItem() else {
            return
        }
        
        let _ = await createItem(
            title: "",
            notes: "Manual",
            latitude: location.latitude,
            longitude: location.longitude,
            altitude: location.altitude,
            hAccuracy: location.hAccuracy,
            vAccuracy: location.vAccuracy,
            course: location.course,
            speed: location.speed,
            timestamp: location.timestamp,
            address: ""
        )
    }
    
    func searchItems(keyword: String) async -> [Item] {
        let predicate = #Predicate<Item> { item in
            item.title.contains(keyword)
        }

        let descriptor = FetchDescriptor(predicate: predicate)
        return await actor.get(descriptor) ?? []
    }
    
    func getItemById(id: UUID) async -> Item? {
        let predicate = #Predicate<Item> { item in
            item.id == id
        }

        let descriptor = FetchDescriptor(predicate: predicate)
        let items = await actor.get(descriptor)
        guard let items = items,
              let item = items.first
        else {
            return nil
        }
        return item
    }
    
    func getLastItem() async -> Item? {
        var descriptor = FetchDescriptor(sortBy: [SortDescriptor(\Item.timestamp, order: .reverse)])
        descriptor.fetchLimit = 1
        let items = await actor.get(descriptor)
        guard let items = items,
              let item = items.first
        else {
            return nil
        }
        return item
    }
    
    func deleteItem(id: UUID) async -> Bool {
        guard let item = await getItemById(id: id) else { return false }
        await actor.delete(item)
        return true
    }
    
    func deleteAllItems() async -> Bool {
        let items = await getAllItems()
        for item in items {
            await actor.delete(item)
        }
        return true
    }
    
    func updateItemAddress(id: UUID, address: String? = nil, title: String? = nil, notes: String? = nil) async -> Item? {
        guard let item = await getItemById(id: id) else { return nil }
        if let address = address {
            item.address = address
        }
        if let title = title {
            item.title = title
        }
        if let notes = notes {
            item.notes = notes
        }
        await actor.save()
        return item
    }
    
    func getAllItems() async -> [Item] {
        let predicate = #Predicate<Item> { item in
            return true
        }

        let descriptor = FetchDescriptor(predicate: predicate)
        return await actor.get(descriptor) ?? []
    }
    
    func getCsv() async -> String{
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss z"
        
        var csv = "latitude,longitude,altitude,speed,timestamp,address,title,notes"
        csv.append("\n")

        let items = await getAllItems()
        for item in items {
            csv.append(String(item.latitude))
            csv.append(",")
            csv.append(String(item.longitude))
            csv.append(",")
            csv.append(String(item.altitude))
            csv.append(",")
            csv.append(String(item.speed))
            csv.append(",")
            csv.append(df.string(from: item.timestamp))
            csv.append(",")
            csv.append(item.address)
            csv.append(",")
            csv.append(item.title)
            csv.append(",")
            csv.append(item.notes)
            csv.append(",")
            csv.append("\n")
        }
        
        return csv
    }
}
