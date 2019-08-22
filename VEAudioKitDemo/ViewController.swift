//
//  ViewController.swift
//  VEAudioKitDemo
//
//  Created by Pablo Balduz on 08/07/2019.
//  Copyright © 2019 Visual Engineering. All rights reserved.
//

import UIKit
import VEAudioKit

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
    
    private let progressBar = UIProgressView()
    private var tracksView: TracksProgressView!
    
    private let counterLabel = UILabel()
    
    private let audioPlayer = AudioPlayer()
    
    private let airplaneAudioURL = Bundle.main.url(forResource: "airplane", withExtension: "mp3")!
    private let dogAudioURL = Bundle.main.url(forResource: "dog", withExtension: "mp3")!
    private let alienSpaceShipURL = Bundle.main.url(forResource: "alien-spaceship", withExtension: "mp3")!
    private let signal8k = Bundle.main.url(forResource: "signal-8khz", withExtension: "wav")!
    private let signal22k = Bundle.main.url(forResource: "signal-22050hz", withExtension: "wav")!
    lazy private var audios = [signal8k, signal22k]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        layout()
        audioPlayerSetup()
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
        [controlsStackView, tracksView, UIView()].forEach(contentStackView.addArrangedSubview)
    }

    private func setup() {
        view.backgroundColor = .orange
        title = "Player"
        
        playButton.addTarget(self, action: #selector(play), for: .touchUpInside)
        skipForwardButton.addTarget(self, action: #selector(plus10), for: .touchUpInside)
        skipBackwardButton.addTarget(self, action: #selector(minus10), for: .touchUpInside)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTrack))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(reset))
        
        progressBar.trackTintColor = .white
        progressBar.progressTintColor = .black
    }
    
    private func audioPlayerSetup() {
        let delay: Float = 0
        audioPlayer.appendAudioFile(url: audios.first!, delay: delay)
        tracksView.addTrack(data: TracksProgressView.TrackData(duration: audioPlayer.audioFiles.first!.duration - delay, startingAt: delay))
        audioPlayer.delegate = self
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
    
    @objc func reset() {
        audioPlayer.reload()
        playButton.isSelected = false
        tracksView.progress = 0
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
}
