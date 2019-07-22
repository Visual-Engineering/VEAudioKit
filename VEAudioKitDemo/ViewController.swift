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
    private var tracksView: TracksView!
    
    
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
        
        tracksView = TracksView(trackDuration: audioPlayer.audioFiles.first!.duration)
        
        [skipBackwardButton, playButton, skipForwardButton].forEach(controlsStackView.addArrangedSubview)
        [controlsStackView, progressBar, tracksView, UIView()].forEach(contentStackView.addArrangedSubview)
    }

    private func setup() {
        view.backgroundColor = .orange
        title = "Player"
        
        playButton.addTarget(self, action: #selector(play), for: .touchUpInside)
        skipForwardButton.addTarget(self, action: #selector(plus10), for: .touchUpInside)
        skipBackwardButton.addTarget(self, action: #selector(minus10), for: .touchUpInside)
        
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
        audioPlayer.appendAudioFile(url: dogAudioURL)
        tracksView.addTrack(duration: audioPlayer.audioFiles.dropFirst().first!.duration)
    }
    
    @objc func minus10() {
        
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



class TracksView: UIProgressView {
    
    class Track: UIView {
        
        private let trackView: UIView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = .white
            return view
        }()
        
        var leadingConstraint: NSLayoutConstraint!
        var trailingConstraint: NSLayoutConstraint!
        
        init() {
            super.init(frame: .zero)
            setup()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setup() {
            addSubview(trackView)
            leadingConstraint = trackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0)
            leadingConstraint.isActive = true
            trailingConstraint = trackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0)
            trailingConstraint.isActive = true
            trackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
            trackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        }
    }
    
    private let indicator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        return view
    }()
    
    private let tracksContainer: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        return stackView
    }()
    
    private var indicatorLeadingConstraint: NSLayoutConstraint?
    
    private var tracks = [Track]()
    private var durations = [Float]()
    
    var duration: Float {
        return durations.reduce(0) { (result, duration) -> Float in
            return result > duration ? result : duration
        }
    }
    
    override var progress: Float {
        didSet {
            if let constraint = indicatorLeadingConstraint {
                constraint.constant = CGFloat(progress) * self.frame.width
                UIView.animate(withDuration: 1, delay: 0, options: .curveLinear, animations: { [weak self] in
                    self?.layoutIfNeeded()
                }, completion: nil)
            }
        }
    }
    
    init(trackDuration: Float) {
        super.init(frame: .zero)
        addTrack(duration: trackDuration)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        addSubview(tracksContainer)
        addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.topAnchor.constraint(equalTo: self.topAnchor),
            indicator.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            indicator.widthAnchor.constraint(equalToConstant: 2),
            tracksContainer.topAnchor.constraint(equalTo: self.topAnchor),
            tracksContainer.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            tracksContainer.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            tracksContainer.bottomAnchor.constraint(equalTo: self.bottomAnchor)])
        indicatorLeadingConstraint = indicator.leadingAnchor.constraint(equalTo: self.leadingAnchor)
        indicatorLeadingConstraint?.isActive = true
        
        progressTintColor = .clear
        trackTintColor = .clear
    }
    
    func addTrack(duration: Float, starting: Float = 0) {
        let track = Track()
        track.translatesAutoresizingMaskIntoConstraints = false
        track.backgroundColor = .clear
        track.heightAnchor.constraint(equalToConstant: 30).isActive = true
        tracks.append(track)
        tracksContainer.addArrangedSubview(track)
        durations.append(duration)
        updateTracks()
    }
    
    func updateTracks() {
        for (track, duration) in zip(tracks, durations) {
            track.leadingConstraint.constant = 0
            track.trailingConstraint.constant = -CGFloat((self.duration - duration) / self.duration) * self.frame.width
        }
    }
}
