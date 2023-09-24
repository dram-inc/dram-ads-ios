//
//  IDMRequest.swift
//  DramAdsIosSdk
//
//  Created by Khoren Asatryan on 16.08.23.
//

import Foundation

protocol IDMRequest {
    func asRequest() throws -> URLRequest
}

extension DM {
    
    @objc(DMRequest)
    public class Request: NSObject, IDMRequest {
        
        public let url: URL
        public let method: HTTPMethod?
        public let body: [String: Any?]?
        public let headers: [String: String?]?
        public let queryParams: [String: String?]?
        public let timeoutInterval: TimeInterval
        
        public init(url: URL, method: HTTPMethod? = nil, params: [String : Any?]? = nil, headers: [String : String?]? = nil, queryParams: [String : String?]? = nil, timeoutInterval: TimeInterval = 60.0) {
            self.url = url
            self.method = method
            self.body = params
            self.headers = headers
            self.queryParams = queryParams
            self.timeoutInterval = timeoutInterval
            super.init()
        }
        
        public init(urlStr: String, method: HTTPMethod? = nil, params: [String : Any?]? = nil, headers: [String : String?]? = nil, queryParams: [String : String?]? = nil, timeoutInterval: TimeInterval = 60.0) throws {
            
            guard let url = URL(string: urlStr) else {
                throw DMError.incorrectUrl
            }
            
            self.url = url
            self.method = method
            self.body = params
            self.headers = headers
            self.queryParams = queryParams
            self.timeoutInterval = timeoutInterval
            super.init()
        }
        
        func asRequest() throws -> URLRequest {
            guard var components = URLComponents(url: self.url, resolvingAgainstBaseURL: false) else {
                throw RequestError.requestNotValid(url: self.url.absoluteString)
            }
                        
            let queryItems = self.queryParams?.compactMap({ keyValue in
                return URLQueryItem(name: keyValue.key, value: keyValue.value)
            })
            components.queryItems = queryItems
            components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
            
            guard let url = components.url else {
                throw RequestError.requestNotValid(url: self.url.absoluteString)
            }
            var request = URLRequest(url: url, timeoutInterval: self.timeoutInterval)
            request.httpMethod = self.method?.httpMethod
            
            self.headers?.forEach({ keyValue in
                request.setValue(keyValue.value, forHTTPHeaderField: keyValue.key)
            })
            
            if let body = self.body {
                do {
                    let data = try JSONSerialization.data(withJSONObject: body)
                    request.httpBody = data
                } catch {
                    throw DMError.error(error: error)
                }
            }
            return request
        }
    }

    
}

extension DM.Request {
    
    enum RequestError: IDMError {
        
        case requestNotValid(url: String)
        
        var code: Int {
            switch self {
            case .requestNotValid:
                return -10
            }
        }
        
        var message: String? {
            switch self {
            case .requestNotValid(let url):
                return "request not valid \(url)"
            }
        }
    }
    
    public enum HTTPMethod {
        case get
        case post
        case put
        case patch
        case delete
        case custom(method: String)
        
        var httpMethod: String {
            switch self {
            case .get:
                return "GET"
            case .post:
                return "POST"
            case .put:
                return "PUT"
            case .patch:
                return "PATCH"
            case .delete:
                return "DELETE"
            case .custom(let method):
                return method
            }
        }
    }
    
}
