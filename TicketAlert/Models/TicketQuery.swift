//
//  TicketQuery.swift
//  TicketAlert
//
//  Created by Wangshu Zhu on 2018/10/11.
//  Copyright © 2018 Wangshu Zhu. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

class TicketQuery
{
    /* https://kyfw.12306.cn/otn/leftTicket/queryA?
     leftTicketDTO.train_date=2018-10-20&
     leftTicketDTO.from_station=BJP&
     leftTicketDTO.to_station=LZJ&
     purpose_codes=ADULT
     */
    var queryTicktParameterNames = ["leftTicketDTO.train_date", "leftTicketDTO.from_station", "leftTicketDTO.to_station", "purpose_codes"]
    
    var routeList: [Route]
    
    func subscribe(to route: Route) {
        routeList.append(route)
        query(route: route)
    }
    
    func query(route: Route) {
        var queryString = "https://kyfw.12306.cn/otn/leftTicket/queryO?"
        let parameters: Parameters = [
            "leftTicketDTO.train_date" : route.trainDate,
            "leftTicketDTO.from_station" : route.fromStation,
            "leftTicketDTO.to_station" : route.toStation,
            "purpose_codes" : route.purposeCode
        ]
        let httpHeader = [
            "User-Agent" : "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/69.0.3497.100 Safari/537.36",
            "Referer" : "https://kyfw.12306.cn/otn/leftTicket/init",
            "X-Requested-With" : "XMLHttpRequest",
            "Accept" : "*/*",
            "Accept-Encoding" : "gzip, deflate, br",
            "Accept-Language" : "en-US,en;q=0.9,zh-CN;q=0.8,zh;q=0.7,zh-TW;q=0.6,ja;q=0.5",
            "Cache-Control" : "no-cache",
            "Connection" : "keep-alive"
        ]
        queryString.append("\(queryTicktParameterNames[0])=\(parameters[queryTicktParameterNames[0]]!)&\(queryTicktParameterNames[1])=\(parameters[queryTicktParameterNames[1]]!)&\(queryTicktParameterNames[2])=\(parameters[queryTicktParameterNames[2]]!)&\(queryTicktParameterNames[3])=\(parameters[queryTicktParameterNames[3]]!)")
        print(queryString)
        
        Alamofire.request(queryString).validate().responseJSON { response in
            
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print("JSON: \(json)")
            case .failure(let error):
                print(error)
            }
        }
    }
    
    convenience init(routeList: [Route]) {
        self.init()
    }
    
    init() {
        routeList = [Route]()
    }
}
