//
//  AudioRecorder.swift
//  VEAudioKit
//
//  Created by Pablo Balduz on 28/08/2019.
//

import AVFoundation

public protocol AudioRecorderDelegate {
    func recordingDidFinish(successfully flag: Bool)
    func recorderDidUpdatePower(_ power: Float)
}

public class AudioRecorder: NSObject {
    
    public var delegate: AudioRecorderDelegate?
    
    public var audioFileName = "recording"
    public var audioSampleRate = 12000
    public var audioQuality: AVAudioQuality = .high
    
    public var recordingFile: AVAudioFile? {
        let url = documentsDirectory.appendingPathComponent("\(audioFileName).m4a")
        return try? AVAudioFile(forReading: url)
    }
    
    public var isRecording: Bool {
        guard let recorder = recorder else { return false }
        return recorder.isRecording
    }
    
    private var recorder: AVAudioRecorder!
    private let timer = Timer()
    
    public override init() {
        super.init()
        timer.delegate = self
    }
    
    public func record() {
        let audiofilePath = documentsDirectory.appendingPathComponent("\(audioFileName).m4a")
        do {
            recorder = try AVAudioRecorder(url: audiofilePath, settings: recordingSettings)
            recorder.delegate = self
            recorder.isMeteringEnabled = true
            recorder.record()
            timer.start()
        } catch {
            finishRecording(success: false)
        }
    }
    
    public func stop() {
        finishRecording(success: true)
    }
}

private extension AudioRecorder {
    
    var documentsDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths.first!
    }
    
    var recordingSettings: [String: Any] {
        return [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: audioSampleRate,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: audioQuality.rawValue]
    }
    
    func finishRecording(success: Bool) {
        recorder.stop()
        timer.stop()
        recorder = nil
        delegate?.recordingDidFinish(successfully: success)
    }
}

extension AudioRecorder: AVAudioRecorderDelegate {
    
    public func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
}

extension AudioRecorder: TimerDelegate {
    
    func timeDidUpdate(timeElapsedSinceLastStart time: NanoSeconds) {
        guard let recorder = recorder else { return }
        if recorder.isRecording {
            recorder.updateMeters()
            let averagePower = recorder.averagePower(forChannel: 0)
            let normalizedPower = pow(10, averagePower / 20)
            delegate?.recorderDidUpdatePower(normalizedPower)
        }
    }
}
