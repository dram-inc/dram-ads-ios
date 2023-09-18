//
//  Decoder.swift
//  DramAdsIosSdk
//
//  Created by Khoren Asatryan on 17.08.23.
//

import Foundation

protocol IDMDecoder {
    func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable
}

extension JSONDecoder: IDMDecoder {}

protocol IDMNetworkOperationDecoder {
    associatedtype T
    func decode(_ type: T.Type, from data: Data) throws -> T
}

extension DM {
    
    struct AnyDecodableDecoder<Obj: Decodable>: IDMNetworkOperationDecoder {
        
        typealias T = Obj
        
        let decoder: IDMDecoder
        
        init(decoder: IDMDecoder = JSONDecoder()) {
            self.decoder = decoder
        }
        
        func decode(_ type: Obj.Type, from data: Data) throws -> Obj {
            do {
                return try self.decoder.decode(type, from: data)
            } catch {
                throw DMError.error(error: error)
            }
        }
    }
    
    struct AnyJSONDecoder: IDMNetworkOperationDecoder {
                
        typealias T = Any
        
        let readingOptions: JSONSerialization.ReadingOptions
        
        init(readingOptions: JSONSerialization.ReadingOptions = []) {
            self.readingOptions = readingOptions
        }
        
        func decode(_ type: T.Protocol, from data: Data) throws -> T {
            do {
                return try JSONSerialization.jsonObject(with: data, options: self.readingOptions)
            } catch {
                throw DMError.error(error: error)
            }
        }

    }
    
    struct AnyStringDecoder: IDMNetworkOperationDecoder {
        
        typealias T = String
        
        func decode(_ type: String.Type, from data: Data) throws -> String {
            let str = String(decoding: data, as: UTF8.self)
            return str
        }

    }
    
    struct AnyDataDecoder: IDMNetworkOperationDecoder {
        
        typealias T = Data
        
        func decode(_ type: Data.Type, from data: Data) throws -> Data {
            return data
        }
        
    }
    
}
