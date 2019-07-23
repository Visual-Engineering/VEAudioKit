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
    private var player = AVAudioPlayerNode()
    private var scheduler: Scheduler!
    
    private var audioFile: AVAudioFile? {
        didSet {
            if let audioFile = audioFile {
                audioLengthSamples = audioFile.length
                audioFormat = audioFile.processingFormat
                audioSampleRate = Float(audioFormat?.sampleRate ?? 44100)
                audioLengthSeconds = Float(audioLengthSamples) / audioSampleRate
            }
        }
    }
    
    private var audioFormat: AVAudioFormat?
    private var audioSampleRate: Float = 0
    private var audioLengthSeconds: Float = 0
    private var audioLengthSamples: AVAudioFramePosition = 0
    
    private var timer: Timer?
    private var currentFrame: AVAudioFramePosition {
        guard let lastRenderTime = player.lastRenderTime, let playerTime = player.playerTime(forNodeTime: lastRenderTime) else {
            return 0
        }
        return playerTime.sampleTime
    }
    private var currentPosition: AVAudioFramePosition = 0
    
    public var delegate: AudioPlayerDelegate?
    
    public var audioFileURL: URL? {
        didSet {
            if let url = audioFileURL {
                audioFile = try? AVAudioFile(forReading: url)
            }
        }
    }
    
    public var isPlaying: Bool {
        return player.isPlaying
    }
    
    public var duration: Float {
        return audioLengthSeconds
    }
    
    public init() { }
    
    public func prepare() {
        guard let audioFile = audioFile else {
            fatalError("No audio file set to be played")
        }
        
        scheduler = Scheduler(player: player, file: audioFile)
        
        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: audioFormat)
        engine.prepare()
        
        scheduler.scheduleFile()
    }
    
    public func play() {
        guard !player.isPlaying else { return }
        
        if !engine.isRunning {
            do {
                try engine.start()
            } catch {
                fatalError("Couldn't start engine")
            }
        }
        
        guard let startTime = player.lastRenderTime?.sampleTime else { return }
        startTimer()
        player.play(at: AVAudioTime(sampleTime: startTime, atRate: Double(audioSampleRate)))
    }
    
    public func pause() {
        guard player.isPlaying else { return }
        cancelTimer()
        player.pause()
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
