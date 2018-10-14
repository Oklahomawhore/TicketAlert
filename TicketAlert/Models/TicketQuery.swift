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

class TicketQuery:NSObject, UITableViewDataSource
{
    static var shared = TicketQuery()
    
    private var leftTicketResults = [Route: Array<[String: String]>]() // 以查询条件为KEY的字典，值为查询返回值（字典： KEY为车次 值为参数状态对）
    private var mapArrayDictionary = [Route: [String: String]]()
    private var leftTicketArray = [Route: [String]]()
    
    // alternate for leftTicketResults
    private var routeInfoList: [[String]]?
    
    // MARK: - Table View data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return leftTicketResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RouteCell", for: indexPath)
        if let RouteCell = cell as? RouteListTableViewCell {
            var leftLabel = ""
            
            // look for from and to staion code
            let routeOnRow = routeList[indexPath.row]
            let fromStationCode = routeList[indexPath.row].fromStation
            let toStationCode = routeList[indexPath.row].toStation
            
            //get mapping from code to literal station name (retrieved from 12306 api response message)
            let stationNameMappingDictionary = mapArrayDictionary[routeOnRow]!
            
            //get from and to station text from mapping dictionary
            
            // TODO: fix option unwrapp logic crash
            let fromStationText = stationNameMappingDictionary[fromStationCode]!
            let toStationText = stationNameMappingDictionary[toStationCode]!
            
            // configure date format to display (i.e. mm/dd)
            let departureDate = routeOnRow.trainDate
            dateFormatter.dateFormat = "MM/dd"
            let strDate = dateFormatter.string(from: departureDate)
            
            //display left label with from and to staions and date
            leftLabel.append("\(fromStationText)→\(toStationText)")
            //leftLabel.append("")
            
            RouteCell.midDateDisplayLabel.text = strDate
            RouteCell.routeInfoLabel.text = leftLabel

            
            let leftTicketStatusText = calcLeftTicketStatus(on: routeOnRow)
            RouteCell.leftTicketStatusLabel.text = leftTicketStatusText

        }
        return cell
    }
    
    /* https://kyfw.12306.cn/otn/leftTicket/queryA?
     leftTicketDTO.train_date=2018-10-20&
     leftTicketDTO.from_station=BJP&
     leftTicketDTO.to_station=LZJ&
     purpose_codes=ADULT
     */
    
    private var queryTicktParameterNames = ["leftTicketDTO.train_date", "leftTicketDTO.from_station", "leftTicketDTO.to_station", "purpose_codes"]
    
    private var routeList: [Route]
    let dateFormatter = DateFormatter()
    
    func subscribe(to route: Route) {
        routeList.append(route)
        query(route: route)
    }
    
    private func query(route: Route) {
        var queryString = "https://kyfw.12306.cn/otn/leftTicket/queryO?"
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let strDate = dateFormatter.string(from: route.trainDate)
        let parameters: Parameters = [
            "leftTicketDTO.train_date" : strDate,
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
                
                NotificationCenter.default.post(name: Notification.Name("subcribeSuccess"), object: TicketQuery.self, userInfo: nil)
                
                let json = JSON(value)
                // save to database.
                let resultArray = json["data"]["result"].arrayValue
                let mapArray = json["data"]["map"].dictionaryValue
                let mapArrayStringDictionary = Dictionary(uniqueKeysWithValues: mapArray.map { key, value in (key, value.stringValue) })
                self.mapArrayDictionary[route] = mapArrayStringDictionary
                print(self.mapArrayDictionary)
                self.routeInfoList = resultArray.map {
                    $0.stringValue.split(separator: "|", maxSplits: 36, omittingEmptySubsequences: false)
                    }.map {
                        $0.map {
                            String($0)
                        }
                }
                if self.leftTicketArray[route] != nil {
                    self.leftTicketArray[route]?.removeAll()
                }
                var ticketDictionaryArray = Array<[String: String]>()
                
                self.routeInfoList?.forEach { array in
                    //let array = Array($0).map { String($0) }
                    ticketDictionaryArray.append(
                    [   "train_code": array[3],
                        "origin" : array[4],
                        "destination" : array[5],
                        "from_station" : array[6],
                        "to_station" : array[7],
                        "departure_time" : array[8],
                        "arrival_time" : array[9],
                        "time_interval" : array[10],
                        "next_day" : array[11],
                        "GJRW" : array[21],
                        "RW" : array[23],
                        "RZ" : array[24],
                        "WZ" : array[26],
                        "YW" : array[28],
                        "YZ" : array[29],
                        "EDZ" : array[30],
                        "YDZ" : array[31],
                        "SWZTDZ" : array[32],
                        "DW" : array[33]
                    ])
                }
                self.leftTicketResults[route] = ticketDictionaryArray
                print(self.leftTicketResults)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func calcLeftTicketStatus(on route:Route) -> String {
        if let routeArray = leftTicketResults[route] {
            var leftTicketStatus = false
            //设置车次优先级/ 设置抢票坐席
            routeArray.forEach { result in
                for (key, value) in result {
                    
                }
                
            }
            //TODO: get left ticket status
        }
        
        return "有票"
    }
    
    convenience init(routeList: [Route]) {
        self.init()
    }
    
    override init() {
        routeList = [Route]()
    }
}
