//
//  EpomAdRequest.swift
//  DramAdsIosSdk
//
//  Created by Khoren Asatryan on 18.08.23.
//

import Foundation
import UIKit

@objc extension DM {
    
    @objc(DMAdRequest)
    public class AdRequest: DM.Request {
        
        public init(configuration: AdRequest.Configuration, env: Environment, placementType: DM.Ad.AdPlacementType) throws {
            let urlStr = env.baseUrl + "/" + placementType.path
            guard let url = URL(string: urlStr) else {
                throw DMError.incorrectUrl
            }
            super.init(url: url, method: .post, queryParams: configuration.culculate())
        }
        
    }
    
}


@objc public extension DM.AdRequest {
        
    /// Epom ad Request configuration
    @objc(DMAdRequestConfiguration)
    class Configuration: NSObject {
        
        @objc(DMAdRequestConfigurationLocation)
        public class Location: NSObject {
            
            let latitude: String
            let longitude: String
            
            @objc
            init(latitude: String, longitude: String) {
                self.latitude = latitude
                self.longitude = longitude
                super.init()
            }
        }
        
        /// Operation system device
        @objc(DMAdRequestConfigurationOperationSystem)
        public class OperationSystem: NSObject {
            /// Device type (1 - Mobile, 2 - PC, 3 - Connected TV) int value
            let deviceType: String?
            
            /// Operation System of the client: Mac OS X; iOS
            let clientOs: String?
            
            /// Device operating system version 3.1.2
            let version: String?
            
            @objc
            init(deviceType: String?, clientOs: String?, version: String?) {
                self.deviceType = deviceType
                self.clientOs = clientOs
                self.version = version
                super.init()
            }
            
        }
        
        ///Placement unique identifier
        @objc public let placementIdentifier: String
                
        ///IP of the client
        @objc public let clientIp: String
                
        /// Response format (html, jsonp, json, xml, xml-bids). Default - html
        @objc public let format: String?
        
        /// Defines how many banners are selected for request. Applyies only for xml-bids format. Default - 1
        @objc public let maxBids: String?
        
        /// Jsonp callback function name
        /// requard if response format is jsonp
        @objc public let callback: String?
        
        /// Client’s time zone
        /// -1; 2; 5.5
        @objc public let tz: String?
        
        /// Client’s location
        @objc public let location: Location?
        
        /// Device UUID
        @objc public let deviceID: String?
        
        /// Device model iPhone: iPad; TV; CarPlay; Mac
        @objc public let model: String?
        
        /// Device make Apple
        @objc public let make: String?
        
        /// Operation system device
        @objc public let operationSystem: OperationSystem?
        
        /// {bannerId}|{count}|{bannerId}|{count}|...
        @objc public let noImpressionsReport: String?
        
        /// Application bundle ID
        @objc public let appBundleID: String?
        
        @objc public init(placementIdentifier: String, clientIp: String? = nil, format: String? = nil, maxBids: String? = nil, callback: String? = nil, tz: String? = nil, location: Location? = nil, deviceID: String? = nil, model: String? = nil, make: String? = nil, operationSystem: OperationSystem? = nil, noImpressionsReport: String? = nil, appBundleID: String? = nil) {
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
            super.init()
        }
        
        @objc public convenience init(default placementIdentifier: String) {
            let clientIp = DM.Utility.getIpAddress() ?? ""
            let tz = TimeInterval(TimeZone.current.secondsFromGMT()) / 3600
            let device = UIDevice.current
            let deviceID = device.identifierForVendor?.uuidString
            let model = device.userInterfaceIdiom
            let make = "Apple"
            let operationSystem = OperationSystem(deviceType: "\(device.userInterfaceIdiom.deviceType)", clientOs: device.systemName, version: device.systemVersion)
            self.init(placementIdentifier: placementIdentifier, clientIp: clientIp, tz: "\(tz)", deviceID: deviceID, model: model.stringValue, make: make, operationSystem: operationSystem, appBundleID: Bundle.main.bundleIdentifier)
        }
        
        func culculate() -> [String: String] {
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
