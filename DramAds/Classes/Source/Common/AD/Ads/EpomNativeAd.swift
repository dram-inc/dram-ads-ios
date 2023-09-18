//
//  EpomNativeAd.swift
//  DramAdsIosSdk
//
//  Created by Khoren Asatryan on 06.09.23.
//

import Foundation

public extension DM {
    
    class EpomNativeAd: EpomAd, Decodable {
        
        private enum CodingKeys: String, CodingKey {
            case advertiser = "advertiser"
            case bannerId = "bannerId"
            case beacons = "beacons"
            case clickUrl = "clickUrl"
            case ctaText = "ctaText"
            case customization = "customization"
            case description = "description"
            case title = "title"
            case subtitle = "subtitle"
            case version = "version"
            case icons = "icons"
            case images = "images"
            
            case videos = "videos"
            case placementId = "placementId"
            case rating = "rating"
            case refreshInterval = "refreshInterval"
        }
        
        let advertiser: String?
        let bannerId: Int?
        let beacons: [Beacon]?
        let clickUrl: URL?
        let ctaText: String?
        let customization: [String: Any]?
        
        let description: String?
        let title: String?
        let subtitle: String?
        let version: String?
        
        let icons: [Image]?
        let images: [Image]?
        let videos: [Video]?
        
        let placementId: Int?
        let rating: Int?
        let refreshInterval: String?

        required public init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            
            self.advertiser = try values.decodeIfPresent(String.self, forKey: .advertiser)
            self.bannerId = try values.decodeIfPresent(Int.self, forKey: .bannerId)
            self.beacons = try values.decodeIfPresent([Beacon].self, forKey: .beacons)
            self.clickUrl = try values.decodeIfPresent(URL.self, forKey: .clickUrl)
            self.ctaText = try values.decodeIfPresent(String.self, forKey: .ctaText)
            self.customization = try values.decodeIfPresent([String: Any].self, forKey: .customization)
            
            self.description = try values.decodeIfPresent(String.self, forKey: .description)
            self.title = try values.decodeIfPresent(String.self, forKey: .title)
            self.subtitle = try values.decodeIfPresent(String.self, forKey: .subtitle)
            
            self.version = try values.decodeIfPresent(String.self, forKey: .version)
            self.icons = try values.decodeIfPresent([Image].self, forKey: .icons)
            self.images = try values.decodeIfPresent([Image].self, forKey: .images)
            self.videos = try values.decodeIfPresent([Video].self, forKey: .videos)
            self.placementId = try values.decodeIfPresent(Int.self, forKey: .placementId)
            self.rating = try values.decodeIfPresent(Int.self, forKey: .rating)
            self.refreshInterval = try values.decodeIfPresent(String.self, forKey: .refreshInterval)
            
            super.init(placementType: .native)
        }
    }
    
}
