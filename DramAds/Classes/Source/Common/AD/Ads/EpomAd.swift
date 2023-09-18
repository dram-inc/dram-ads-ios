//
//  EpomAd.swift
//  DramAdsIosSdk
//
//  Created by Khoren Asatryan on 06.09.23.
//

import Foundation

public extension DM {
    
    class EpomAd: Ad {
                
        public let placementType: AdPlacementType
        
        init(placementType: AdPlacementType) {
            self.placementType = placementType
        }
        
    }
    
}

public extension DM.EpomAd {
    
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

public extension DM.EpomAd {
    
    enum AdPlacementType {
        
        case site
        case nonStandart
        case video
        case native
        
        var path: String {
            switch self {
            case .site, .nonStandart:
                return "ads-api-v3"
            case .video:
                return ""
            case .native:
                return "ads-api-native"
            }
        }
        
    }
    
}

