//
//  FontPickerViewController.swift
//  ColorPickerExample
//
//
//  Created by JeffChiu on 11/17/15.
//  Copyright Â© 2015 JeffChiu. All rights reserved.

import Foundation
import UIKit

/* This class handles the font picking table view. I copied and modified the ColorPickerController
 * Original code from: https://github.com/EthanStrider/iOS-Projects/tree/master/ColorPickerExample
*/
class FontPickerViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var delegate: ViewController? = nil
    var font: UIFont!
    
    // get an array of all the fonts
    // from: http://giordanoscalzo.tumblr.com/post/95900320382/print-all-ios-fonts-in-swift
    let fonts = UIFont.familyNames()
    
    // MARK: Table View Data Source
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fonts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FontCell")!
        // Set the text
        cell.textLabel?.text = self.fonts[indexPath.row]
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            let indexFont = self.fonts[indexPath.row]
            font = UIFont(name: indexFont, size: 40)
            delegate?.setTextFont(font!)
            self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
}