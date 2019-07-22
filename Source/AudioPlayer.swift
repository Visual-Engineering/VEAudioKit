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

public struct AudioFileItem {
    let file: AVAudioFile
    let delay: Float
    
    // Duration in seconds
    public var duration: Float {
        let lengthSamples = file.length
        let sampleRate = file.processingFormat.sampleRate
        return Float(Double(lengthSamples) / sampleRate) + delay
    }
    
    // Length
    var length: AVAudioFramePosition {
        let delayLength = AVAudioFramePosition(Double(delay) * file.processingFormat.sampleRate)
        return delayLength + file.length
    }
    
    var audioFormat: AVAudioFormat {
        return file.processingFormat
    }
    
    var sampleRate: Float {
        return Float(audioFormat.sampleRate)
    }
    
    init(file: AVAudioFile, delay: Float = 0) {
        self.file = file
        self.delay = delay
    }
}

public class AudioPlayer {
    
    private var engine = AVAudioEngine()
    private var players = [AVAudioPlayerNode]()
    private var schedulers = [Scheduler]()
    
    public private(set) var audioFiles = [AudioFileItem]() {
        didSet {
            guard !audioFiles.isEmpty else { return }
            audioLengthSamples = audioFiles.reduce(0) { (result, audioFileItem) -> AVAudioFramePosition in
                return result > audioFileItem.length ? result : audioFileItem.length
            }
            let item = audioFiles.reduce(audioFiles.first!) { (result, audioFileItem) -> AudioFileItem in
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
        guard let lastRenderTime = players.first!.lastRenderTime, let playerTime = players.first!.playerTime(forNodeTime: lastRenderTime) else {
            return 0
        }
        return playerTime.sampleTime
    }
    private var currentPosition: AVAudioFramePosition = 0
    
    public var delegate: AudioPlayerDelegate?
    
    public var audioFileURLs = [URL]() {
        didSet {
            guard !audioFileURLs.isEmpty else { return }
            audioFileURLs.forEach{
                guard let file = try? AVAudioFile(forReading: $0) else { return }
                audioFiles.append(AudioFileItem(file: file))
            }
        }
    }
    
    public var isPlaying: Bool {
        return players.contains { $0.isPlaying }
    }
    
    public var duration: Float {
        return audioLengthSeconds
    }
    
    public init() { }
    
    public func prepare() {
        guard !audioFiles.isEmpty else {
            fatalError("No audio file set to be played")
        }
        
        audioFiles.forEach(preparePlayer)
        engine.prepare()
        schedulers.forEach(schedule)
    }
    
    private func preparePlayer(for item: AudioFileItem) {
        let player = AVAudioPlayerNode()
        players.append(player)
        let scheduler = Scheduler(player: player, file: item.file)
        schedulers.append(scheduler)
        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: audioFormat)
    }
    
    private func schedule(_ scheduler: Scheduler) {
        scheduler.scheduleFile()
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
        
        guard let startTime = players.first!.lastRenderTime?.sampleTime else { return }
        startTimer()
        players.forEach { $0.play(at: AVAudioTime(sampleTime: startTime, atRate: Double(audioSampleRate))) }
    }
    
    public func pause() {
        guard isPlaying else { return }
        cancelTimer()
        players.forEach { $0.pause() }
    }
    
    public func appendAudioFile(url: URL, delay: Float = 0) {
        let file = try! AVAudioFile(forReading: url)
        let item = AudioFileItem(file: file, delay: delay)
        audioFiles.append(item)
        preparePlayer(for: item)
        engine.prepare()
        guard let scheduler = schedulers.last else { fatalError() }
        schedule(scheduler)
    }
    
    @objc func updatePlayerPosition() {
        currentPosition = currentFrame
        currentPosition = max(min(currentPosition, audioLengthSamples), 0)
        let seconds = Float(currentPosition) / audioSampleRate
        delegate?.playerDidUpdatePosition(seconds: seconds)
    }
    
    private func startTimer() {
        if timer == nil {
            let timer = Timer(timeInterval: 0.5, target: self, selector: #selector(updatePlayerPosition), userInfo: nil, repeats: true)
            RunLoop.current.add(timer, forMode: .common)
            self.timer = timer
        }
    }
    
    private func cancelTimer() {
        timer?.invalidate()
        timer = nil
    }
}
