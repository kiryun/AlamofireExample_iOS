//
//  APIClient.swift
//  AlamofireNetwork
//
//  Created by Gihyun Kim on 2020/02/26.
//  Copyright © 2020 wimes. All rights reserved.
//

import Foundation
import Alamofire

class APIClient {
    static func login(email: String, password: String, completion:@escaping (Result<User, AFError>)->Void) {
        AF.request(APIRouter.login(email: email, password: password))
                 .responseDecodable { (response: DataResponse<User, AFError>) in
                    completion(response.result)
                    
                    
        }
    }
}
