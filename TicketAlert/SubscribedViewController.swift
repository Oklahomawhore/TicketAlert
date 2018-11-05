//
//  SubscribedViewController.swift
//  TicketAlert
//
//  Created by Wangshu Zhu on 2018/10/13.
//  Copyright © 2018 Wangshu Zhu. All rights reserved.
//

import UIKit

class SubscribedViewController: UIViewController, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = TicketQuery.shared
            tableView.delegate = self
        }
    }
    
    private var ticketObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        tableView.reloadData()
        
        ticketObserver = NotificationCenter.default.addObserver(
            forName: Notification.Name("ticketIsAvailable"),
            object: TicketQuery.self,
            queue: OperationQueue.main,
            using: { (notification) in
                let alertView = UIAlertController()
                alertView.addAction(UIAlertAction(title: "OK", style: .default))
                alertView.message = "succesfully subscribed!"
                self.present(alertView, animated: true)
        })
        
        
        //retrieve data from database
        do {
            let url: URL = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let routeUrl = url.appendingPathComponent("routeList").appendingPathExtension("js")
            let searchUrl = url.appendingPathComponent("searchParameters").appendingPathExtension("js")
            
            guard let routeListObject = try? Data(contentsOf: routeUrl) else {
                return
            }
            guard let searchListObject = try? Data(contentsOf: searchUrl) else {
                return
            }
            
            
            TicketQuery.shared.routeList = try JSONDecoder().decode([Route].self, from: routeListObject)
            TicketQuery.shared.searchParmeters = try JSONDecoder().decode([Route: [String: Bool]].self, from: searchListObject)
            print(routeListObject)
        } catch let nserror as NSError {
            print("SubscribedViewController database operation faild code line 43")
            print("error message: \(nserror.debugDescription)")
        } catch  {
            print("Error occured reading database in object: SubscribedViewController")
        }
        
        
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
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
