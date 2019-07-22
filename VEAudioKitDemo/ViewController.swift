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
    
    
    private let audioPlayer = AudioPlayer()
    
    private let airplaneAudioURL = Bundle.main.url(forResource: "airplane", withExtension: "mp3")!
    private let dogAudioURL = Bundle.main.url(forResource: "dog", withExtension: "mp3")!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        audioPlayerSetup()
        layout()
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
        tracksView.addTrack(data: TracksProgressView.TrackData(duration: audioPlayer.audioFiles.first!.duration))
        
        [skipBackwardButton, playButton, skipForwardButton].forEach(controlsStackView.addArrangedSubview)
        [controlsStackView, progressBar, tracksView, UIView()].forEach(contentStackView.addArrangedSubview)
    }

    private func setup() {
        view.backgroundColor = .orange
        title = "Player"
        
        playButton.addTarget(self, action: #selector(play), for: .touchUpInside)
        skipForwardButton.addTarget(self, action: #selector(plus10), for: .touchUpInside)
        skipBackwardButton.addTarget(self, action: #selector(minus10), for: .touchUpInside)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTrack))
        
        progressBar.trackTintColor = .white
        progressBar.progressTintColor = .black
    }
    
    private func audioPlayerSetup() {
        audioPlayer.audioFileURLs = [airplaneAudioURL]
        audioPlayer.prepare()
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
        
    }
    
    @objc func minus10() {
        
    }
    
    @objc func addTrack() {
        audioPlayer.appendAudioFile(url: dogAudioURL)
        tracksView.addTrack(data: TracksProgressView.TrackData(duration: audioPlayer.audioFiles.dropFirst().first!.duration))
    }
}

extension ViewController: AudioPlayerDelegate {
    
    func playerDidEnd() {
        
    }
    
    func playerDidUpdatePosition(seconds: Float) {
        let progress = seconds / audioPlayer.duration
        tracksView.progress = progress
        progressBar.progress = progress
    }
}
