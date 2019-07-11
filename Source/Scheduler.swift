//
//  Scheduler.swift
//  Pods-VEAudioKitDemo
//
//  Created by Pablo Balduz on 10/07/2019.
//

import AVFoundation

internal class Scheduler {
    
    private unowned var player: AVAudioPlayerNode
    private let file: AVAudioFile
    private let startFrames: [AVAudioFramePosition]
    
    private var sampleRate: Double {
        return file.processingFormat.sampleRate
    }
    
    internal init(player: AVAudioPlayerNode, file: AVAudioFile, startFrames: [AVAudioFramePosition] = [0]) {
        self.player = player
        self.file = file
        self.startFrames = startFrames
    }
    
    internal func scheduleFile() {
        startFrames.forEach { frame in
            let time = AVAudioTime(sampleTime: frame, atRate: sampleRate)
            player.scheduleFile(file, at: time, completionHandler: nil)
        }
    }
    
    internal func scheduleFile(startingAt frame: AVAudioFramePosition) {
        let ranges = startFrames.map { $0...AVAudioFramePosition($0 + file.length) }
        
        for case let range in ranges where range.contains(frame) {
            let segmentCount = AVAudioFrameCount(range.lowerBound + file.length - frame)
            let startingFrame = file.length - AVAudioFramePosition(segmentCount)
            player.scheduleSegment(file, startingFrame: startingFrame, frameCount: segmentCount, at: nil, completionHandler: nil)
        }
        
        guard let lastFrame = startFrames.last, frame < lastFrame else { return }
        let updatedFrames = startFrames.filter { $0 > frame }.map { $0 - frame }
        updatedFrames.forEach {
            let time = AVAudioTime(sampleTime: $0, atRate: sampleRate)
            self.player.scheduleFile(self.file, at: time, completionHandler: nil)
        }
    }
}
