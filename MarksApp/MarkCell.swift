//
//  MarkCell.swift
//  MarksApp
//
//  Created by Patricia on 17/05/2020.
//  Copyright © 2020 IWEB. All rights reserved.
//

import UIKit

class MarkCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var markLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
