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
    
    private var timer: Timer?
    private var currentFrame: AVAudioFramePosition {
        guard let frame = players.first?.currentFrame else {
            return 0
        }
        return frame
    }
    private var currentPosition: AVAudioFramePosition = 0
    
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
        
        guard let startTime = players.first?.playbackPosition else { return }
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
    
    public func scheduleFiles() {
        //        schedulers.forEach(schedule)
    }
    
    public func appendAudioFile(url: URL, delay: Float = 0) {
        let file = try! AVAudioFile(forReading: url)
        let item = AudioItem(file: file, delay: delay)
        audioFiles.append(item)
        players.append(SinglePlayer(engine: engine, audioItem: item))
    }
    
    @objc func updatePlayerPosition() {
        currentPosition = currentFrame
        currentPosition = max(min(currentPosition, audioLengthSamples), 0)
        let seconds = Float(currentPosition) / audioSampleRate
        delegate?.playerDidUpdatePosition(seconds: seconds)
    }
    
    private func startTimer() {
        if timer == nil {
            let timer = Timer(timeInterval: 0.1, target: self, selector: #selector(updatePlayerPosition), userInfo: nil, repeats: true)
            RunLoop.current.add(timer, forMode: .common)
            self.timer = timer
        }
    }
    
    private func cancelTimer() {
        timer?.invalidate()
        timer = nil
    }
}
