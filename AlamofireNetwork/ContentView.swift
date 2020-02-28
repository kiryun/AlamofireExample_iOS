//
//  ContentView.swift
//  AlamofireNetwork
//
//  Created by Gihyun Kim on 2020/02/26.
//  Copyright © 2020 wimes. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        List{
            Button(action: self.logic){
                Text("Login-GetArticles")
            }
//            Button(action: self.login){
//                Text("Login")
//            }
//            Button(action: self.getArticles){
//                Text("Get Articles")
//            }
//            Button(action: self.badLogic){
//                Text("Bad Logic")
//            }
        }
    }
    
//    func login(){
//        APIClient.login(email: "test@gamil.com", password: "myPassword") { result in
//            switch result{
//            case .success(let user):
//                print(user)
//            case .failure(let error):
//                print("wimes's App Error")
//                print(error.localizedDescription)
//            }
//        }
//    }
//
//    func getArticles(){
//        APIClient.getArticles { result in
//            switch result{
//            case .success(let articles):
//                print(articles)
//            case .failure(let error):
//                print("wimes's App Error")
//                print(error.localizedDescription)
//            }
//        }
//    }
//
//    func badLogic(){
//        APIClient.login(email: "test@gmail.com", password: "myPassword", completion: { result in
//            switch result {
//            case .success(let user):
//                APIClient.userArticles(userID: user.id, completion: { result in
//                    switch result {
//                    case .success(let articles):
//                        APIClient.getArticles(id: articles.last!.id, completion: { result in
//                            switch result {
//                            case .success(let article):
//                                print(article)
//                            case .failure(let error):
//                                print(error)
//                            }
//                        })
//                    case .failure(let error):
//                        print(error)
//                    }
//                })
//            case .failure(let error):
//                print(error)
//            }
//        })
//    }
    
    func logic(){
        APIClient.login(email: "test@gamil.com", password: "myPassword")
            .map({$0.id})
            .andThen(APIClient.a)
            .map({$0.last!.id})
            .andThen(APIClient.getArticles)
            .execute(onSuccess: { article in
                print(article)
            }, onFailure:{ error in
                print(error)
            })
    }
}

