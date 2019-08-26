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
    
    private var audioFormat: AVAudioFormat?
    private var audioSampleRate: Float
    private var audioLengthSamples: AVAudioFramePosition
    private var audioLengthSeconds: Float
    
    var audioItem: AudioItem {
        didSet {
            scheduler.startFrames = [AVAudioFramePosition(audioItem.delay * audioItem.sampleRate)]
        }
    }
    
    var playbackTime: AVAudioTime? {
        return playerNode.lastRenderTime
    }
    
    var isPlaying: Bool {
        return playerNode.isPlaying
    }
    
    init(engine: AVAudioEngine, audioItem: AudioItem) {
        self.playerNode = AVAudioPlayerNode()
        self.audioItem = audioItem
        self.scheduler = Scheduler(player: playerNode, file: audioItem.file, startFrames: [audioItem.delay * audioItem.sampleRate])
        self.engine = engine
        self.audioFormat = audioItem.audioFormat
        self.audioSampleRate = audioItem.sampleRate
        self.audioLengthSamples = audioItem.length
        self.audioLengthSeconds = Float(audioLengthSamples) / audioSampleRate
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
    
    func seek(to second: Float, isPlaying: Bool) {
        playerNode.stop()
        let frame = AVAudioFramePosition(second * audioSampleRate)
        scheduler.scheduleFile(startingAt: frame)
        if isPlaying {
            playerNode.play(at: playbackTime)
        }
    }
    
    func reload() {
        playerNode.stop()
        scheduler.scheduleFile()
    }
}
