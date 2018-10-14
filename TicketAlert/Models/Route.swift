//
//  Route.swift
//  TicketAlert
//
//  Created by Wangshu Zhu on 2018/10/11.
//  Copyright © 2018 Wangshu Zhu. All rights reserved.
//

import Foundation

struct Route: Hashable, CustomDebugStringConvertible {
    var debugDescription: String {
        return "\(fromStation)->\(toStation)"
    }
    
    var routeNm: String?
    var trainDate: Date
    var purposeCode = "ADULT"
    var fromStation: String
    var toStation: String
    
    init(trainDate: Date, fromStation: String, toStation: String) {
        self.trainDate = trainDate
        self.fromStation = fromStation
        self.toStation = toStation
    }
}
