//
//  ChosenRestaurantPhotoCell.swift
//  Eat
//
//  Created by Henry Jones on 2018-03-17.
//  Copyright © 2018 launchpad. All rights reserved.
//

import UIKit

class ChosenRestaurantPhotoCell: UITableViewCell {


  @IBOutlet weak var restaurantPhoto: UIImageView!

  func configure(restaurant: Restaurant) {
      if let url = URL(string: restaurant.imageUrl) {
        restaurantPhoto.kf.setImage(with: url)
      } else {
        restaurantPhoto.image = #imageLiteral(resourceName: "default_restaurant_photo")
      }
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
