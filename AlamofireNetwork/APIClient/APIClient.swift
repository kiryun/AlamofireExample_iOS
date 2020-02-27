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
    @discardableResult
    private static func performRequest<T: Decodable>(route: APIRouter, decoder: JSONDecoder = JSONDecoder(), completion: @escaping (Result<T, AFError>) -> Void) -> DataRequest{
        return AF.request(route)
            .responseDecodable(decoder: decoder){ (response: DataResponse<T, AFError>) in
                completion(response.result)
        }
    }
    
    static func login(email: String, password: String, completion:@escaping (Result<User, AFError>)->Void) {
        AF.request(APIRouter.login(email: email, password: password))
                 .responseDecodable { (response: DataResponse<User, AFError>) in
                    completion(response.result)
        }
    }
    
    static func getArticles(completion: @escaping (Result<[Article], AFError>) -> Void){
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .formatted(DateFormatter.articleDateFormatter)
        
        AF.request(APIRouter.articles)
            .responseDecodable(decoder: jsonDecoder){ (response: DataResponse<[Article], AFError>) in
                completion(response.result)
        }
    }
    
}
