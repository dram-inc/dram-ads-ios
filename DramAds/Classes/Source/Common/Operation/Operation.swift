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
            let result = Result.success(result: value)
            self.response(result)
        }
        
        func response(error: IDMError) {
            let result = Result<T>.failure(error: error)
            self.response(result)
        }
        
        override func cancel() {
            super.cancel()
            self.response(error: DM.DMError.canceled)
        }
                
    }
    
}

extension DM.Operation {
    typealias CallBack<Result> = (_ result: Result) -> Void
    typealias Result = DM.Result
}

