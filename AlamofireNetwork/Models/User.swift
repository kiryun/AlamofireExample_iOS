//
//  User.swift
//  AlamofireNetwork
//
//  Created by Gihyun Kim on 2020/02/26.
//  Copyright © 2020 wimes. All rights reserved.
//

import Foundation

struct User: Codable {
    let id: Int
    let firstName: String
    let lastName: String
    let email: String
    let image: URL
}
