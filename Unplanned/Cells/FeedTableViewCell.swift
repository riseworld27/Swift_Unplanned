//
//  FeedTableViewCell.swift
//  Unplanned
//
//  Created by matata on 28.05.16.
//  Copyright © 2016 matata. All rights reserved.
//

import UIKit

class FeedTableViewCell: UITableViewCell {

    @IBOutlet weak var ivImageFeed: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!

    override var frame: CGRect {
        get {
            return super.frame
        }
        set (newFrame) {
            let inset: CGFloat = 60
            var frame = newFrame
            frame.origin.x += inset
            frame.size.width -= 2 * inset
            super.frame = frame
        }
    }
}
