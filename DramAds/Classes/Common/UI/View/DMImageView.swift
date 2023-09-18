//
//  DMImageView.swift
//  DramAds
//
//  Created by Khoren Asatryan on 10.09.23.
//

import UIKit

class DMImageView: UIImageView {
    
    private weak var token: DM.ImageService.Token?
    private var urlRequest: URLRequest?
    private var imageService = DM.shared.imageService
    
    func setImage(urlStr: String, defautImage: UIImage? = nil) {
        let request = try? DM.Request(urlStr: urlStr)
        self.setImage(request: request, defautImage: defautImage)
    }
    
    func setImage(url: URL?, defautImage: UIImage? = nil) {
        
        guard let url = url else {
            self.setImage(request: nil, defautImage: defautImage)
            return
        }
        
        let request = DM.Request(url: url)
        self.setImage(request: request, defautImage: defautImage)
    }
    
    func setImage(request: IDMRequest?, defautImage: UIImage? = nil) {
        self.token?.cancell()
        guard let request = try? request?.asRequest(), request.url != self.urlRequest?.url else {
            if self.image == nil {
                self.image = defautImage
            }
            return
        }
        
        self.image = defautImage
        self.urlRequest = request
        self.token = self.imageService.downloadImage(request: request) { [weak self] result in
            switch result {
            case .success(let image):
                self?.image = image
            case .failure(_):
                break
            }
        }
    }
        
}
