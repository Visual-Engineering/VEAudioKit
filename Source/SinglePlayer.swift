//
//  SinglePlayer.swift
//  VEAudioKit
//
//  Created by Pablo Balduz on 25/07/2019.
//

import AVFoundation

class SinglePlayer {
    
    private let playerNode: AVAudioPlayerNode
    private let scheduler: Scheduler
    private unowned let engine: AVAudioEngine
    
    private var audioItem: AudioItem {
        didSet {
            audioFormat = audioItem.audioFormat
            audioSampleRate = audioItem.sampleRate
            audioLengthSamples = audioItem.length
            audioLengthSeconds = Float(audioLengthSamples) / audioSampleRate
        }
    }
    
    private var audioFormat: AVAudioFormat?
    private var audioSampleRate: Float = 0
    private var audioLengthSamples: AVAudioFramePosition = 0
    private var audioLengthSeconds: Float = 0
    
    var currentFrame: AVAudioFramePosition {
        guard let lastRenderTime = playerNode.lastRenderTime, let playerTime = playerNode.playerTime(forNodeTime: lastRenderTime) else {
            return 0
        }
        return playerTime.sampleTime
    }
    var currentPosition: AVAudioFramePosition = 0
    var playbackPosition: AVAudioFramePosition {
        guard let lastRenderTime = playerNode.lastRenderTime else {
            return 0
        }
        return lastRenderTime.sampleTime
    }
    
    var isPlaying: Bool {
        return playerNode.isPlaying
    }
    
    init(engine: AVAudioEngine, audioItem: AudioItem) {
        self.playerNode = AVAudioPlayerNode()
        self.audioItem = audioItem
        self.scheduler = Scheduler(player: playerNode, file: audioItem.file, startFrames: [audioItem.delay * audioItem.sampleRate])
        self.engine = engine
        setup()
    }
    
    private func setup() {
        engine.attach(playerNode)
        engine.connect(playerNode, to: engine.mainMixerNode, format: audioFormat)
        engine.prepare()
        scheduler.scheduleFile()
    }
    
    func play(at time: AVAudioTime? = nil) {
        playerNode.play(at: time)
    }
    
    func pause() {
        playerNode.pause()
    }
    
    func stop() {
        playerNode.stop()
    }
    
    func seek(to second: Float) {
        
    }
}
