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
            Button(action: self.login){
                Text("Login")
            }
            Button(action: self.getArticles){
                Text("Get Articles")
            }
        }
    }
    
    func login(){
        APIClient.login(email: "test@gamil.com", password: "myPassword") { result in
            switch result{
            case .success(let user):
                print(user)
            case .failure(let error):
                print("wimes's App Error")
                print(error.localizedDescription)
            }
        }
    }
    
    func getArticles(){
        APIClient.getArticles { result in
            switch result{
            case .success(let articles):
                print(articles)
            case .failure(let error):
                print("wimes's App Error")
                print(error.localizedDescription)
            }
        }
    }
    
}

