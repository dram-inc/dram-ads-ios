//
//  Operation.swift
//  DramAdsIosSdk
//
//  Created by Khoren Asatryan on 16.08.23.
//

import Foundation

protocol IOperation: AnyObject {
    func cancel()
}

extension DM {
    
    class OperationBase: Foundation.Operation, IOperation {
        
        enum Status: String {
            case ready = "isReady"
            case executing = "isExecuting"
            case finished = "isFinished"
            case waiting = "isWaiting"
            case canceled = "isCanceled"
        }
        
        private enum State: String {
            case ready = "isReady"
            case executing = "isExecuting"
            case finished = "isFinished"
            case cancelled = "isCancelled"
        }
        
       var underlyingQueue: DispatchQueue?
        
        private(set) var isWaiting = false
                
        override var isReady: Bool {
            set {
                willChangeValue(forKey: State.ready.rawValue)
                didChangeValue(forKey: State.ready.rawValue)
            } get {
                return self.status == .ready
            }
        }
        
        override var isExecuting: Bool {
            set {
                willChangeValue(forKey: State.executing.rawValue)
                didChangeValue(forKey: State.executing.rawValue)
            } get {
                return self.status == .executing
            }
        }
        
        override var isFinished: Bool {
            set {
                willChangeValue(forKey: State.finished.rawValue)
                didChangeValue(forKey: State.finished.rawValue)
            } get {
                return self.status == .finished
            }
        }
        
        func underlyingQueue(execute work: @escaping @convention(block) () -> Void) {
            if let underlyingQueue = self.underlyingQueue {
                underlyingQueue.async {
                    work()
                }
            } else {
                work()
            }
        }
        
        private(set) var status: Status = .ready {
            didSet {
                self.underlyingQueue {
                    switch self.status {
                    case .ready:
                        self.isReady = true
                        self.isExecuting = false
                        self.isFinished = false
                        self.isWaiting = false
                    case .executing:
                        self.isReady = false
                        self.isExecuting = true
                        self.isFinished = false
                        self.isWaiting = false
                    case .finished:
                        self.isReady = false
                        self.isExecuting = false
                        self.isWaiting = false
                        self.isFinished = true
                    case .waiting:
                        self.isReady = false
                        self.isExecuting = false
                        self.isFinished = false
                        self.isWaiting = true
                    case .canceled:
                        self.isReady = false
                        self.isExecuting = false
                        self.isFinished = false
                        self.isWaiting = false
                    }
                }
            }
        }
            
        override func start() {
            super.start()
            if self.isCancelled {
                self.status = .executing
                self.status = .finished
            } else {
                if !self.isWaiting {
                    self.resume()
                }
            }
        }
        
        func finish() {
            if self.isExecuting {
                self.status = .finished
            } else {
                super.cancel()
            }
        }
        
        func pause() {
            self.status = .waiting
        }
        
        func resume() {
            self.status = .executing
        }
                        
    }

}
