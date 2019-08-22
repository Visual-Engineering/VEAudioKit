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
    
    public static let PlayerPositionUpdateRate: TimeInterval = 0.1
    
    private var engine = AVAudioEngine()
    private let timeline = Timeline()
    private var players = [SinglePlayer]()
    
    public private(set) var audioFiles = [AudioItem]() {
        didSet {
            guard !audioFiles.isEmpty else { return }
            let item_ = audioFiles.reduce(audioFiles.first!) { (result, audioFileItem) -> AudioItem in
                return result.length > audioFileItem.length ? result : audioFileItem
            }
            audioLengthSamples = item_.length
            audioLengthSeconds = Float(audioLengthSamples) / item_.sampleRate
        }
    }
    
    private var audioLengthSeconds: Float = 0
    private var audioLengthSamples: AVAudioFramePosition = 0
    
    public var delegate: AudioPlayerDelegate?
    
    public var isPlaying: Bool {
        return players.contains { $0.isPlaying }
    }
    
    public var duration: Float {
        return audioLengthSeconds
    }
    
    public init() {
        timeline.delegate = self
    }
    
    public func play() {
        guard !isPlaying else { return }
        if !engine.isRunning {
            do {
                try engine.start()
            } catch {
                fatalError("Couldn't start engine")
            }
        }
        
        timeline.start()
        players.forEach {
            guard let playbackTime = $0.playbackTime else { return }
            $0.play(at: playbackTime)
        }
    }
    
    public func pause() {
        guard isPlaying else { return }
        timeline.pause()
        players.forEach { $0.pause() }
    }
    
    public func stop() {
        timeline.reset()
        players.forEach { $0.stop() }
    }
    
    public func reload() {
        timeline.reset()
        players.forEach { $0.reload() }
    }
    
    public func seek(to second: Float) {
        timeline.seek(Double(second))
        let currrentSecond = max(min(Float(timeline.currentTime), audioLengthSeconds), 0)
        if currrentSecond <= audioLengthSeconds {
            if !isPlaying {
                delegate?.playerDidUpdatePosition(seconds: currrentSecond)
            }
            players.forEach {
                $0.seek(to: currrentSecond, isPlaying: isPlaying)
            }
        }
    }
    
    public func appendAudioFile(url: URL, delay: Float = 0) {
        let file = try! AVAudioFile(forReading: url)
        let item = AudioItem(file: file, delay: delay)
        audioFiles.append(item)
        let player = SinglePlayer(engine: engine, audioItem: item)
        players.append(player)
    }
}

// MARK: - TimelineDelegate
extension AudioPlayer: TimelineDelegate {
    
    var length: TimeInterval {
        return TimeInterval(audioLengthSeconds)
    }
    
    var timeUpdateRate: TimeInterval {
        return AudioPlayer.PlayerPositionUpdateRate
    }
    
    func currentTimeDidUpdate(time: Double) {
        let currentTime = max(min(Float(time), audioLengthSeconds), 0)
        delegate?.playerDidUpdatePosition(seconds: currentTime)
    }
    
    func timelineDidReachEnd() {
        delegate?.playerDidEnd()
    }
}
