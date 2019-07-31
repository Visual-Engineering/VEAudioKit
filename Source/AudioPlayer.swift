//
//  AudioPlayer.swift
//  Pods-VEAudioKitDemo
//
//  Created by Pablo Balduz on 10/07/2019.
//

import AVFoundation

public protocol AudioPlayerDelegate {
    func playerDidEnd()
    func playerDidUpdatePosition(seconds: Float)
}

public class AudioPlayer {
    
    private var engine = AVAudioEngine()
    private var players = [SinglePlayer]()
    private var referencePlayer: SinglePlayer? {
        return players.reduce(nil) { (result, player) in
            guard let result = result else { return player }
            return result.audioItem.duration > player.audioItem.duration ? result : player
        }
    }
    
    public private(set) var audioFiles = [AudioItem]() {
        didSet {
            guard !audioFiles.isEmpty else { return }
            audioLengthSamples = audioFiles.reduce(0) { (result, audioFileItem) -> AVAudioFramePosition in
                return result > audioFileItem.length ? result : audioFileItem.length
            }
            let item = audioFiles.reduce(audioFiles.first!) { (result, audioFileItem) -> AudioItem in
                return result.sampleRate < audioFileItem.sampleRate ? result : audioFileItem
            }
            audioFormat = item.audioFormat
            audioSampleRate = item.sampleRate
            audioLengthSeconds = Float(audioLengthSamples) / audioSampleRate
        }
    }
    
    private var audioFormat: AVAudioFormat?
    private var audioSampleRate: Float = 0
    private var audioLengthSeconds: Float = 0
    private var audioLengthSamples: AVAudioFramePosition = 0
    
    var updater: Timer?
    var currentFrame: AVAudioFramePosition {
        guard let frame = referencePlayer?.currentFrame else {
            return 0
        }
        return frame
    }
    var currentPosition: AVAudioFramePosition = 0
    var skipFrame: AVAudioFramePosition = 0
    
    public var delegate: AudioPlayerDelegate?
    
    public var isPlaying: Bool {
        return players.contains { $0.isPlaying }
    }
    
    public var duration: Float {
        return audioLengthSeconds
    }
    
    public init() { }
    
    public func play() {
        guard !isPlaying else { return }
        if !engine.isRunning {
            do {
                try engine.start()
            } catch {
                fatalError("Couldn't start engine")
            }
        }
        
        guard let startTime = referencePlayer?.playbackPosition else { return }
        startTimer()
        players.forEach { $0.play(at: AVAudioTime(sampleTime: startTime, atRate: Double(audioSampleRate))) }
    }
    
    public func pause() {
        guard isPlaying else { return }
        cancelTimer()
        players.forEach { $0.pause() }
    }
    
    public func stop() {
        players.forEach { $0.stop() }
    }
    
    public func reload() {
        skipFrame = 0
        players.forEach { $0.reload() }
    }
    
    public func seek(to second: Float) {
        skipFrame = currentPosition + AVAudioFramePosition(second * audioSampleRate)
        skipFrame = max(min(skipFrame, audioLengthSamples), 0)
        currentPosition = skipFrame
        if currentPosition < audioLengthSamples {
            guard let playbackSampleTime = referencePlayer?.playbackPosition else { return }
            let playbackTime = isPlaying ? AVAudioTime(sampleTime: playbackSampleTime, atRate: Double(audioSampleRate)) : nil
            players.forEach {
                $0.seek(to: skipFrame, playbackTime: playbackTime)
            }
        }
        updatePlayerPosition()
    }
    
    public func appendAudioFile(url: URL, delay: Float = 0) {
        let file = try! AVAudioFile(forReading: url)
        let item = AudioItem(file: file, delay: delay)
        audioFiles.append(item)
        let player = SinglePlayer(engine: engine, audioItem: item)
        players.append(player)
    }
}

// MARK: - AudioPlayerUpdating
extension AudioPlayer: AudioPlayerUpdating {
    
    func updatePlayerPosition() {
        currentPosition = currentFrame + skipFrame
        currentPosition = max(min(currentPosition, audioLengthSamples), 0)
        let seconds = Float(currentPosition) / audioSampleRate
        delegate?.playerDidUpdatePosition(seconds: seconds)
    }
}
