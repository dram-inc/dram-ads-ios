//
//  ADService.swift
//  DramAdsIosSdk
//
//  Created by Khoren Asatryan on 21.08.23.
//

import Foundation

extension DM {
    
    public class ADService {
        
        typealias CallBack<T> = (_ result: DM.Result<T>) -> Void
        
        let network: NetworkDispatcher
        let responseQueue: DispatchQueue
        private(set) var environment: Environment?
        
        init(network: NetworkDispatcher, responseQueue: DispatchQueue) {
            self.network = network
            self.responseQueue = responseQueue
        }
        
        func configure(environment: Environment) {
            self.environment = environment
        }
        
        @discardableResult
        public func loadAd(request: AdRequest, response: @escaping (DM.Result<Any>) -> Void) -> IDMNetworkOperation? {
            return self.network.request(json: request) { [weak self] result in
                self?.responseQueue.async {
                    response(result)
                }
            }
        }
        
    }
    
}

public extension DM.ADService.AdError {
    
    enum ErrorType: IDMError {
        
        case configurationError
        case error(error: Error)
        
        public var code: Int {
            switch self {
            case .configurationError:
                return -1
            case .error(let error):
                if let error = error as? IDMError {
                    return error.code
                }
                return (error as NSError).code
            }
        }
        
        public var message: String? {
            switch self {
            case .configurationError:
                return "Configuration error"
            case .error(let error):
                if let error = error as? IDMError {
                    return error.message
                }
                return (error as NSError).localizedDescription
            }
        }
        
        public var isCanceled: Bool {
            switch self {
            case .configurationError:
                return false
            case .error(let error):
                if let error = error as? IDMError {
                    return error.isCanceled
                }
                return (error as NSError).code == -999
            }
        }
    }
    
}

public extension DM.ADService {
    
    @objc(DMServiceAdError)
    class AdError: NSObject {
        
        static var configurationError: AdError {
            return AdError(errorType: .configurationError)
        }
        
        let errorType: ErrorType
        
        public override var description: String {
            return "code: \(self.code), message: \(self.message ?? "")"
        }
        
        init(errorType: ErrorType) {
            self.errorType = errorType
            super.init()
        }
        
        convenience init(error: Error) {
            self.init(errorType: .error(error: error))
        }
        
    }
    
}

extension DM.ADService.AdError: IDMError {
    
    public var code: Int {
        return self.errorType.code
    }
    
    @objc public var message: String? {
        return self.errorType.message
    }
    
    @objc public var isCanceled: Bool {
        return self.errorType.isCanceled
    }
    
}

@objc extension DM.ADService.AdError: CustomNSError {
    
    @objc public static var errorDomain: String {
        return "DramAds.io"
    }
    
    @objc public var errorCode: Int {
        return self.code
    }
    
    @objc public var errorUserInfo: [String : Any] {
        return ["message": self.message ?? "", "code": self.code]
    }
    
}
