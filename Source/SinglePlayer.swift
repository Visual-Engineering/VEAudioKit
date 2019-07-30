//
//  SinglePlayer.swift
//  VEAudioKit
//
//  Created by Pablo Balduz on 25/07/2019.
//

import AVFoundation

protocol SinglePlayerDelegate {
    var currentPosition: AVAudioFramePosition { get }
    var skipFrame: AVAudioFramePosition { get }
}

class SinglePlayer {
    
    private let playerNode: AVAudioPlayerNode
    private let scheduler: Scheduler
    private unowned let engine: AVAudioEngine
    
    private(set) var audioItem: AudioItem
    
    private var audioFormat: AVAudioFormat?
    private var audioSampleRate: Float
    private var audioLengthSamples: AVAudioFramePosition
    private var audioLengthSeconds: Float
    
    var currentFrame: AVAudioFramePosition {
        guard let lastRenderTime = playerNode.lastRenderTime, let playerTime = playerNode.playerTime(forNodeTime: lastRenderTime) else {
            return 0
        }
        return playerTime.sampleTime
    }
    var playbackPosition: AVAudioFramePosition {
        guard let lastRenderTime = playerNode.lastRenderTime else {
            return 0
        }
        return lastRenderTime.sampleTime
    }
    
    var isPlaying: Bool {
        return playerNode.isPlaying
    }
    
    var delegate: SinglePlayerDelegate?
    
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
    
    func seek(to second: Float, playbackTime: AVAudioTime?) {
        guard let currentPosition = delegate?.currentPosition,
            let skipFrame = delegate?.skipFrame else { return }
        playerNode.stop()
        if currentPosition < audioLengthSamples {
            scheduler.scheduleFile(startingAt: skipFrame)
            if let playbackTime = playbackTime {
                playerNode.play(at: playbackTime)
            }
        }
    }
}
