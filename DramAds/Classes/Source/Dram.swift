//
//  Dram.swift
//  DramAdsIosSdk
//
//  Created by Khoren Asatryan on 16.08.23.
//

import Foundation

/// DM is root class in sdk
@objc(DMDram)
public class DM: NSObject {
    
    /// Return class instance
    @objc(sharedManager)
    static public let shared: DM = DM(queue: DM.queue, responseQueue: DM.responseQueue)
    
    static private let queue = DispatchQueue(label: "Dram")
    static private let responseQueue = DispatchQueue.main
    static var bundle: Bundle { return Bundle(for: DM.self) }
    
    private let operationManager: OperationManager
    let network: NetworkDispatcher
    let imageService: ImageService
    public let adService: ADService
    
    private init(queue: DispatchQueue, responseQueue: DispatchQueue) {
        self.operationManager = OperationManager(networkDispatchQueue: queue)
        self.network = NetworkDispatcher(configuration: .default, queue: queue, operationQueue: self.operationManager.adNetworkQueue)
        self.imageService = ImageService(queue: queue, memoryCache: ImageService.MemoryCache(), deckCache: nil, operationQueue: self.operationManager.imageDownloadQueue)
        self.adService = ADService(network: self.network, responseQueue: responseQueue)
    }
    
    public func configure(enviorment: Enviorment) {
        self.adService.configure(enviorment: enviorment)
    }
    
    @objc
    public func configure() {
        let enviorment = DM.Enviorment(baseUrl: "https://ads.epomtestsite.com")
        self.configure(enviorment: enviorment)
    }
    
}
