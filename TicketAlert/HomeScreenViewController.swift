//
//  HomeScreenViewController.swift
//  TicketAlert
//
//  Created by Wangshu Zhu on 2018/10/11.
//  Copyright © 2018 Wangshu Zhu. All rights reserved.
//

import UIKit
import SimpleCheckbox
import JBDatePicker

class HomeScreenViewController: UIViewController, UITextFieldDelegate, JBDatePickerViewDelegate
{
    
    
    var query = TicketQuery.shared
    
    var routeNumber: String = ""
    //MARK: - user preference outlets
    @IBOutlet weak var gdOnlyTag: Checkbox!
    @IBOutlet weak var edzTag: Checkbox!
    @IBOutlet weak var swztdzTag: Checkbox!
    @IBOutlet weak var ywTag: Checkbox!
    @IBOutlet weak var wzTag: Checkbox!
    @IBOutlet weak var rwTag: Checkbox!
    @IBOutlet weak var ydzTag: Checkbox!
    @IBOutlet weak var dwTag: Checkbox!
    @IBOutlet weak var yzTag: Checkbox!
    @IBOutlet weak var rzTag: Checkbox!
    @IBOutlet weak var gjrwTag: Checkbox!
    

    @IBOutlet weak var originalText: UITextField! { didSet { originalText.delegate = self } }
    @IBOutlet weak var destinationText: UITextField! { didSet { destinationText.delegate = self } }
    @IBOutlet weak var dataPicker: UIDatePicker!
    
    @IBOutlet weak var datePicker: JBDatePickerView!
    
    @IBOutlet weak var departureDateLabel: UILabel! 
    @IBOutlet weak var presentedMonthLabel: UILabel!
    @IBOutlet weak var backgroundView: UIView! {
        didSet {
            backgroundView.layer.cornerRadius = 16.0
            backgroundView.layer.shadowOffset = CGSize(width: -15.0, height: 20.0)
            backgroundView.layer.shadowRadius = 16.0
            backgroundView.layer.shadowOpacity = 0.6
        }
    }
    
    
    // MARK:- date picker delegate methods

    private var datePicked = Date()
    private var dateFormatter = DateFormatter()
    
    func didSelectDay(_ dayView: JBDatePickerDayView) {
        // does nothing
        datePicked = dayView.date ?? Date()
        
        let selectedDate = dateFormatter.string(from: datePicked)
        
        departureDateLabel.text = "出发日期：\(selectedDate)"
    }
    func didPresentOtherMonth(_ monthView: JBDatePickerMonthView) {
        if presentedMonthLabel != nil {
            presentedMonthLabel.text = monthView.monthDescription
        }
    }
    
    @IBAction func subscribeButtonTouched(_ sender: UIButton) {
        sendSubscription()
    }
    //MARK: - textfield delegate methods
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    //MARK: - logic funs
    private func sendSubscription() {
        if let fromStationText = originalText.text, let toStationText = destinationText.text {
            let departureDate = datePicked
            /*
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let strDate = dateFormatter.string(from: departureDate)
             */
            
            if let fromStationCode = Station.stationList[fromStationText], let toStationCode = Station.stationList[toStationText] {
                let route = Route(trainDate: departureDate, fromStation: fromStationCode, toStation: toStationCode)
                if !query.routeList.contains(route) {
                    var paraMeters = [String: Bool]()
                    paraMeters = [
                        "GJRW" : gjrwTag.isChecked,
                        "RW" : rwTag.isChecked,
                        "RZ" : rzTag.isChecked,
                        "WZ" : wzTag.isChecked,
                        "YW" : ywTag.isChecked,
                        "YZ" : yzTag.isChecked,
                        "EDZ" : edzTag.isChecked,
                        "YDZ" : ydzTag.isChecked,
                        "SWZTDZ" : swztdzTag.isChecked,
                        "DW" : dwTag.isChecked
                    ]
                    print(paraMeters)
                    query.subscribe(to: route, withParmeters: paraMeters)
                    
                } else {
                    let alertView = UIAlertController()
                    alertView.message = "这个路线已订阅，请在订阅标签查看"
                    alertView.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alertView, animated: true)
                }
                
            } else {
                let alertView = UIAlertController()
                alertView.message = "无法获取站名，请输入正确的地名或站名"
                alertView.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alertView, animated: true)
            }
        }
    }
    
    @objc private func handleTapOnBackground(_ sender: UITapGestureRecognizer) {
        switch sender.state {
        case .ended:
            let touchPoint = sender.location(in: view)
            view.endEditing(true) //  one line does the job. Does not need to check if outside textfield.
            
        default:
            break
        }
        
    }
    
    private var subscriptionObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subscriptionObserver = NotificationCenter.default.addObserver(
            forName: Notification.Name("subcribeSuccess"),
            object: TicketQuery.self,
            queue: OperationQueue.main,
            using: { (notification) in
                let alertView = UIAlertController()
                alertView.addAction(UIAlertAction(title: "OK", style: .default))
                guard let userInfo = notification.userInfo as? [String : Bool] else { return }
                guard let message = userInfo["successKey"] else { return }
                alertView.message = message ? "succesfully subscribed!":"subscribe success but returned network issue!"
                self.present(alertView, animated: true)
        })
        /*
        let today = NSDate() as Date
        let calendar = Calendar.current
        var comps = DateComponents()
        comps.day = 30
        let maxDate = calendar.date(byAdding: comps, to: today as Date)
        dataPicker.minimumDate = today
        dataPicker.maximumDate = maxDate
        dataPicker.locale = Locale(identifier: "zh_CN")
        print(Locale.current)
        dataPicker.calendar = calendar
        */
        Station.fetchStationList()
        
        datePicker.delegate = self
        
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .medium
        
        dateFormatter.locale = Locale(identifier: "zh_CN")
        
        departureDateLabel.text = "出发日期：\(dateFormatter.string(from: Date()))"
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapOnBackground(_:)))
        view.addGestureRecognizer(tapGesture)
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

//MARK: - UIView find first responder extension
extension UIView {
    var firstResponder: UIView? {
        guard !isFirstResponder else { return self }
        
        for subview in subviews {
            if let firstResponder = subview.firstResponder {
                return firstResponder
            }
        }
        
        return nil
    }
}
