//
//  EpomAd.swift
//  DramAdsIosSdk
//
//  Created by Khoren Asatryan on 06.09.23.
//

import Foundation

public extension DM {
    
    class Ad: AdBase {
                
        public let placementType: AdPlacementType
        
        init(placementType: AdPlacementType) {
            self.placementType = placementType
            super.init()
        }
        
    }
    
}

public extension DM.Ad {
    
    enum BeaconType: Decodable, Equatable {
        
        case impression
        case noImpression
        case unknown(type: String)
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawString = try container.decode(String.self)
            
            switch rawString {
            case "impression":
                self = .impression
            case "noImpression":
                self = .noImpression
            default:
                self = .unknown(type: rawString)
            }
            
        }
    }
    
    struct Beacon: Decodable {
        let type: BeaconType
        let url: URL
    }
    
    struct Image: Decodable {
        let width: Float
        let height: Float
        let url: URL
    }
    
    struct Video: Decodable {
        let width: Float
        let height: Float
        let url: URL
    }
    
}

public extension DM.Ad {
    
    enum AdPlacementType {
        
        case site
        case nonStandart
        case video
        case native
        
        var path: String {
            switch self {
            case .site, .nonStandart:
                return "placement/banner"
            case .video:
                return ""
            case .native:
                return "placement/native"
            }
        }
        
    }
    
}

