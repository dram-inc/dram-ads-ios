//
//  ADService+NativeAd.swift
//  DramAds
//
//  Created by Khoren Asatryan on 10.09.23.
//

import Foundation

public extension DM.ADService {
    
    @discardableResult
    func load(nativeAd configuration: DM.AdRequest.Configuration, response: @escaping (DM.Result<DM.NativeAd>) -> Void) -> IDMNetworkOperation? {
        guard let enviorment = self.environment else {
            self.responseQueue.async {
                response(.failure(error: AdError.configurationError))
            }
            return nil
        }

        do {
            let request = try DM.AdRequest(configuration: configuration, env: enviorment, placementType: .native)
            return self.network.request(decodable: request) { [weak self] (result: DM.Result<DM.NativeAd>) in
                self?.responseQueue.async {
                    response(result)
                }
            }
        } catch {
            self.responseQueue.async {
                response(.failure(error: AdError(error: error)))
            }
        }
        return nil
    }
    
    ///Use for test
    @discardableResult
    func load(nativeAd placementKey: String, response: @escaping (DM.Result<Any>) -> Void) -> IDMNetworkOperation? {
        guard let enviorment = self.environment else {
            self.responseQueue.async {
                response(.failure(error: AdError.configurationError))
            }
            return nil
        }

        do {
            let congig = DM.AdRequest.Configuration(default: placementKey)
            let request = try DM.AdRequest(configuration: congig, env: enviorment, placementType: .native)
            self.network.request(json: request) { [weak self] result in
                self?.responseQueue.async {
                    response(result)
                }
            }

        } catch {
            self.responseQueue.async {
                response(.failure(error: AdError(error: error)))
            }
        }
        return nil
    }
        
}
