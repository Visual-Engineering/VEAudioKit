//
//  Utils.swift
//  VEAudioKit
//
//  Created by Pablo Balduz on 26/08/2019.
//

import Foundation

extension Numeric where Self: Comparable {
    
    func bounded(by range: ClosedRange<Self>) -> Self {
        return max(min(self, range.upperBound), range.lowerBound)
    }
}

