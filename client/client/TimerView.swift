//
//  TimerView.swift
//  client
//
//  Created by Nadir Muzaffar on 4/2/20.
//  Copyright © 2020 Nadir Muzaffar. All rights reserved.
//

import SwiftUI

public struct TimerView: View {
    @ObservedObject var stopWatch: Stopwatch

    public var body: some View {
        HStack {
            Spacer()
            
            Text(self.stopWatch.convertCountToTimeString())
                .font(.title)
                .allowsTightening(true)
            
            Spacer()
        }
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        let stopwatch = Stopwatch()
        stopwatch.start()
        return TimerView(stopWatch: stopwatch)
    }
}
