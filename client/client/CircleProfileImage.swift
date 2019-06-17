//
//  CircleProfileImage.swift
//  client
//
//  Created by Nadir Muzaffar on 6/16/19.
//  Copyright © 2019 Nadir Muzaffar. All rights reserved.
//

import SwiftUI

struct CircleProfileImage: View {
    var body: some View {
        Image("turtlerock")
            .resizable()
            .scaledToFit()
            .clipShape(Circle())
    }
}

#if DEBUG
struct CircleProfileImage_Previews : PreviewProvider {
    static var previews: some View {
        CircleProfileImage()
    }
}
#endif
