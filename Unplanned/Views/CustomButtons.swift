//
//  CustomButtons.swift
//  Unplanned
//
//  Created by True Metal on 5/26/16.
//  Copyright © 2016 matata. All rights reserved.
//

import Foundation
import UIKit

class SolidButton : UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.5)
    }
}
