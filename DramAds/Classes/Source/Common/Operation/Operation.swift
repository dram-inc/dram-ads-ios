//
//  Operation.swift
//  DramAdsIosSdk
//
//  Created by Khoren Asatryan on 16.08.23.
//

import Foundation

extension DM {
    
    class Operation<T>: OperationBase {
        
        private var responseHandler: CallBack<Result<T>>?
        
        init(_ responseHandler: @escaping CallBack<Result<T>>) {
            self.responseHandler = responseHandler
        }
        
        func response(_ result: Result<T>) {
            self.underlyingQueue {
                self.responseHandler?(result)
                self.responseHandler = nil
                self.finish()
            }
        }
        
        func response(value: T) {
            let result = Result.success(value)
            self.response(result)
        }
        
        func response(error: IDMError) {
            let result = Result<T>.failure(error)
            self.response(result)
        }
        
        override func cancel() {
            super.cancel()
            self.response(error: DM.DMError.canceled)
        }
                
    }
    
}

extension DM.Operation {
    typealias CallBack<T> = (_ result: T) -> Void
    typealias Result = DM.Result
}

