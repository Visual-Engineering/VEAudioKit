//
//  TracksView.swift
//  VEAudioKitDemo
//
//  Created by Pablo Balduz on 22/07/2019.
//  Copyright © 2019 Visual Engineering. All rights reserved.
//

import UIKit

class TracksProgressView: UIProgressView {
    
    private let indicator: UIView = {
        let indicator = UIView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.backgroundColor = .black
        return indicator
    }()
    
    private let tracksContainer: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        return stackView
    }()
    
    private var indicatorLeadingConstraint: NSLayoutConstraint?
    
    private var tracks = [TrackView]()
    private var durations = [Float]()
    
    var totalDuration: Float {
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
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        addSubview(tracksContainer)
        addSubview(indicator)
        
        indicatorLeadingConstraint = indicator.leadingAnchor.constraint(equalTo: self.leadingAnchor)
        NSLayoutConstraint.activate([
            indicator.topAnchor.constraint(equalTo: self.topAnchor),
            indicator.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            indicator.widthAnchor.constraint(equalToConstant: 2),
            indicatorLeadingConstraint!,
            tracksContainer.topAnchor.constraint(equalTo: self.topAnchor),
            tracksContainer.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            tracksContainer.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            tracksContainer.bottomAnchor.constraint(equalTo: self.bottomAnchor)])
        
        progressTintColor = .clear
        trackTintColor = .clear
    }
    
    func addTrack(duration: Float, starting: Float = 0) {
        let trackView = TrackView()
        trackView.translatesAutoresizingMaskIntoConstraints = false
        trackView.backgroundColor = .clear
        trackView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        tracksContainer.addArrangedSubview(trackView)
        tracks.append(trackView)
        durations.append(duration)
        updateTrackViews()
    }
    
    private func updateTrackViews() {
        for (track, duration) in zip(tracks, durations) {
            track.leadingConstraint.constant = 0
            track.trailingConstraint.constant = -CGFloat((totalDuration - duration) / totalDuration) * self.frame.width
        }
    }
}

extension TracksProgressView {
    
    class TrackView: UIView {
        
        private let trackView: UIView = {
            let track = UIView()
            track.translatesAutoresizingMaskIntoConstraints = false
            track.backgroundColor = .white
            return track
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
            leadingConstraint = trackView.leadingAnchor.constraint(equalTo: leadingAnchor)
            trailingConstraint = trackView.trailingAnchor.constraint(equalTo: trailingAnchor)
            NSLayoutConstraint.activate([
                trackView.topAnchor.constraint(equalTo: topAnchor),
                trackView.bottomAnchor.constraint(equalTo: bottomAnchor),
                leadingConstraint,
                trailingConstraint])
        }
    }
}
