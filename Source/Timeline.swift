//
//  Timeline.swift
//  VEAudioKit
//
//  Created by Pablo Balduz on 19/08/2019.
//

import AVFoundation

// MARK: - TimelineDelegate

/// The `TimelineDelegate` provides an interface to respond to `Timeline` events as well as to configure it.
protocol TimelineDelegate: class {
    
    var length: TimeInterval { get }
    
    /// A `TimeInterval` to control the time updates triggering rate
    var timeUpdateRate: TimeInterval { get }
    
    /// Triggered when a time update happens according to `timeUpdateRate` property value
    ///
    /// - Parameters:
    ///   - time: The time elapsed (expressed in seconds) since the `Timeline` instance was started
    func currentTimeDidUpdate(time: Double)
    
    func timelineDidReachEnd()
}

extension TimelineDelegate {
    var timeUpdateRate: TimeInterval { return 0.1 }
}

// MARK: - Timeline

/// Custom timeline designed to work while playing audio files.
/// It provides the ability to track the current position of the audio expressed in seconds.
/// It also provides a `TimelineDelegate` that enables responding to time updates.
class Timeline {
    
    // MARK: - Public properties
    
    /// A `Double` representing the current second in the timeline
    var currentTime: Double {
        guard let length = delegate?.length else { return 0 }
        let time = lastPauseTime + currentElapsedTime
        return time.bounded(by: 0...length)
    }
    
    /// A `Bool` indicating whether the timeline is active or not
    var isRunning: Bool {
        return running
    }
    
    /// A `TimelineDelegate` to handle events and configure the timeline
    weak var delegate: TimelineDelegate? {
        didSet {
            guard let delegate = delegate else { return }
            Timer.TimerUpdateRate = delegate.timeUpdateRate
        }
    }
    
    // MARK: - Private properties
    
    private var currentElapsedTime: Double = 0
    private var lastPauseTime: Double = 0
    private var timer = Timer()
    private var running: Bool = false
    
    // MARK: - Public properties
    
    /// Initializes a new `Timeline` object
    init() {
        timer.delegate = self
    }
    
    // MARK: - Public methods
    
    /// Starts the timeline from zero
    func start() {
        timer.start()
        running = true
    }
    
    /// Pauses the timeline
    ///
    /// This causes the stop of time updates being triggered
    func pause() {
        if running { lastPauseTime += timer.currentElapsed.seconds }
        currentElapsedTime = 0
        timer.stop()
        running = false
    }
    
    /// Sets the current time to zero and stops the timeline
    ///
    /// This causes the stop of time updates being triggered
    func reset() {
        timer.stop()
        lastPauseTime = 0
        currentElapsedTime = 0
        running = false
    }
    
    /// Seeks current time a specified amount of time specfied in seconds
    /// - Parameters:
    ///   - seconds: The number of seconds the timeline should add to current time
    ///
    /// A negative value will result in moving backwards in the timeline
    func seek(_ seconds: Double) {
        guard let length = delegate?.length else { return }
        lastPauseTime += currentElapsedTime + seconds
        lastPauseTime = lastPauseTime.bounded(by: 0...length)
        timer.stop()
        currentElapsedTime = 0
        if running { timer.start() }
    }
}

extension Timeline: TimerDelegate {
    
    func timeDidUpdate(timeElapsedSinceLastStart time: NanoSeconds) {
        guard let length = delegate?.length else { return }
        currentElapsedTime = time.seconds
        if currentTime == length {
            timer.stop()
            running = false
            currentElapsedTime = 0
            lastPauseTime = length
            delegate?.timelineDidReachEnd()
        }
        delegate?.currentTimeDidUpdate(time: currentTime)
    }
}
