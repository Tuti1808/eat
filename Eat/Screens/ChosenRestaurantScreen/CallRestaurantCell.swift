//
//  CallRestaurantCell.swift
//  Eat
//
//  Created by Henry Jones on 2018-03-21.
//  Copyright © 2018 launchpad. All rights reserved.
//

import UIKit

class CallRestaurantCell: UITableViewCell {


  @IBOutlet weak var callRestaurantLabel: UILabel!
  @IBOutlet weak var phoneNumber: UILabel!
  @IBOutlet weak var phoneIcon: UIImageView!

    func configure(restaurant: Restaurant) {
      callRestaurantLabel.text = "Call restaurant"
      callRestaurantLabel.font = UIFont.systemFont(ofSize: 16)
      callRestaurantLabel.textColor = UIColor(red: 0.42, green: 0.44, blue: 0.6, alpha: 1)
      phoneNumber.text = restaurant.phone
      phoneNumber.font = UIFont.systemFont(ofSize: 11)
      phoneNumber.textColor = UIColor(red: 0.62, green: 0.62, blue: 0.75, alpha: 1)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}