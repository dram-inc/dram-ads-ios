//
//  Dictionary+Operation.swift
//  DramAdsIosSdk
//
//  Created by Khoren Asatryan on 07.09.23.
//

import Foundation

extension Dictionary {
    
    mutating func appentIfExist(key: Key, value: Value?) {
        guard let value = value else {
            return
        }
        self[key] = value
    }
    
}
