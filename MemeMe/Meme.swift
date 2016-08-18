//
//  Meme.swift
//  MemeMe
//
//  Created by JeffChiu on 11/17/15.
//  Copyright Â© 2015 JeffChiu. All rights reserved.
//

import Foundation
import UIKit

// create the Meme struct and all its properties
struct Meme {
    var topText: String // for the top text
    var bottomText: String // for the bottom text
    var originalImg: UIImage // for the original image
    var memeImg: UIImage // for the memed image
    var font: UIFont // for the text font (for editing)
    var fontColor: UIColor // for the text color (for editing)
    var zoomScale: CGFloat // the zoom scale that was applied (for editing)
    var originalContentOffset: CGPoint // the content offset of the image in the scroll view (for editing)
    var bottomTextFieldCenter: CGPoint // center location of the bottom textfield (for editing)
    var topTextFieldCenter: CGPoint // center location of the top textfield (for editing)
    
    // initializer function
    init(topText: String, bottomText: String, original: UIImage, zoom: CGFloat, meme: UIImage, font: UIFont, fontColor: UIColor, offset: CGPoint, bottomTextCenter: CGPoint, topTextCenter: CGPoint){
        // set all the properties
        self.topText = topText
        self.bottomText = bottomText
        self.originalImg = original
        self.zoomScale = zoom
        self.memeImg = meme
        self.fontColor = fontColor
        self.font = font
        self.originalContentOffset = offset
        self.bottomTextFieldCenter = bottomTextCenter
        self.topTextFieldCenter = topTextCenter
    }
}