//
//  NetworkOperation.swift
//  DramAdsIosSdk
//
//  Created by Khoren Asatryan on 16.08.23.
//

import Foundation

public protocol IDMNetworkOperation: AnyObject {
    var taskIdentifier: Int { get }
    func cancel()
}

protocol IDMNetworkTaskOperation: IDMNetworkOperation {
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?)
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data)
    
}

extension DM {
    
    class NetworkOperation<T, Task: URLSessionTask>: DM.Operation<T>, IDMNetworkTaskOperation {
                    
        private let task: Task
        
        var sessionTask: URLSessionTask {
            return self.task
        }
        
        var taskIdentifier: Int {
            return self.task.taskIdentifier
        }
                
        init(task: Task, queue: DispatchQueue, _ responseHandler: @escaping CallBack<Result<T>>) {
            self.task = task
            super.init(responseHandler)
        }
        
        override func resume() {
            super.resume()
            self.resumeTask()
        }
        
        func resumeTask() {
            self.task.resume()
        }
            
        func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {}
        func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {}
        
    }
  
}
