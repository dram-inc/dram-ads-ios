//
//  NetworkDownloadOperation.swift
//  DramAds
//
//  Created by Khoren Asatryan on 09.09.23.
//

import Foundation

extension DM {
    
    class NetworkDownloadOperation: NetworkOperation<URL, URLSessionDownloadTask> {
        
        typealias ProgressCallBack = CallBack<Progress>
        
        private var progressHandler: ProgressCallBack?
        
        init(task: URLSessionDownloadTask, queue: DispatchQueue, _ callBack: @escaping CallBack<DM.Result<URL>>, _ progressHandler: ProgressCallBack?) {
            self.progressHandler = progressHandler
            super.init(task: task, queue: queue, callBack)
        }
        
        override func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
            super.urlSession(session, task: task, didCompleteWithError: error)
        }
        
        override func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
            super.urlSession(session, dataTask: dataTask, didReceive: data)
        }
        
        func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
            self.response(value: location)
        }
        
        func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
            self.progressHandler?(downloadTask.progress)
        }
        
        func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {}
        
    }
    
}
