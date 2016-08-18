//
//  CustomTableViewCell.swift
//  MemeMe
//
//
//  Created by JeffChiu on 11/17/15.
//  Copyright Â© 2015 JeffChiu. All rights reserved.


import Foundation
import UIKit

/* This class is used for Custom Table View Cells
*/
class CustomTableViewCell : UITableViewCell {

    // Outlets
    @IBOutlet var topText: UILabel! // top text
    @IBOutlet var bottomText: UILabel! // bottom text
    @IBOutlet var memeImage: UIImageView! // the meme image
    @IBOutlet weak var checkMark: UIImageView! // the checkmark that will appear when selected
    
    // Figured out to use awakeFromNib from:
    // http://stackoverflow.com/questions/25541786/custom-uitableviewcell-from-nib-in-swift
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // customize the way the image is displayed
        // in this case we are making a rounded image
        // Code from: http://stackoverflow.com/questions/25587713/how-to-set-imageview-in-circle-like-imagecontacts-in-swift-correctly
        
        memeImage.layer.borderWidth = 1.0
        memeImage.layer.masksToBounds = false
        memeImage.layer.borderColor = UIColor.whiteColor().CGColor
        memeImage.layer.cornerRadius = 10
        memeImage.clipsToBounds = true
    }
}