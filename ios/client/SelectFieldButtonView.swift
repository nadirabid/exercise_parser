//
//  SelectFieldButtonView.swift
//  client
//
//  Created by Nadir Muzaffar on 7/7/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import SwiftUI

struct SelectFieldButtonView: View {
    @Binding var selected: Bool
    var title: String
    
    var imageName: String {
        if selected {
            return "checkmark.circle.fill"
        }
        
        return "circle"
    }
    
    var body: some View {
        Button(action: { self.selected.toggle() }) {
            HStack {
                Image(systemName: imageName).foregroundColor(appColor)
            
                Text(title).foregroundColor(Color.primary).frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}
