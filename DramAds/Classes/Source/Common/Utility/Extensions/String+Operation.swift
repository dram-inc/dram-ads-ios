//
//  String+Operation.swift
//  DramAdsIosSdk
//
//  Created by Khoren Asatryan on 07.09.23.
//

import Foundation
import CommonCrypto
import CryptoKit

private protocol ByteCountable {
    static var byteCount: Int { get }
}

extension Insecure.MD5: ByteCountable { }
extension Insecure.SHA1: ByteCountable { }

extension String {
        
    var sha1: String? {
        return self.insecureSHA1Hash()
    }
    
    var md5: String? {
        return self.insecureMD5Hash()
    }
    
    func insecureMD5Hash(using encoding: String.Encoding = .utf8) -> String? {
        return self.hash(algo: Insecure.MD5.self, using: encoding)
    }
    
    func insecureSHA1Hash(using encoding: String.Encoding = .utf8) -> String? {
        return self.hash(algo: Insecure.SHA1.self, using: encoding)
    }
    
    private func hash<Hash: HashFunction & ByteCountable>(algo: Hash.Type, using encoding: String.Encoding = .utf8) -> String? {
        guard let data = self.data(using: encoding) else {
            return nil
        }
        
        return algo.hash(data: data).prefix(algo.byteCount).map {
            String(format: "%02hhx", $0)
        }.joined()
    }
    
    
}
