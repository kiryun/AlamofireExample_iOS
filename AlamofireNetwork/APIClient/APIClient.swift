//
//  APIClient.swift
//  AlamofireNetwork
//
//  Created by Gihyun Kim on 2020/02/26.
//  Copyright © 2020 wimes. All rights reserved.
//

import Foundation
import Alamofire
import PromisedFuture

class APIClient {
    @discardableResult
    private static func performRequest<T: Decodable>(route: APIRouter, decoder: JSONDecoder = JSONDecoder()) -> Future<T>{
        return Future { completion in
            AF.request(route)
                .responseDecodable(decoder: decoder, completionHandler: { (response: DataResponse<T, AFError>) in
                    switch response.result{
                    case .success(let value):
                        completion(.success(value))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                })
        }
    }
    
    static func login(email: String, password: String) -> Future<User> {
        return self.performRequest(route: APIRouter.login(email: email, password: password))
    }
    
    static func userArticles(userId: Int) -> Future<[Article]> {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .formatted(.articleDateFormatter)
        return performRequest(route: APIRouter.articles(userId: userId), decoder: jsonDecoder)
    }
    
    static func getArticles(articleId: Int) -> Future<Article>{
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .formatted(DateFormatter.articleDateFormatter)
        
        return performRequest(route: APIRouter.article(id: articleId), decoder: jsonDecoder)
    }
}
