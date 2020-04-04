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
            
            HStack {
                HStack(alignment: .center, spacing: 0) {
                    Text(stopWatch.hoursString)
                        .font(.title)
                        .foregroundColor(Color(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)))
                        .frame(width: 40)
                    
                    Text("H")
                        .font(.caption)
                        .fontWeight(.heavy)
                        .foregroundColor(Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)))
                    
                    Text(stopWatch.minutesString)
                        .font(.title)
                        .foregroundColor(Color(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)))
                        .frame(width: 40)
                    
                    Text("M")
                        .font(.caption)
                        .fontWeight(.heavy)
                        .foregroundColor(Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)))
                    
                    Text(stopWatch.secondsString)
                        .font(.title)
                        .foregroundColor(Color(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)))
                        .frame(width: 40)
                    
                    Text("S")
                        .font(.caption)
                        .fontWeight(.heavy)
                        .foregroundColor(Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)))
                }
            }
            
            Spacer()
        }
    }
}

private struct TextView: View {
    @State var text: String

    public var body: some View {
        Text(text)
            .font(.title)
            .foregroundColor(Color(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)))
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        let stopwatch = Stopwatch()
        stopwatch.start()
        return TimerView(stopWatch: stopwatch)
    }
}
