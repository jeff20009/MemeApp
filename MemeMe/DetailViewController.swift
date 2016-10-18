//
//  DetailViewController.swift
//  MemeMe
//
//
//  Created by JeffChiu on 11/17/15.
//  Copyright Â© 2015 JeffChiu. All rights reserved.


import Foundation
import UIKit

/* This class is used for the Detailed View.
*/

class DetailViewController: UIViewController {
    
    // Outlets
    @IBOutlet weak var imageView: UIImageView! // to display the Meme
    
    // Variables
    var meme: Meme! // for the meme that will be displayed
    var index: Int! // index for keeping track of the meme from the memes array
    
    var navController: UINavigationBar! //
    
    override func viewDidLoad() {
        // set the image
        imageView.image = meme.memeImg;
        
        // hide the tab bar
        self.tabBarController?.tabBar.isHidden = true
    }
    
    // handles back button being pressed
    @IBAction func goBack() {
        // pop to the root view controller
        navigationController?.popToRootViewController(animated: true)
    }
    
    // handles the edit button being pressed
    @IBAction func editMeme(_ sender: UIBarButtonItem) {
        
        // instatiate and present the edit view controller
        let editVC = storyboard?.instantiateViewController(withIdentifier: "EditView") as! ViewController
        present(editVC, animated: true, completion: {
            // call the function to set the meme to be edited in the edit view
            editVC.setForEditing(self.meme, index: self.index)
        })
    }
    
    // handles the trash button being pressed
    @IBAction func deleteMeme(){
        
        // obtain the memes object array from the AppDelegate
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        
        // remove the meme and go back one screen
        appDelegate.memes.remove(at: self.index)
        goBack()
    }
}
