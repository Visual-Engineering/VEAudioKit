//
//  ViewController.swift
//  VEAudioKitDemo
//
//  Created by Pablo Balduz on 08/07/2019.
//  Copyright © 2019 Visual Engineering. All rights reserved.
//

import UIKit
import VEAudioKit
import AVFoundation

class ViewController: UIViewController {
    
    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        stackView.spacing = 10
        return stackView
    }()
    
    private let controlsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private let playButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "play"), for: .normal)
        button.setImage(UIImage(named: "pause"), for: .selected)
        return button
    }()
    
    private let skipForwardButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "plus-10"), for: .normal)
        return button
    }()
    
    private let skipBackwardButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "minus-10"), for: .normal)
        return button
    }()
    
    private let editButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Edit", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        return button
    }()
    
    private let recordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start recording", for: .normal)
        button.setTitle("Stop recording", for: .selected)
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.black, for: .selected)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        button.tintColor = .clear
        return button
    }()
    
    private let resetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Reset audio player", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        return button
    }()
    
    private let progressBar = UIProgressView()
    private var tracksView: TracksProgressView!
    
    private let counterLabel = UILabel()
    
    private let audioPlayer = AudioPlayer()
    private let audioRecorder = AudioRecorder()
    
    private let airplaneAudioURL = Bundle.main.url(forResource: "airplane", withExtension: "mp3")!
    private let dogAudioURL = Bundle.main.url(forResource: "dog", withExtension: "mp3")!
    private let alienSpaceShipURL = Bundle.main.url(forResource: "alien-spaceship", withExtension: "mp3")!
    private let signal8k = Bundle.main.url(forResource: "signal-8khz", withExtension: "wav")!
    private let signal22k = Bundle.main.url(forResource: "signal-22050hz", withExtension: "wav")!
    lazy private var audios = [signal8k, signal22k]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        layout()
        audioKitSetup()
        setup()
    }
    
    private func layout() {
        view.addSubview(contentStackView)
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor)])
        
        tracksView = TracksProgressView()

        [skipBackwardButton, playButton, skipForwardButton].forEach(controlsStackView.addArrangedSubview)
        [controlsStackView, tracksView, editButton, recordButton, resetButton, UIView()].forEach(contentStackView.addArrangedSubview)
    }

    private func setup() {
        view.backgroundColor = .orange
        title = "Player"
        
        playButton.addTarget(self, action: #selector(play), for: .touchUpInside)
        skipForwardButton.addTarget(self, action: #selector(plus10), for: .touchUpInside)
        skipBackwardButton.addTarget(self, action: #selector(minus10), for: .touchUpInside)
        editButton.addTarget(self, action: #selector(editTrack), for: .touchUpInside)
        recordButton.addTarget(self, action: #selector(startRecording), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(resetAudioPlayer), for: .touchUpInside)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTrack))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Reload", style: .plain, target: self, action: #selector(reload))
        
        progressBar.trackTintColor = .white
        progressBar.progressTintColor = .black
    }
    
    private func audioKitSetup() {
//        let delay: Float = 0
//        audioPlayer.appendAudioFile(url: audios.first!, delay: delay)
//        tracksView.addTrack(data: TracksProgressView.TrackData(duration: audioPlayer.audioFiles.first!.duration - delay, startingAt: delay))
        audioPlayer.delegate = self
        audioRecorder.delegate = self
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord)
            try audioSession.overrideOutputAudioPort(.speaker)
        } catch {
            print("Error configuring audio session")
        }
    }
    
    @objc func play() {
        playButton.isSelected = !playButton.isSelected
        
        if !audioPlayer.isPlaying {
            audioPlayer.play()
        } else {
            audioPlayer.pause()
        }
    }
    
    @objc func plus10() {
        audioPlayer.seek(to: 3)
    }
    
    @objc func minus10() {
        audioPlayer.seek(to: -3)
    }
    
    @objc func addTrack() {
        let index = audioPlayer.audioFiles.count
        guard index < audios.count else { return }
        let delay: Float = Float(index * 3)
        audioPlayer.appendAudioFile(url: audios[index], delay: delay)
        tracksView.addTrack(data: TracksProgressView.TrackData(duration: audioPlayer.audioFiles[index].duration - delay, startingAt: delay))
    }
    
    @objc func reload() {
        audioPlayer.reload()
        playButton.isSelected = false
        tracksView.progress = 0
    }
    
    @objc func editTrack() {
        playButton.isSelected = false
        let index = 0
        let delay: Float = 6
        audioPlayer.setDelay(delay, for: audioPlayer.audioFiles[index])
        tracksView.tracksData[index] = TracksProgressView.TrackData(duration: audioPlayer.audioFiles[index].duration - delay, startingAt: delay)
        playerDidUpdatePosition(seconds: Float(audioPlayer.currentTime))
    }
    
    @objc func startRecording() {
        if !audioRecorder.isRecording {
            recordButton.isSelected = true
            audioRecorder.record()
        } else {
            recordButton.isSelected = false
            audioRecorder.stop()
        }
    }
    
    @objc func resetAudioPlayer() {
        audioPlayer.reset()
        tracksView.clearTracks()
        playButton.isSelected = false
    }
}

extension ViewController: AudioPlayerDelegate {
    
    func playerDidEnd() {
        play()
    }
    
    func playerDidUpdatePosition(seconds: Float) {
        let progress = seconds / audioPlayer.duration
        tracksView.progress = progress
        progressBar.progress = progress
    }
    
    func playerDidUpdateVolumeMeter(_ value: Float) {
        print("Volume meter: \(value)")
    }
}

extension ViewController: AudioRecorderDelegate {
    
    func recordingDidFinish(successfully flag: Bool) {
        if flag {
            guard let file = audioRecorder.recordingFile else { return }
            audioPlayer.appendAudioFile(url: file.url)
            let duration = audioPlayer.audioFiles.last!.duration
            tracksView.addTrack(data: TracksProgressView.TrackData(duration: duration))
        } else {
            recordButton.isSelected = false
            print("Recording failed")
        }
    }
    
    func recorderDidUpdatePower(_ power: Float) {
        print("Power: \(power)")
    }
    
    func recorderDidUpdateTime(_ seconds: Float) {
        print("\(floor(seconds)) seconds")
    }
}
