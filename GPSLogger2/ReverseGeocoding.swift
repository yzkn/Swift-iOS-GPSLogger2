//
//  ReverseGeocoding.swift
//  GPSLogger2
//
//  Created by Yu on 2024/07/08.
//

import Foundation
import SQLite

class ReverseGeocoding {
  var db: Connection
  let townDatastore: TownDatastore
  
  init() {
    let path = Bundle.main.path(forResource: "town", ofType: "db")!
    db = try! Connection(path, readonly: true)
    
    townDatastore = TownDatastore(db: db)
  }
}

class TownDatastore {
  private let towns = Table("town")

  private let city = Expression<String>("city")
  private let town = Expression<String>("town")
  private let lat = Expression<Double>("lat")
  private let lon = Expression<Double>("lon")

  private let db: Connection

  init(db: Connection) {
    self.db = db
  }
    
    func search(lat: Double, lon: Double) -> String? {
        do {
            let stmt = try db.prepare(" SELECT city || town as label , ( abs ( \(lat) - lat ) + abs ( \(lon) - lon ) ) as d FROM town ORDER BY d ASC LIMIT 1; ")
            
            for row in stmt {
                for (index, name) in stmt.columnNames.enumerated() {
                    if(name=="label"){
                        return "\(row[index]!)"
                    }
                }
            }
        } catch {
            print (error)
        }
        
        return nil
    }
}

class Town {
  let city: String
  let town: String
  let lat: Double
  let lon: Double
    
    init(city: String, town: String, lat: Double, lon: Double) {
    self.city = city
    self.town = town
    self.lat = lat
    self.lon = lon
  }
}
