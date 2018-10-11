//
//  StationCode.swift
//  TicketAlert
//
//  Created by Wangshu Zhu on 2018/10/11.
//  Copyright © 2018 Wangshu Zhu. All rights reserved.
//

import Foundation
import CoreFoundation
import SwiftyJSON
import JavaScriptCore

class Station
{
    static var jsContext:JSContext!
    
    // https://kyfw.12306.cn/otn/resources/js/framework/station_name.js
    static var stationList = [String: String]() 
    
    static func fetchStationList() {
        let urlString = "https://kyfw.12306.cn/otn/resources/js/framework/station_name.js"
        let main = Bundle.main
        if let filePath = main.path(forResource: "station_name", ofType: "js") {
        //if let url = URL(string: urlString) {
            if let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)) {
                let jsString = String(data: data, encoding: .utf8)!
                let jsArray = jsString.drop(while: ){$0 != "'"}.drop(while: ){$0 == "'"}.split(separator: "@")
                for string in jsArray {
                    let station = string.split(separator: "|")
                    let stationName = String(station[1])
                    let stationCode = String(station[2])
                    stationList[stationName] = stationCode
                }
            }
            // }
        } else {
            print("code.js dose not exist")
        }
    }
    
    func printStationList() {
        
    }
    
    init() {
    }
}
