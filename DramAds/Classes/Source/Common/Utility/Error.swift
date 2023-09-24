//
//  Error.swift
//  DramAdsIosSdk
//
//  Created by Khoren Asatryan on 16.08.23.
//

import Foundation

public protocol IDMError: Error {
    var code: Int { get }
    var message: String? { get }
    var isCanceled: Bool { get }
}

public extension IDMError {
    
    var isCanceled: Bool {
        return false
    }
        
}

extension DM {
    
    enum DMError: IDMError {
                
        case error(error: Error)
        case canceled
        case incorrectUrl
        case notFound
        case incorrectParsing(message: String, code: Int)
        
        var code: Int {
            switch self {
            case .error(let error):
                if let error = error as? IDMError {
                    return error.code
                }
                return (error as NSError).code
            case .canceled:
                return -999
            case .incorrectUrl:
                return -100
            case .incorrectParsing(_, let code):
                return code
            case .notFound:
                return 404
            }
        }
        
        var message: String? {
            switch self {
            case .error(let error):
                if let error = error as? IDMError {
                    return error.message
                }
                return (error as NSError).localizedDescription
            case .canceled:
                return "Request is canceled"
            case .incorrectUrl:
                return "Incorrect Url"
            case .incorrectParsing(let message, _):
                return message
            case .notFound:
                return "Not Found"
            }
        }
        
        var isCanceled: Bool {
            switch self {
            case .error(let error):
                return (error as NSError).code == -999
            case .canceled:
                return true
            case .incorrectUrl, .incorrectParsing, .notFound:
                return false
            }
        }
    }
    
}
