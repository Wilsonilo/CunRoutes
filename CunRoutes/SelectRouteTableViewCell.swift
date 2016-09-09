//
//  SelectRouteTableViewCell.swift
//  CunRoutes
//
//  Created by Wilson Muñoz on 7/9/16.
//  Copyright © 2016 Wilson Muñoz. All rights reserved.
//

import UIKit

class SelectRouteTableViewCell: UITableViewCell {

    @IBOutlet weak var ButtonRadio: RadioButton!
    @IBOutlet weak var LabelName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        //ButtonRadio.selected = true

    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
