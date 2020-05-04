//
//  AudioPlayer.swift
//  Pods-VEAudioKitDemo
//
//  Created by Pablo Balduz on 10/07/2019.
//

import AVFoundation

public protocol AudioPlayerDelegate {
    func playerDidFinish(_ player: AudioPlayer)
    func player(_ player: AudioPlayer, didUpdatePosition seconds: Float)
    func player(_ player: AudioPlayer, didUpdateVolumeMeter volume: Float)
}

public class AudioPlayer {
    
    public static let PlayerPositionUpdateRate: TimeInterval = 0.1
    
    private var engine = AVAudioEngine()
    private let timeline = Timeline()
    private var players = [SinglePlayer]()
    
    public private(set) var audioFiles = [AudioItem]() {
        didSet {
            updatePlayerLength()
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
    
    public var currentTime: Double {
        return timeline.currentTime
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
        
        connectVolumeTap()
        timeline.start()
        players.forEach {
            guard let playbackTime = $0.playbackTime else { return }
            $0.play(at: playbackTime)
        }
    }
    
    public func pause() {
        guard isPlaying else { return }
        disconnectVolumeTap()
        timeline.pause()
        players.forEach { $0.pause() }
    }
    
    public func stop() {
        disconnectVolumeTap()
        timeline.reset()
        players.forEach { $0.stop() }
    }
    
    public func reload() {
        disconnectVolumeTap()
        timeline.reset()
        players.forEach { $0.reload() }
    }
    
    public func reset() {
        disconnectVolumeTap()
        timeline.reset()
        players.forEach { $0.stop() }
        players = []
        audioFiles = []
    }
    
    public func seek(to second: Float) {
        timeline.seek(Double(second))
        let currentSecond = Float(timeline.currentTime).bounded(by: 0...audioLengthSeconds)
        if currentSecond <= audioLengthSeconds {
            if !isPlaying {
                delegate?.player(self, didUpdatePosition: currentSecond)
            }
            players.forEach {
                $0.seek(to: currentSecond, isPlaying: isPlaying)
            }
        }
    }
    
    public func appendAudioFile(url: URL, delay: Float = 0, volume: Float = 1) {
        let file = try! AVAudioFile(forReading: url)
        let item = AudioItem(file: file, delay: delay, volume: volume)
        audioFiles.append(item)
        let player = SinglePlayer(engine: engine, audioItem: item)
        players.append(player)
    }
    
    public func setDelay(_ delay: Float, for item: AudioItem) {
        pause()
        guard let index = audioFiles.firstIndex(of: item) else { return }
        let player = players[index]
        let item = AudioItem(file: player.audioItem.file, delay: delay, volume: player.audioItem.volume)
        player.audioItem = item
        audioFiles[index] = item
        updatePlayerLength()
        player.seek(to: Float(timeline.currentTime), isPlaying: false)
    }
    
    public func updateVolume(_ volume: Float, for item: AudioItem) {
        guard let index = audioFiles.firstIndex(of: item) else { return }
        let player = players[index]
        player.volume = volume
    }
    
    private func updatePlayerLength() {
        guard !audioFiles.isEmpty else {
            audioLengthSamples = 0
            audioLengthSeconds = 0
            return
        }
        let item = audioFiles.reduce(audioFiles.first!) { (result, audioFileItem) -> AudioItem in
            return result.duration > audioFileItem.duration ? result : audioFileItem
        }
        audioLengthSamples = item.length
        audioLengthSeconds = Float(audioLengthSamples) / item.sampleRate
    }
    
    private func connectVolumeTap() {
        let format = engine.mainMixerNode.outputFormat(forBus: 0)
        engine.mainMixerNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, when in

            guard let channelData = buffer.floatChannelData else {
              return
            }

            let channelDataValue = channelData.pointee
            let channelDataValueArray = stride(from: 0,
                                             to: Int(buffer.frameLength),
                                             by: buffer.stride).map{ channelDataValue[$0] }

            let rms = channelDataValueArray.map { $0 * $0 }.reduce(0, +) / Float(buffer.frameLength)
            let avgPower = 20 * log10(rms)
            let meterLevel = self.scaledPower(power: avgPower)
            self.delegate?.player(self, didUpdateVolumeMeter: meterLevel)
        }
    }
    
    private func scaledPower(power: Float) -> Float {
        guard power.isFinite else { return 0.0 }
        let minDb: Float = -80
        if power < minDb {
        return 0.0
        } else if power >= 1.0 {
        return 1.0
        } else {
            return (abs(minDb) - abs(power)) / abs(minDb)
      }
    }

    func disconnectVolumeTap() {
        engine.mainMixerNode.removeTap(onBus: 0)
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
        let currentTime = Float(time).bounded(by: 0...audioLengthSeconds)
        delegate?.player(self, didUpdatePosition: currentTime)
    }
    
    func timelineDidReachEnd() {
        delegate?.playerDidFinish(self)
    }
}
