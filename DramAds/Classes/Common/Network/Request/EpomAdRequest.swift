//
//  EpomAdRequest.swift
//  DramAdsIosSdk
//
//  Created by Khoren Asatryan on 18.08.23.
//

import Foundation
import UIKit

extension DM {
    
    public class EpomAdRequest: DM.Request {
        
        public init(configuration: EpomAdRequest.Configuration, env: Enviorment, placementType: DM.EpomAd.AdPlacementType) throws {
            let urlStr = env.baseUrl + "/" + placementType.path
            guard let url = URL(string: urlStr) else {
                throw DMError.incorrectUrl
            }
            super.init(url: url, method: .post, queryParams: configuration.culculateRequestHeader())
        }
        
    }
    
}


extension DM.EpomAdRequest {
        
    /// Epom ad Request configuration
    public struct Configuration {
        
        public struct Location {
            let latitude: String
            let longitude: String
        }
        
        /// Operation system device
        public struct OperationSystem {
            /// Device type (1 - Mobile, 2 - PC, 3 - Connected TV) int value
            let deviceType: String?
            
            /// Operation System of the client: Mac OS X; iOS
            let clientOs: String?
            
            /// Device operating system version 3.1.2
            let version: String?
        }
        
        ///Placement unique identifier
        public let placementIdentifier: String
                
        ///IP of the client
        public let clientIp: String
                
        /// Response format (html, jsonp, json, xml, xml-bids). Default - html
        public let format: String?
        
        /// Defines how many banners are selected for request. Applyies only for xml-bids format. Default - 1
        public let maxBids: String?
        
        /// Jsonp callback function name
        /// requard if response format is jsonp
        public let callback: String?
        
        /// Client’s time zone
        /// -1; 2; 5.5
        public let tz: String?
        
        /// Client’s location
        public let location: Location?
        
        /// Device UUID
        public let deviceID: String?
        
        /// Device model iPhone: iPad; TV; CarPlay; Mac
        public let model: String?
        
        /// Device make Apple
        public let make: String?
        
        /// Operation system device
        public let operationSystem: OperationSystem?
        
        /// {bannerId}|{count}|{bannerId}|{count}|...
        public let noImpressionsReport: String?
        
        /// Application bundle ID
        public let appBundleID: String?
        
        public init(placementIdentifier: String, clientIp: String? = nil, format: String? = nil, maxBids: String? = nil, callback: String? = nil, tz: String? = nil, location: Location? = nil, deviceID: String? = nil, model: String? = nil, make: String? = nil, operationSystem: OperationSystem? = nil, noImpressionsReport: String? = nil, appBundleID: String? = nil) {
            self.placementIdentifier = placementIdentifier
            self.clientIp = clientIp ?? DM.Utility.getIpAddress() ?? ""
            self.format = format
            self.maxBids = maxBids
            self.callback = callback
            self.tz = tz
            self.location = location
            self.deviceID = deviceID
            self.model = model
            self.make = make
            self.operationSystem = operationSystem
            self.noImpressionsReport = noImpressionsReport
            self.appBundleID = appBundleID
        }
        
        public init(default placementIdentifier: String) {
            let clientIp = DM.Utility.getIpAddress() ?? ""
            let tz = TimeInterval(TimeZone.current.secondsFromGMT()) / 3600
            let device = UIDevice.current
            let deviceID = device.identifierForVendor?.uuidString
            let model = device.userInterfaceIdiom
            let make = "Apple"
            let operationSystem = OperationSystem(deviceType: "\(device.userInterfaceIdiom.deviceType)", clientOs: device.systemName, version: device.systemVersion)
            self.init(placementIdentifier: placementIdentifier, clientIp: clientIp, tz: "\(tz)", deviceID: deviceID, model: model.stringValue, make: make, operationSystem: operationSystem, appBundleID: Bundle.main.bundleIdentifier)
        }
        
        func culculateRequestHeader() -> [String: String] {
            let maxBids = self.maxBids ?? "1"
            var result: [String: String] = ["clientIp": self.clientIp, "key": self.placementIdentifier, "maxBids": maxBids]
            
            result.appentIfExist(key: "format", value: self.format)
            result.appentIfExist(key: "callback", value: self.callback)
            result.appentIfExist(key: "tz", value: self.tz)
            result.appentIfExist(key: "latitude", value: self.location?.latitude)
            result.appentIfExist(key: "longitude", value: self.location?.longitude)
            
            result.appentIfExist(key: "didsha1", value: self.deviceID?.sha1)
            result.appentIfExist(key: "didmd5", value: self.deviceID?.md5)
            result.appentIfExist(key: "model", value: self.model)
            result.appentIfExist(key: "make", value: self.make)
            result.appentIfExist(key: "devicetype", value: self.operationSystem?.deviceType)
            
            result.appentIfExist(key: "clientOs", value: self.operationSystem?.clientOs)
            result.appentIfExist(key: "osv", value: self.operationSystem?.version)
            
            result.appentIfExist(key: "no_impressions_report", value: self.noImpressionsReport)
            result.appentIfExist(key: "apn", value: self.appBundleID)
            
            return result
        }
        
    }
    
}

private extension UIUserInterfaceIdiom {
    
    var stringValue: String {
        switch self {
        case .unspecified:
            return ""
        case .phone:
            return "iPhone"
        case .pad:
            return "iPad"
        case .tv:
            return "TV"
        case .carPlay:
            return "CarPlay"
        case .mac:
            return "Mac"
        default:
            return ""
        }
    }
    
    var deviceType: Int {
        switch self {
        case .unspecified:
            return 0
        case .phone:
            return 1
        case .pad:
            return 1
        case .tv:
            return 3
        case .carPlay:
            return 0
        case .mac:
            return 3
        default:
            return 0
        }
    }
        
}
