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
        private(set) var enviorment: Enviorment?
        
        init(network: NetworkDispatcher, responseQueue: DispatchQueue) {
            self.network = network
            self.responseQueue = responseQueue
        }
        
        func configure(enviorment: Enviorment) {
            self.enviorment = enviorment
        }
        
        @discardableResult
        public func loadAd(request: EpomAdRequest, response: @escaping (DM.Result<Any>) -> Void) -> IDMNetworkOperation? {
            return self.network.request(json: request) { [weak self] result in
                self?.responseQueue.async {
                    response(result)
                }
            }
        }
        
    }
    
}

public extension DM.ADService {
    
    enum AdError: IDMError {
        
        case configurationError
        case error(error: Error)
        
        public var code: Int? {
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
    }
    
}
