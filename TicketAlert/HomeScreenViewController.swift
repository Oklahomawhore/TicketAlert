//
//  HomeScreenViewController.swift
//  TicketAlert
//
//  Created by Wangshu Zhu on 2018/10/11.
//  Copyright © 2018 Wangshu Zhu. All rights reserved.
//

import UIKit

class HomeScreenViewController: UIViewController, UITextFieldDelegate
{
    var query = TicketQuery()
    var routeNumber: String = ""

    @IBOutlet weak var originalText: UITextField! { didSet { originalText.delegate = self } }
    @IBOutlet weak var destinationText: UITextField! { didSet { destinationText.delegate = self } }
    @IBOutlet weak var dataPicker: UIDatePicker!
    
    @IBAction func subscribeButtonTouched(_ sender: UIButton) {
        sendSubscription()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    private func sendSubscription() {
        if let fromStationText = originalText.text, let toStationText = destinationText.text {
            let departureDate = dataPicker.date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let strDate = dateFormatter.string(from: departureDate)
            Station.fetchStationList()
            if let fromStationCode = Station.stationList[fromStationText], let toStationCode = Station.stationList[toStationText] {
                let route = Route(trainDate: strDate, fromStation: fromStationCode, toStation: toStationCode)
                print("\(route)")
                query.subscribe(to: route)
            } else {
                var alertView = UIAlertController()
                alertView.message = "无法获取站名，请输入正确的地名或站名"
                alertView.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alertView, animated: true)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}