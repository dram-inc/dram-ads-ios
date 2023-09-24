//
//  ImageServiceOperation.swift
//  DramAds
//
//  Created by Khoren Asatryan on 09.09.23.
//

import UIKit

extension DM {
    
    class ImageServiceOperation: DM.NetworkDownloadOperation {
        
        let deckCache: IImageServiceCache?
        let memoryCache: IImageServiceCache
        private let imageIdentifier: String?
        
        private var tokens: Set<Token> = Set<Token>()
        
        init(task: URLSessionDownloadTask, queue: DispatchQueue, deckCache: IImageServiceCache?, memoryCache: IImageServiceCache, callBack: @escaping CallBack<DM.Result<URL>>, _ progressHandler: ProgressCallBack?) {
            self.deckCache = deckCache
            self.memoryCache = memoryCache
            self.imageIdentifier = task.originalRequest?.url?.absoluteString
            super.init(task: task, queue: queue, callBack, progressHandler)
        }
        
        override func response(error: IDMError) {
            self.tokens.forEach { token in
                DispatchQueue.main.async {
                    token.imageHandler(.failure(error: error))
                }
            }
            super.response(error: error)
        }
        
        override func resumeTask() {
            guard self.imageIdentifier != nil else {
                self.response(error: DMError.incorrectUrl)
                return
            }
            
            if let image = self.getImageFromMemoryCache() {
                self.tokens.forEach { token in
                    DispatchQueue.main.async {
                        token.imageHandler(.success(result: image))
                    }
                }
                super.response(.success(result: URL(fileURLWithPath: "")))
            } else if let image = self.getImageFromDeckCache() {
               
                try? self.memoryCache.write(identifier: image.identifier, image: image.data)
                
                self.tokens.forEach { token in
                    DispatchQueue.main.async {
                        token.imageHandler(.success(result: image.image))
                    }
                }
            } else {
                super.resumeTask()
            }
                            
        }
        
        override func response(_ result: DM.Result<URL>) {
            
            guard let imageIdentifier = self.imageIdentifier else {
                self.response(error: DMError.incorrectUrl)
                return
            }
            
            if !self.isCancelled {
                switch result {
                case .success(let url):
                    do {
                        let data = try Data(contentsOf: url)
                        try self.deckCache?.write(identifier: imageIdentifier, image: data)
                        try self.memoryCache.write(identifier: imageIdentifier, image: data)
                        let imageData = try self.memoryCache.read(identifier: imageIdentifier)
                        guard let image = UIImage(data: imageData) else {
                            let error = DMError.incorrectUrl
                            super.response(error: DMError.incorrectUrl)
                            self.tokens.forEach { token in
                                DispatchQueue.main.async {
                                    token.imageHandler(.failure(error: error))
                                }
                            }
                            return
                        }
                        self.tokens.forEach { token in
                            DispatchQueue.main.async {
                                token.imageHandler(.success(result: image))
                            }
                        }
                    } catch {
                        let error = DMError.error(error: error)
                        super.response(error: error)
                        self.tokens.forEach { token in
                            DispatchQueue.main.async {
                                token.imageHandler(.failure(error: error))
                            }
                        }
                        return
                    }
                default:
                    break
                }
            }
            super.response(result)
        }
        
        func createToken(imageHandler: @escaping CallBack<Result<UIImage>>, progress: ProgressCallBack?) -> Token {
            let token = Token(imageHandler: imageHandler, progress: progress) { [weak self] token in
                self?.underlyingQueue {
                    self?.tokens.remove(token)
                    if (self?.tokens.isEmpty ?? true) {
                        self?.cancel()
                    }
                }
            }
            
            self.underlyingQueue { [weak self] in
                self?.tokens.insert(token)
            }
            
            return token
        }
        
        private func getImageFromMemoryCache() -> UIImage? {
            guard let imageIdentifier = self.imageIdentifier, let imageData = try? self.memoryCache.read(identifier: imageIdentifier), let image = UIImage(data: imageData) else {
                return nil
            }
            return image
        }
        
        private func getImageFromDeckCache() -> (image: UIImage, data: Data, identifier: String)? {
            guard let imageIdentifier = self.imageIdentifier, let imageData = try? self.deckCache?.read(identifier: imageIdentifier), let image = UIImage(data: imageData) else {
                return nil
            }
            return (image: image, data: imageData, imageIdentifier)
        }
        
    }
    
}

extension DM.ImageServiceOperation {
    
    final class Token: Equatable, Hashable {
                
        fileprivate let identifier: String = UUID().uuidString
        fileprivate let imageHandler: CallBack<Result<UIImage>>
        fileprivate let progress: ProgressCallBack?
        private let cancellToken: ((_ token: Token) -> Void)?
        
        init(imageHandler: @escaping CallBack<Result<UIImage>>, progress: ProgressCallBack?, cancellToken: ((_ token: Token) -> Void)?) {
            self.imageHandler = imageHandler
            self.progress = progress
            self.cancellToken = cancellToken
        }
        
        func cancell() {
            self.cancellToken?(self)
        }
        
        static func == (lhs: Token, rhs: Token) -> Bool {
            return lhs.identifier == rhs.identifier
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(self.identifier)
        }
        
    }
        
}
