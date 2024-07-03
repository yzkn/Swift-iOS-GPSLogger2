//
//  ErrorView.swift
//  GPSLogger2
//
//  Created by Yu on 2024/07/04.
//

import SwiftUI

struct ErrorView: View {
    var errorText: String
    
    var body: some View {
        Text(errorText)
    }
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView(errorText: "エラーメッセージ")
    }
}
