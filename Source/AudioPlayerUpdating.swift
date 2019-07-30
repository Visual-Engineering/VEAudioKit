//
//  AudioPlayerUpdating.swift
//  VEAudioKit
//
//  Created by Pablo Balduz on 30/07/2019.
//

protocol AudioPlayerUpdating: class {
    var updater: Timer? { get set }
    var updaterRateTimeInterval: TimeInterval { get }
    func updatePlayerPosition()
}

extension AudioPlayerUpdating {
    
    var updaterRateTimeInterval: TimeInterval {
        return 0.1
    }
    
    func startTimer() {
        if updater == nil {
            let timer = Timer(timeInterval: updaterRateTimeInterval, repeats: true, block: timerUpdated)
            RunLoop.current.add(timer, forMode: .common)
            updater = timer
        }
    }
    
    func cancelTimer() {
        updater?.invalidate()
        updater = nil
    }
    
    private func timerUpdated(timer: Timer) {
        updatePlayerPosition()
    }
}

