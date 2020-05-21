//
//  CircleButtonView.swift
//  client
//
//  Created by Nadir Muzaffar on 5/20/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import SwiftUI

struct CircleButtonView: View {
    @Binding var isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            self.action()
        }) { Circle()
            .frame(width: 16, height: 16)
            .foregroundColor(self.isSelected ? appColor : appColor.opacity(0.5))
        }
    }
}

struct CircleButtonView_Previews: PreviewProvider {
    @State static var isSelected = true
    
    static var previews: some View {
        CircleButtonView(isSelected: CircleButtonView_Previews.$isSelected) {
            print("Button pressed!")
        }
    }
}
