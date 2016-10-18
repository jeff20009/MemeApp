//
//  CollectionViewController.swift
//  MemeMe
//
//
//  Created by JeffChiu on 11/17/15.
//  Copyright Â© 2015 JeffChiu. All rights reserved.


import Foundation

import UIKit

/* This class is used for the Saved Memes Collection View
*/
class CollectionViewController: UICollectionViewController {
    
    @IBOutlet weak var leftBarButton: UIBarButtonItem! // left nav bar button
    @IBOutlet weak var rightBarButton: UIBarButtonItem! // right nav bar button
    @IBOutlet var memeCollectionView: UICollectionView! // the collection view itself
    
    var memes: [Meme]! // array to hold all the saved memes
    var isEditingMeme = false // flag for when editing memes (in this case just to delete one or more)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        // get memes from AppDelegate
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        memes = appDelegate.memes
        
        // set background color (had to be done here)
        memeCollectionView.backgroundColor = UIColor.orange
        
        // set initial properties
        rightBarButton.title = "Edit"
        self.tabBarController?.tabBar.isHidden = false
        memeCollectionView.allowsMultipleSelection = false
        
        // deselect all selected cells
        deselectAll()
    }
    
    // MARK: Collection View Functions
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memes.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MemeCollectionViewCell", for: indexPath) as! CustomCollectionViewCell
        
        let meme = memes[(indexPath as NSIndexPath).row]
        cell.memeImage.image = meme.memeImg
        
        return cell
    }
    
    // handle what happens when collection view memes are selected
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath:IndexPath)
    {
        // check for flag, make sure not in editing mode (when deleting memes)
        if(!isEditingMeme){
            
            // if not editing, show the meme detail view
            showDetailView((indexPath as NSIndexPath).row)
        }
        else {
            // if not, then we are editing, so we can select more than one cell.
            let cell = collectionView.cellForItem(at: indexPath) as! CustomCollectionViewCell
            
            // unhide the cells checkmark
            cell.checkMark.isHidden = false
        }
    }
    
    // When editing, we can deselect a meme, so that it will no longer be highlited
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CustomCollectionViewCell
        
        // hide the checkmark
        cell.checkMark.isHidden = true
    }
    
    // function that handles the deletion of the selected memes (when editing)
    func deleteMemes(){
        
        // get all the index paths for the selected items (if any have been selected)
        if let indexPaths = collectionView?.indexPathsForSelectedItems {
            
            // create the link to the app elegate, so we have access to
            // the memes object array
            let object = UIApplication.shared.delegate
            let appDelegate = object as! AppDelegate
            
            // iterate over all index paths
            for i in stride(from: (indexPaths.count - 1), through: 0, by: -1){
                // get the current indexPath
                let indexPath = indexPaths[i] 
                
                // remove the meme from the saved memes array (in App Delegate)
                appDelegate.memes.remove(at: (indexPath as NSIndexPath).row)
                
                // remove the memes from the class's copy of the memes array
                memes.remove(at: (indexPath as NSIndexPath).row)
                
                // remove the item from the collection view
                collectionView?.deleteItems(at: [indexPath])
            }
        }
    }
    
    // MARK: OTHER FUNCTIONS
    
    // function to show the detailed view controller
    func showDetailView(_ index: Int){
        
        // instantiate the view, set the properties and push
        let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        
        // set the meme to display and its index in the detailed view
        detailVC.meme = memes[index]
        detailVC.index = index
        
        // push the view controller into the view
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    // function to deselect all the selected rows
    func deselectAll(){
        
        // get all the index paths
        if let selectedRowPaths = memeCollectionView.indexPathsForSelectedItems {
            // iterate over each index path
            for indexPath in selectedRowPaths {
                // get the cell and deselect
                let cell = memeCollectionView.cellForItem(at: indexPath) as! CustomCollectionViewCell
                cell.checkMark.isHidden = true
                memeCollectionView.deselectItem(at: indexPath, animated: false)
            }
        }
    }
    
    // MARK: @IBAction Functions
    // handle right nav bar button presses
    // this is for when the "Edit Button is pressed"
    @IBAction func rightNavBarButtonAction(_ sender: UIBarButtonItem) {
        
        // check if in editing mode or not
        if(!isEditingMeme){
            
            // if not in editing, then turn flag on
            isEditingMeme = true
            memeCollectionView.allowsMultipleSelection = true
            
            // hide the tab bar
            self.navigationController?.tabBarController?.tabBar.isHidden = true
            
            // change button titles
            leftBarButton.title = "Delete"
            rightBarButton.title = "Cancel"
        }
        else {
            // else, already in editing mode
            
            // reset the button titles
            rightBarButton.title = "Edit"
            leftBarButton.title = "Back"
            
            // unhide the tab bar
            self.navigationController?.tabBarController?.tabBar.isHidden = false
            
            // reset editing flag
            isEditingMeme = false
            
            // deselect all selected rows
            deselectAll()
        }
    }
    
    // handle the left navigation button being pressed
    @IBAction func leftNavBarButtonAction(_ sender: UIBarButtonItem) {
        
        // check if we are editing or going back
        if(isEditingMeme){
            
            // if we are editing, then this button was pressed to delete the memes
            
            // delete the memes
            deleteMemes()
            
            // turn flag off
            isEditingMeme = false
            
            // reset button to display "Back"
            leftBarButton.title = "Back"
        }
        else {
            // button was pressed when it said "Back"
            
            // go back to the Edit View View Controller
            let editVC = storyboard?.instantiateViewController(withIdentifier: "EditView") as! ViewController
            present(editVC, animated: true, completion: nil)
        }
    }
}
