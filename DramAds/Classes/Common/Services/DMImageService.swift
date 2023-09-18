//
//  DMImageService.swift
//  DramAds
//
//  Created by Khoren Asatryan on 09.09.23.
//

import Foundation
import UIKit

protocol IImageServiceCache: AnyObject {
    func read(identifier: String) throws -> Data
    func write(identifier: String, image: Data) throws
}


extension DM {
    
    class ImageService: NetworkDispatcher {
        
        let deckCache: IImageServiceCache?
        let memoryCache: IImageServiceCache
        private let threadLock = DMLocker()
        
        private var operations = [URL: ImageServiceOperation]()
        
        init(queue: DispatchQueue, maxConcurrentOperationCount: Int = 20, memoryCache: IImageServiceCache, deckCache: IImageServiceCache?, operationQueue: DM.OperationQueue) {
            self.memoryCache = memoryCache
            self.deckCache = deckCache
            super.init(configuration: .default, queue: queue, operationQueue: operationQueue)
        }
        
        @discardableResult
        override func generateNetworkDownloadOperation(task: URLSessionDownloadTask, callBack: @escaping DM.NetworkDispatcher.CallBack<URL>, progressHandler: DM.NetworkDispatcher.ProgressCallBack?) -> IDMNetworkOperation {
            return ImageServiceOperation(task: task, queue: self.dispatchQueue, deckCache: self.deckCache, memoryCache: self.memoryCache, callBack: { [weak self] result in
                self?.removeOperation(task)
                callBack(result)
            }, progressHandler)
        }
                
        @discardableResult
        func downloadImage(request: URLRequest, imageHandler: @escaping ImageServiceOperation.CallBack<Result<UIImage>>, progress: NetworkDispatcher.ProgressCallBack? = nil) -> ImageServiceOperation.Token? {
           
            if let operation = self.getOperation(for: request), operation.isExecuting {
                return operation.createToken(imageHandler: imageHandler, progress: progress)
            } else {
                let networkOperation = self.download(request: request, autoRun: false) { result in } progressHandler: { result in }
                let token = (networkOperation as? ImageServiceOperation)?.createToken(imageHandler: imageHandler, progress: progress)
                self.addOperation(operation: networkOperation as! ImageServiceOperation)
                self.run(operation: networkOperation)
                return token
            }
        }
        
        @discardableResult
        func downloadImage(request: IDMRequest, imageHandler: @escaping ImageServiceOperation.CallBack<Result<UIImage>>, progress: NetworkDispatcher.ProgressCallBack? = nil) -> ImageServiceOperation.Token? {
            do {
                let request = try request.asRequest()
                return self.downloadImage(request: request, imageHandler: imageHandler, progress: progress)
            } catch {
                imageHandler(.failure(DMError.error(error: error)))
                return nil
            }
        }
        
        private func getOperation(for request: URLRequest) -> ImageServiceOperation? {
            return self.threadLock.locked { [weak self] in
                guard let url = request.url else {
                    return nil
                }
                return self?.operations[url]
            }
        }
        
        private func addOperation(operation: ImageServiceOperation) {
            self.threadLock.locked { [weak self] in
                guard let url = operation.sessionTask.originalRequest?.url else {
                    return
                }
                self?.operations[url] = operation
            }
        }
        
        private func removeOperation(for request: URLRequest) {
            self.threadLock.locked { [weak self] in
                guard let url = request.url else {
                    return
                }
                self?.operations[url] = nil
            }
        }
        
        private func removeOperation(_ operation: ImageServiceOperation) {
            self.threadLock.locked { [weak self] in
                guard let url = operation.sessionTask.originalRequest?.url else {
                    return
                }
                self?.operations[url] = nil
            }
        }
        
        private func removeOperation(_ sessionTask: URLSessionTask) {
            self.threadLock.locked { [weak self] in
                guard let url = sessionTask.originalRequest?.url else {
                    return
                }
                self?.operations[url] = nil
            }
        }
        
    }
    
}

extension DM.ImageService {
    typealias Token = DM.ImageServiceOperation.Token
}

extension DM.ImageService {
    
    class MemoryCache: IImageServiceCache {
        
        private let cache: NSCache<NSString, NSData>
        
        init() {
            self.cache = NSCache()
            self.cache.countLimit = 330
        }
        
        func read(identifier: String) throws -> Data {
            guard let data = self.cache.object(forKey: identifier as NSString) else {
                throw DM.DMError.notFound
            }
            return data as Data
        }
        
        func write(identifier: String, image: Data) throws {
            self.cache.setObject(image as NSData, forKey: identifier as NSString)
        }
    }
    
}

