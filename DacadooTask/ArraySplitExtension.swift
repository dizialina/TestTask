//
//  ArraySplitExtension.swift
//  DacadooTask
//
//  Created by Alina Yehorova on 22.09.16.
//  Copyright © 2016 Alina Yehorova. All rights reserved.
//

import Foundation

extension Array {
    
    mutating func splitBy(numberOfElements:Int) -> [Array] {
        
        // Count number of possible subarrays after splitting
        var numberOfPossibleSubarrays = self.count / numberOfElements
        
        // Check if last subarray will be full
        let lastSubarrayCount = self.count % numberOfElements
        if lastSubarrayCount > 0 {
            numberOfPossibleSubarrays += 1
        }
        
        // Slice array into parts
        var arrayOfSubarrays = [Array]()
        let lastIndex = numberOfElements
        for _ in 1...numberOfPossibleSubarrays {
            if self.count > lastIndex {
                let subarray = self.prefix(upTo: lastIndex)
                arrayOfSubarrays.append(Array(subarray))
                self.removeSubrange(0..<lastIndex)
            } else {
                arrayOfSubarrays.append(self)
            }
        }
        
        return arrayOfSubarrays
    }
    
}
