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
    // 以查询条件为KEY的字典，值为查询返回值（字典： KEY为车次 值为参数状态对）

    private var leftTicketResults = [Route: Array<[String: String]>]()
    private var mapArrayDictionary = [Route: [String: String]]()
    private var leftTicketArray = [Route: [String]]()
    
    // alternate for leftTicketResults
    private var routeInfoList: [[String]]?
    var searchParmeters = [Route: [String: Bool]]()
    
    // MARK: - Table View data source
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            tableView.performBatchUpdates({
                deleteQuery(for: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }, completion: { (finish) in
            })
        default:
            break
        }
        
    }
    
    private func deleteQuery(for index: Int) {
        if index < routeList.count {
            let route = routeList[index]
            routeList.remove(at: index)
            leftTicketResults.removeValue(forKey: route)
            mapArrayDictionary.removeValue(forKey: route)
            leftTicketArray.removeValue(forKey: route)
            searchParmeters.removeValue(forKey: route)
            print("row removed from table")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routeList.isEmpty ? 1 : routeList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var identifier = ""
        if routeList.isEmpty {
            identifier = "PlaceHolder"
        } else {
            identifier = "RouteCell"
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        if let RouteCell = cell as? RouteListTableViewCell {
            var leftLabel = ""
            
            // look for from and to staion code
            let routeOnRow = routeList[indexPath.row]
            let fromStationCode = routeList[indexPath.row].fromStation
            let toStationCode = routeList[indexPath.row].toStation
            
            //get mapping from code to literal station name (retrieved from 12306 api response message)
            let stationNameMappingDictionary = Station.stationList
            //get from and to station text from mapping dictionary
            
            // TODO: fix option unwrapp logic crash
            let fromStationText = stationNameMappingDictionary.key(forValue: fromStationCode)!
            let toStationText = stationNameMappingDictionary.key(forValue: toStationCode)!
            
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
            
            
            if leftTicketStatusText == "无票" {
                RouteCell.backgroundColor = #colorLiteral(red: 1, green: 0.5781051517, blue: 0, alpha: 1)
            } else {
                RouteCell.backgroundColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
            }
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
    //MARK: var api , all route list 
    var routeList: [Route]
    let dateFormatter = DateFormatter()
    
    //TODO: subscribe to remote notification
    func subscribe(to route: Route, withParmeters parameters:[String: Bool]) {
        routeList.append(route)
        query(route: route)
        searchParmeters[route] = parameters
        let jsonEncoder = JSONEncoder()
        do {
            let jsonRouteList = try jsonEncoder.encode(routeList)
            let jsonSearchParams = try jsonEncoder.encode(searchParmeters)
            let url: URL = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let routeUrl = url.appendingPathComponent("routeList").appendingPathExtension("js")
            let searchUrl = url.appendingPathComponent("searchParameters").appendingPathExtension("js")
            try jsonRouteList.write(to: routeUrl, options: .atomic)
            try jsonSearchParams.write(to: searchUrl, options: .atomic)
            
            
        } catch EncodingError.invalidValue(let value, _) {
            print("\(value) cant be encoded because..")
        } catch let nserror as NSError {
            print(nserror.debugDescription)
        } catch {
            print("Object: TicktQuery Line 144 Unexpected error catched!")
        }
        
        
//        let dataBase = UserDefaults.standard
        
//        dataBase.set(routeList, forKey: "routeList")
//        dataBase.set(searchParmeters, forKey: "searchParameters")
    }
    
    private func query(route: Route) {
        var queryString = "https://kyfw.12306.cn/otn/leftTicket/query?"
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
        //print(queryString)
        
        //TODO: save to user defaults
        
        
        Alamofire.request(queryString).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                
                NotificationCenter.default.post(name: Notification.Name("subcribeSuccess"), object: TicketQuery.self, userInfo: ["successKey" : true])
                
                let json = JSON(value)
                // save to database.
                let resultArray = json["data"]["result"].arrayValue
                let mapArray = json["data"]["map"].dictionaryValue
                let mapArrayStringDictionary = Dictionary(uniqueKeysWithValues: mapArray.map { key, value in (key, value.stringValue) })
                self.mapArrayDictionary[route] = mapArrayStringDictionary
                //print(self.mapArrayDictionary)
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
                NotificationCenter.default.post(name: Notification.Name("subcribeSuccess"), object: TicketQuery.self, userInfo: ["successKey" : false])
                print(error)
            }
        }
    }
    
    private func calcLeftTicketStatus(on route:Route) -> String {
        var returnString = "无票"
        var leftTicketCount: Int = 0
        guard let searchCondition = searchParmeters[route] else {
            print("未找到搜索条件")
            return "搜索失败"
        }
        var hasTicketRouteCode = [String]()
        if let routeArray = leftTicketResults[route] {
            //设置车次优先级/ 设置抢票坐席
            routeArray.forEach { result in
                for (key, value) in result {
                    if let searchKey = searchCondition[key] {
                        if  searchKey {
                            if value == "有" {
                                returnString = "有票"
                                hasTicketRouteCode += [result["train_code"]!]
                            } else if Int(value) != nil {
                                guard returnString == "有票" else { leftTicketCount += Int(value) ?? 0; return }
                                hasTicketRouteCode += [result["train_code"]!]
                            } else {
                                guard returnString == "有票" else { returnString = "无票"; return }
                            }
                        }
                    }
                }
                //TODO: get left ticket status
            }
            // NotificationCenter.default.post(Notification(name: Notification.Name("ticketIsAvailable"), object: TicketQuery.self, userInfo: ["余票": leftTicketStatus, "route": ]))
        }
        //print(returnString)
        return leftTicketCount == 0 ? returnString : "余票：\(leftTicketCount)"
    }
    
    convenience init(routeList: [Route]) {
        self.init()
    }
    
    override init() {
        routeList = [Route]()
    }
}
