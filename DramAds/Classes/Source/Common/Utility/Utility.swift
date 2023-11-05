//
//  Utility.swift
//  DramAdsIosSdk
//
//  Created by Khoren Asatryan on 16.08.23.
//

import Foundation

extension DM {
        
    public enum Result<T> {
        case success(result: T)
        case failure(error: IDMError)
    }
    
    typealias CallBack<T> = (_ result: T) -> Void
    typealias ResultCallBack<T> = CallBack<Result<T>>
    
}

@objc public extension DM {
    
    @objc(DMEnvironment) class Environment: NSObject {
        
        /// Base Url for epom
        public let baseUrl: String
        public let type: `Type`
        
        @objc public init(baseUrl: String, type: Type) {
            self.baseUrl = baseUrl
            self.type = type
        }
                
        @objc public init(type: `Type`) {
            self.type = type
            
            var url: String {
                switch type {
                case .demo:
                    return "https://demoad.justdram.com"
                case .live:
                    return "https://ad.justdram.com"
                }
            }
            
            self.baseUrl = url
        }
        
    }
    
}

public extension DM.Environment {
    
    @objc(DMEnvironmentType)
    enum `Type`: Int {
        case demo
        case live
    }
    
}

public extension DM {
    
    struct Utility {
        
        static func getIpAddress() -> String? {
            var address : String?
            // Get list of all interfaces on the local machine:
            var ifaddr : UnsafeMutablePointer<ifaddrs>?
            guard getifaddrs(&ifaddr) == 0 else { return nil }
            guard let firstAddr = ifaddr else { return nil }
            
            // For each interface ...
            for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
                let interface = ifptr.pointee
                
                // Check for IPv4 or IPv6 interface:
                let addrFamily = interface.ifa_addr.pointee.sa_family
                if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                    
                    // Check interface name:
                    let name = String(cString: interface.ifa_name)
                    if  name == "en0" {
                        // Convert interface address to a human readable string:
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                    &hostname, socklen_t(hostname.count),
                                    nil, socklen_t(0), NI_NUMERICHOST)
                        address = String(cString: hostname)
                    } else if (name == "pdp_ip0" || name == "pdp_ip1" || name == "pdp_ip2" || name == "pdp_ip3") {
                        // Convert interface address to a human readable string:
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                    &hostname, socklen_t(hostname.count),
                                    nil, socklen_t(1), NI_NUMERICHOST)
                        address = String(cString: hostname)
                    }
                }
            }
            freeifaddrs(ifaddr)
            return address
        }

        
    }
    
}

extension TimeInterval {
    
    func timeFormat(useMilliseconds: Bool = false) -> String {
        let ti = Int(useMilliseconds ? self / 1000 : self)
        let seconds = ti % 60
        let minutes = (ti / 60) % 60
        let hours = (ti / 3600)
        
        if hours == 0 {
            if minutes == 0 {
                return String(format: "%d",seconds)
            }
            return String(format: "%0.2d:%0.2d%",minutes,seconds)
        }
        
        return String(format: "%0.2d:%0.2d:%0.2d%",hours,minutes,seconds)
    }
    
}
