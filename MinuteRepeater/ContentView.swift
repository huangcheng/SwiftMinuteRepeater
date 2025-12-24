    //
    //  ContentView.swift
    //  MinuteRepeater
    //
    //  Created by Cheng Huang on 2025-12-24.
    //

import SwiftUI
import AVFoundation

struct ContentView: View {
    @State var audioPlayer: AVAudioPlayer?
    
    private var hour: Data = NSDataAsset(name: "Audio/hour")!.data
    private var quarter: Data = NSDataAsset(name: "Audio/quarter")!.data
    private var minute: Data = NSDataAsset(name: "Audio/minute")!.data
    
    private func convertCurrentTimeToHQM() -> (Int, Int, Int) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: Date())
        
        let _hour = components.hour ?? 0
        
        var hour = _hour % 12
        
        if hour == 0 && _hour != 0 {
            hour = 12
        }
        
        let minute = components.minute ?? 0
        let quarter = minute / 15
        let minuteRemainder = minute % 15
        
        return (hour, quarter, minuteRemainder)
    }
    
    private func getWaveDataForTime() -> Data {
        let (hourCount, quarterCount, minuteCount) = convertCurrentTimeToHQM()
        
        let rider = WaveRider()
        
        for _ in 0..<hourCount {
            rider.append(waveData: hour)
        }
        
        for _ in 0..<quarterCount {
            rider.append(waveData: quarter)
        }
        
        for _ in 0..<minuteCount {
            rider.append(waveData: minute)
        }
        
        return rider.getData()
    }

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
