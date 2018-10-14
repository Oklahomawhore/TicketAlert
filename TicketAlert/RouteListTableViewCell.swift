//
//  RouteListTableViewCell.swift
//  TicketAlert
//
//  Created by Wangshu Zhu on 2018/10/12.
//  Copyright © 2018 Wangshu Zhu. All rights reserved.
//

import UIKit

class RouteListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var routeInfoLabel: UILabel!
    
    @IBOutlet weak var leftTicketStatusLabel: UILabel!
    
    @IBOutlet weak var midDateDisplayLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
