//
//  TracksView.swift
//  VEAudioKitDemo
//
//  Created by Pablo Balduz on 22/07/2019.
//  Copyright © 2019 Visual Engineering. All rights reserved.
//

import UIKit

class TracksView: UIProgressView {
    
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
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        return stackView
    }()
    
    private var indicatorLeadingConstraint: NSLayoutConstraint?
        
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
        let trackView = UIView()
        trackView.translatesAutoresizingMaskIntoConstraints = false
        trackView.backgroundColor = .white
        trackView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        tracksContainer.addArrangedSubview(trackView)
    }
}

