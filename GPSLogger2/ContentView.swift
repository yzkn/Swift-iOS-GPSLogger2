//
//  ContentView.swift
//  GPSLogger2
//
//  Created by Yu on 2024/07/04.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @Query private var items: [Item]
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("GPSLogger2")
            
            List(items) { item in
                VStack(alignment: .leading) {
                    Text(item.title)
                    Text(item.timestamp, style: .date)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self)
}
