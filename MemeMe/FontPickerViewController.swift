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
    let fonts = UIFont.familyNames
    
    // MARK: Table View Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fonts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FontCell")!
        // Set the text
        cell.textLabel?.text = self.fonts[(indexPath as NSIndexPath).row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let indexFont = self.fonts[(indexPath as NSIndexPath).row]
            font = UIFont(name: indexFont, size: 40)
            delegate?.setTextFont(font!)
            self.dismiss(animated: false, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
}
