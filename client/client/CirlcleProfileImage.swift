//
//  CirlcleProfileImage.swift
//  client
//
//  Created by Nadir Muzaffar on 6/16/19.
//  Copyright © 2019 Nadir Muzaffar. All rights reserved.
//

import SwiftUI

struct CircleProfileImage : View {
    var body: some View {
        Image("profile_picture_demo")
    }
}

#if DEBUG
struct CirlcleProfileImage_Previews : PreviewProvider {
    static var previews: some View {
        CircleProfileImage()
    }
}
#endif
