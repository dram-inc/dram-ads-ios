//
//  ADService+NativeAd.swift
//  DramAds
//
//  Created by Khoren Asatryan on 10.09.23.
//

import Foundation

public extension DM.ADService {
    
    @discardableResult
    func load(nativeAd configuration: DM.EpomAdRequest.Configuration, response: @escaping (DM.Result<DM.EpomNativeAd>) -> Void) -> IDMNetworkOperation? {
        guard let enviorment = self.enviorment else {
            self.responseQueue.async {
                response(.failure(AdError.configurationError))
            }
            return nil
        }

        do {
            let request = try DM.EpomAdRequest(configuration: configuration, env: enviorment, placementType: .native)
            return self.network.request(decodable: request) { [weak self] (result: DM.Result<DM.EpomNativeAd>) in
                self?.responseQueue.async {
                    response(result)
                }
            }
        } catch {
            self.responseQueue.async {
                response(.failure(AdError.error(error: error)))
            }
        }
        return nil
    }
    
    ///Use for test
    @discardableResult
    func load(nativeAd placementKey: String, response: @escaping (DM.Result<Any>) -> Void) -> IDMNetworkOperation? {
        guard let enviorment = self.enviorment else {
            self.responseQueue.async {
                response(.failure(AdError.configurationError))
            }
            return nil
        }

        do {
            let congig = DM.EpomAdRequest.Configuration(default: placementKey)
            let request = try DM.EpomAdRequest(configuration: congig, env: enviorment, placementType: .native)
            self.network.request(json: request) { [weak self] result in
                self?.responseQueue.async {
                    response(result)
                }
            }

        } catch {
            self.responseQueue.async {
                response(.failure(AdError.error(error: error)))
            }
        }
        return nil
    }
        
}
