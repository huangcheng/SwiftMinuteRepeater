    //
    //  WaveRider.swift
    //  MinuteRepeater
    //
    //  Created by Cheng Huang on 2025-12-24.
    //

import Foundation

struct WaveHeader {
    var riff: UInt32
    var fileSize: UInt32
    var wave: UInt32
    var fmt: UInt32
    var fmtSize: UInt32
    var formatTag: UInt16
    var channels: UInt16
    var samplesPerSec: UInt32
    var avgBytesPerSec: UInt32
    var blockAlign: UInt16
    var bitsPerSample: UInt16
    var data: UInt32
    var dataSize: UInt32
}

class WaveRider {
    private var data: Data
    private var size: UInt32
    private var header: WaveHeader?
    private var audioData: [UInt8] = []
    
    init() {
        data = Data()
        size = 0
        header = nil
    }
    
    func append(waveData: Data) {
        if waveData.count < 44 { return }
        let riff = waveData.subdata(in: 0..<4).withUnsafeBytes { $0.load(as: UInt32.self) }.littleEndian
        if riff != 0x46464952 { return } // "RIFF"
        let fileSize = waveData.subdata(in: 4..<8).withUnsafeBytes { $0.load(as: UInt32.self) }.littleEndian
        let wave = waveData.subdata(in: 8..<12).withUnsafeBytes { $0.load(as: UInt32.self) }.littleEndian
        if wave != 0x45564157 { return } // "WAVE"
        
        var position: Int = 12
        var fmtParsed = false
        var dataParsed = false
        var parsedFmtSize: UInt32 = 0
        var parsedFormatTag: UInt16 = 0
        var parsedChannels: UInt16 = 0
        var parsedSamplesPerSec: UInt32 = 0
        var parsedAvgBytesPerSec: UInt32 = 0
        var parsedBlockAlign: UInt16 = 0
        var parsedBitsPerSample: UInt16 = 0
        var parsedDataSize: UInt32 = 0
        var parsedAudioData: [UInt8] = []
        
        while position + 8 <= waveData.count {
            let chunkId = waveData.subdata(in: position..<position+4).withUnsafeBytes { $0.load(as: UInt32.self) }.littleEndian
            let chunkSize = waveData.subdata(in: position+4..<position+8).withUnsafeBytes { $0.load(as: UInt32.self) }.littleEndian
            if chunkId == 0x20746D66 { // "fmt "
                if position + 8 + Int(chunkSize) > waveData.count { return }
                parsedFmtSize = chunkSize
                parsedFormatTag = waveData.subdata(in: position+8..<position+10).withUnsafeBytes { $0.load(as: UInt16.self) }.littleEndian
                parsedChannels = waveData.subdata(in: position+10..<position+12).withUnsafeBytes { $0.load(as: UInt16.self) }.littleEndian
                parsedSamplesPerSec = waveData.subdata(in: position+12..<position+16).withUnsafeBytes { $0.load(as: UInt32.self) }.littleEndian
                parsedAvgBytesPerSec = waveData.subdata(in: position+16..<position+20).withUnsafeBytes { $0.load(as: UInt32.self) }.littleEndian
                parsedBlockAlign = waveData.subdata(in: position+20..<position+22).withUnsafeBytes { $0.load(as: UInt16.self) }.littleEndian
                parsedBitsPerSample = waveData.subdata(in: position+22..<position+24).withUnsafeBytes { $0.load(as: UInt16.self) }.littleEndian
                fmtParsed = true
            } else if chunkId == 0x61746164 { // "data"
                if position + 8 + Int(chunkSize) > waveData.count { return }
                parsedDataSize = chunkSize
                parsedAudioData = Array(waveData[position+8..<position+8+Int(chunkSize)])
                dataParsed = true
                break // assume data is last
            }
            position += 8 + Int(chunkSize)
            if position % 2 == 1 { position += 1 } // align to even
        }
        
        if !fmtParsed || !dataParsed { return }
        
        let parsedHeader = WaveHeader(riff: riff, fileSize: fileSize, wave: wave, fmt: 0x20746D66, fmtSize: parsedFmtSize, formatTag: parsedFormatTag, channels: parsedChannels, samplesPerSec: parsedSamplesPerSec, avgBytesPerSec: parsedAvgBytesPerSec, blockAlign: parsedBlockAlign, bitsPerSample: parsedBitsPerSample, data: 0x61746164, dataSize: parsedDataSize)
        let otherSize = parsedDataSize
        if header == nil {
            header = parsedHeader
            audioData = parsedAudioData
            size = otherSize
        } else {
            guard let selfHeader = header else { return }
            guard selfHeader.formatTag == parsedHeader.formatTag &&
                    selfHeader.channels == parsedHeader.channels &&
                    selfHeader.samplesPerSec == parsedHeader.samplesPerSec &&
                    selfHeader.bitsPerSample == parsedHeader.bitsPerSample else { return }
            audioData.append(contentsOf: parsedAudioData)
            size += otherSize
            header!.dataSize = size
            header!.fileSize = 36 + size
        }
        updateData()
    }
    
    private func updateData() {
        guard let header = header else { return }
        var headerBytes = [UInt8]()
        headerBytes.append(contentsOf: withUnsafeBytes(of: header.riff.littleEndian) { Array($0) })
        headerBytes.append(contentsOf: withUnsafeBytes(of: header.fileSize.littleEndian) { Array($0) })
        headerBytes.append(contentsOf: withUnsafeBytes(of: header.wave.littleEndian) { Array($0) })
        headerBytes.append(contentsOf: withUnsafeBytes(of: header.fmt.littleEndian) { Array($0) })
        headerBytes.append(contentsOf: withUnsafeBytes(of: header.fmtSize.littleEndian) { Array($0) })
        headerBytes.append(contentsOf: withUnsafeBytes(of: header.formatTag.littleEndian) { Array($0) })
        headerBytes.append(contentsOf: withUnsafeBytes(of: header.channels.littleEndian) { Array($0) })
        headerBytes.append(contentsOf: withUnsafeBytes(of: header.samplesPerSec.littleEndian) { Array($0) })
        headerBytes.append(contentsOf: withUnsafeBytes(of: header.avgBytesPerSec.littleEndian) { Array($0) })
        headerBytes.append(contentsOf: withUnsafeBytes(of: header.blockAlign.littleEndian) { Array($0) })
        headerBytes.append(contentsOf: withUnsafeBytes(of: header.bitsPerSample.littleEndian) { Array($0) })
        headerBytes.append(contentsOf: withUnsafeBytes(of: header.data.littleEndian) { Array($0) })
        headerBytes.append(contentsOf: withUnsafeBytes(of: header.dataSize.littleEndian) { Array($0) })
        data = Data(headerBytes + audioData)
    }
    
    func getData() -> Data {
        return Data(data)
    }
}
