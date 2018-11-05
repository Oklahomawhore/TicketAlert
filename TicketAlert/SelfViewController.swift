//
//  SelfViewController.swift
//  TicketAlert
//
//  Created by Wangshu Zhu on 2018/10/21.
//  Copyright © 2018 Wangshu Zhu. All rights reserved.
//

import UIKit
import LoginController

class SelfViewController: UITableViewController, LoginViewControllerDelegate {
    
    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    private var userIsLogin = false

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                
                break
            default:
                break
            }
        } else {
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if !userIsLogin {
            let loginVC = LoginViewController()
            loginVC.backgroundColor = UIColor.lightGray
            loginVC.delegate = self
            self.present(loginVC, animated: true)
        }
        // Do any additional setup after loading the view.
    }
    
    func signin(loginViewController: LoginViewController) {
        // connect with server to verify username and password
        
        
        loginViewController.dismiss(animated: true) {
            self.userIsLogin = true
            
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Log12306" {
            let vc = segue.destination
            
        } else if segue.identifier == "About" {
            
        } else if segue.identifier == "ChangePhon" {
            
        }
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    

}
