//
//  OperationQueue.swift
//  DramAdsIosSdk
//
//  Created by Khoren Asatryan on 16.08.23.
//

import Foundation

extension DM {
    
    class OperationQueue {
        
        private let queue: Foundation.OperationQueue
        
        init(operationMaxCount: Int, underlyingQueue: DispatchQueue?) {
            self.queue = Foundation.OperationQueue()
            self.queue.maxConcurrentOperationCount = operationMaxCount
            self.queue.qualityOfService = .userInitiated
            self.queue.underlyingQueue = underlyingQueue
        }
        
        init(queue: Foundation.OperationQueue) {
            self.queue = queue
        }
        
        func add(_ operation: OperationBase) {
            operation.underlyingQueue = self.queue.underlyingQueue
            self.queue.addOperation(operation)
        }
        
        func cancelAllOperations() {
            self.queue.cancelAllOperations()
        }
        
        func allOperations() -> [OperationBase] {
            return self.queue.operations.compactMap({ $0 as? OperationBase})
        }
        
    }
    
}
