//
//  OperationManager.swift
//  DramAdsIosSdk
//
//  Created by Khoren Asatryan on 16.08.23.
//

import Foundation

extension DM {
    
    class OperationManager {
        
        let networkDispatchQueue: DispatchQueue?
        
        private var queues: [QueueType: OperationQueue] = [QueueType: OperationQueue]()
        
        var networkQueue: OperationQueue {
            guard let queue = self.queues[.network] else {
                let queue = OperationQueue(operationMaxCount: 20, underlyingQueue: self.networkDispatchQueue)
                self.queues[.network] = queue
                return queue
            }
            return queue
        }
        
        var adNetworkQueue: OperationQueue {
            guard let queue = self.queues[.adNetwork] else {
                let queue = OperationQueue(operationMaxCount: 20, underlyingQueue: self.networkDispatchQueue)
                self.queues[.adNetwork] = queue
                return queue
            }
            return queue
        }
        
        var imageDownloadQueue: OperationQueue {
            guard let queue = self.queues[.imageDownloadNetwork] else {
                let queue = OperationQueue(operationMaxCount: 20, underlyingQueue: self.networkDispatchQueue)
                self.queues[.imageDownloadNetwork] = queue
                return queue
            }
            return queue
        }
        
        init(networkDispatchQueue: DispatchQueue?) {
            self.networkDispatchQueue = networkDispatchQueue
        }
        
        func cancelAllOperations() {
            self.queues.forEach { keyValue in
                keyValue.value.cancelAllOperations()
            }
        }
        
    }
    
}

extension DM.OperationManager {
    
    enum QueueType {
        case adNetwork
        case network
        case imageDownloadNetwork
    }
    
}
