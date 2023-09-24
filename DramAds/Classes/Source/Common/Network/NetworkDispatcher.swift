//
//  NetworkDispatcher.swift
//  DramAdsIosSdk
//
//  Created by Khoren Asatryan on 16.08.23.
//

import Foundation

extension DM {

    class NetworkDispatcher: NSObject {

        private(set) var session: URLSession!
        private let operationQueue: DM.OperationQueue
        private let operations = WeakArray<IDMNetworkTaskOperation>()
        private let threadLock = NSLock()
        let dispatchQueue: DispatchQueue

        init(configuration: URLSessionConfiguration, queue: DispatchQueue, operationQueue: DM.OperationQueue, maxConcurrentOperationCount: Int = 20) {
            self.operationQueue = operationQueue
            self.dispatchQueue = queue
            super.init()
            let operationQueue = Foundation.OperationQueue()
            operationQueue.maxConcurrentOperationCount = maxConcurrentOperationCount
            operationQueue.underlyingQueue = queue
            self.session = URLSession(configuration: configuration, delegate: self, delegateQueue: operationQueue)
        }
        
        func generateNetworkDownloadOperation(task: URLSessionDownloadTask, callBack: @escaping CallBack<URL>, progressHandler: ProgressCallBack?) -> IDMNetworkOperation {
            return NetworkDownloadOperation(task: task, queue: self.dispatchQueue, callBack, progressHandler)
        }
        
        func run(operation: IDMNetworkOperation) {
            self.dispatchQueue.async {
                self.threadLock.lock()
                self.operations.addObject(operation as! IDMNetworkTaskOperation)
                if let operation = operation as? OperationBase {
                    self.operationQueue.add(operation)
                }
                self.threadLock.unlock()
            }
        }
                        
    }

}

extension DM.NetworkDispatcher {
    
    typealias ProgressCallBack = DM.NetworkDownloadOperation.ProgressCallBack
            
    func download(request: URLRequest, autoRun: Bool, callBack: @escaping CallBack<URL>, progressHandler: ProgressCallBack?) -> IDMNetworkOperation {
        let task = self.session.downloadTask(with: request)
        let operation = self.generateNetworkDownloadOperation(task: task, callBack: callBack, progressHandler: progressHandler)
        if autoRun {
            self.run(operation: operation)
        }
        return operation
    }
    
    func download(request: IDMRequest, autoRun: Bool = true, callBack: @escaping CallBack<URL>, progressHandler: ProgressCallBack?) -> IDMNetworkOperation? {
        do {
            let request = try request.asRequest()
            return self.download(request: request, autoRun: autoRun, callBack: callBack, progressHandler: progressHandler)
        } catch {
            let error = DM.DMError.error(error: error)
            self.dispatchQueue.async {
                callBack(.failure(error: error))
            }
        }
        return nil
    }
    
}

extension DM.NetworkDispatcher {
    
    typealias CallBack<T> = (_ result: DM.Result<T>) -> Void
    
    private func request<Decoder: IDMNetworkOperationDecoder>(request: URLRequest, decoder: Decoder, callBack: @escaping CallBack<Decoder.T>) -> IDMNetworkOperation {
                
        let task = self.session.dataTask(with: request)
        let operation = DM.NetworkDataOperation<Decoder>(task: task, decoder: decoder, queue: self.dispatchQueue, callBack)
        
        self.threadLock.lock()
        self.operations.addObject(operation)
        self.operationQueue.add(operation)
        self.threadLock.unlock()
        return operation
    }
    
    @discardableResult
    func request<Decoder: IDMNetworkOperationDecoder>(request: IDMRequest, decoder: Decoder, callBack: @escaping CallBack<Decoder.T>) -> IDMNetworkOperation? {
        do {
            let request = try request.asRequest()
            return self.request(request: request, decoder: decoder, callBack: callBack)
        } catch {
            let error = DM.DMError.error(error: error)
            self.dispatchQueue.async {
                callBack(.failure(error: error))
            }
        }
        return nil
    }
    
    @discardableResult
    func request<T: Decodable>(decodable request: IDMRequest, decoder: IDMDecoder = JSONDecoder(), callBack: @escaping CallBack<T>) -> IDMNetworkOperation? {
        let decoder = DM.AnyDecodableDecoder<T>(decoder: decoder)
        return self.request(request: request, decoder: decoder, callBack: callBack)
    }
    
    @discardableResult
    func request(string request: IDMRequest, callBack: @escaping CallBack<String>) -> IDMNetworkOperation? {
        let decoder = DM.AnyStringDecoder()
        return self.request(request: request, decoder: decoder, callBack: callBack)
    }
    
    @discardableResult
    func request(data request: IDMRequest, callBack: @escaping CallBack<Data>) -> IDMNetworkOperation? {
        let decoder = DM.AnyDataDecoder()
        return self.request(request: request, decoder: decoder, callBack: callBack)
    }
    
    @discardableResult
    func request(json request: IDMRequest, callBack: @escaping CallBack<Any>) -> IDMNetworkOperation? {
        let decoder = DM.AnyJSONDecoder()
        return self.request(request: request, decoder: decoder, callBack: callBack)
    }
    
}

extension DM.NetworkDispatcher: URLSessionDelegate {
    
    private func getOperation(for taskIdentifier: Int, find: @escaping (_ result: IDMNetworkTaskOperation?) -> Void) {
        self.threadLock.lock()
        let operation = self.operations.first(where: { $0.taskIdentifier == taskIdentifier })
        self.threadLock.unlock()
        find(operation)
    }
        
}

extension DM.NetworkDispatcher: URLSessionTaskDelegate {
        
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        self.getOperation(for: task.taskIdentifier) { result in
            result?.urlSession(session, task: task, didCompleteWithError: error)
        }
    }
    
}

extension DM.NetworkDispatcher: URLSessionDataDelegate {
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        self.getOperation(for: dataTask.taskIdentifier) { result in
            result?.urlSession(session, dataTask: dataTask, didReceive: data)
        }
    }
    
}

extension DM.NetworkDispatcher: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        self.getOperation(for: downloadTask.taskIdentifier) { result in
            (result as? DM.NetworkDownloadOperation)?.urlSession(session, downloadTask: downloadTask, didFinishDownloadingTo: location)
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        self.getOperation(for: downloadTask.taskIdentifier) { result in
            (result as? DM.NetworkDownloadOperation)?.urlSession(session, downloadTask: downloadTask, didWriteData: bytesWritten, totalBytesWritten: totalBytesWritten, totalBytesExpectedToWrite: totalBytesExpectedToWrite)
        }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        self.getOperation(for: downloadTask.taskIdentifier) { result in
            (result as? DM.NetworkDownloadOperation)?.urlSession(session, downloadTask: downloadTask, didResumeAtOffset: fileOffset, expectedTotalBytes: expectedTotalBytes)
        }
    }
    
}
