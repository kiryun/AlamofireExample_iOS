//
//  DateFormatter.swift
//  AlamofireNetwork
//
//  Created by Gihyun Kim on 2020/02/27.
//  Copyright © 2020 wimes. All rights reserved.
//

import Foundation

extension DateFormatter {
    static var articleDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
}
