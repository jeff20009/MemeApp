//
//  TableViewController.swift
//  MemeMe
//
//
//  Created by JeffChiu on 11/17/15.
//  Copyright Â© 2015 JeffChiu. All rights reserved.

import UIKit

/* This class is used for the Sent Memes Table View Controller
*/
class TableViewController: UITableViewController {
    
    // Outlets
    @IBOutlet weak var leftBarButton: UIBarButtonItem! // left nav bar button
    @IBOutlet weak var rightBarButton: UIBarButtonItem! // right nav bar button
    @IBOutlet var memeTableView: UITableView! // the table view itself
    
    var memes: [Meme]! // array of memes
    var delegate: ViewController? = nil // the delegate will be the Edit View ViewController
    var isEditingMeme = false // flag to determine if in editing mode (for deletion of multiple memes)
    
    // link to objects in AppDelegate
    let object = UIApplication.shared.delegate
    var appDelegate: AppDelegate!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        
        // get the memes from app delegate
        appDelegate = object as! AppDelegate
        memes = appDelegate.memes
        
        // if no memes are saved, go to edit view
        if(memes.count == 0){
            
            // to remove a warning, we use dispatch_async
            // this is because the TabBarController tries to display both the table view and then
            // the edit view in such short time
            // from: http://stackoverflow.com/questions/8563473/unbalanced-calls-to-begin-end-appearance-transitions-for-uitabbarcontroller
            
            if (self.view) != nil {
                DispatchQueue.main.async {
                    self.goToEditView()
                }
            }
        }
        
        // set initial properties
        rightBarButton.title = "Edit"
        self.tabBarController?.tabBar.isHidden = false
        memeTableView.allowsMultipleSelection = false
        
        // deselect all selected rows
        deselectAll()
    
    }
    
    // MARK: TableView Functions
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.memes.count
    }
    
    // create the cells
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // deque a cell using custom table view cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemeTableCell") as! CustomTableViewCell
        
        // set the meme
        let meme = self.memes[(indexPath as NSIndexPath).row]
        
        // Set the text and image
        cell.topText.text = meme.topText
        cell.bottomText.text = meme.bottomText
        cell.memeImage.image = meme.memeImg
        cell.checkMark.isHidden = true
        
        return cell
    }
    
    // handle selection of a cell
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // check flag, if not in editing mode (selectint multiple cells)
        if(!isEditingMeme){
            // show the detail view
            showDetailView((indexPath as NSIndexPath).row)
        }
        else {
            // else, we are editing, unhide the cell's checkmark
            let cell = tableView.cellForRow(at: indexPath) as! CustomTableViewCell
            cell.checkMark.isHidden = false
        }
        
        // memeTableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    /// Mark - TableView this function handles the swipe to delete funcionality of a cell
    // from: http://www.ioscreator.com/tutorials/delete-rows-table-view-ios8-swift
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            memes.remove(at: (indexPath as NSIndexPath).row)
            appDelegate.memes.remove(at: (indexPath as NSIndexPath).row)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
        }
    }
    
    // hande deselection of rows
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath){
        
        // hide the checkmark of deselected row
        let cell = tableView.cellForRow(at: indexPath) as! CustomTableViewCell
        cell.checkMark.isHidden = true
    }
    
    // MARK: OTHER FUNCTIONS
    // function to show the detailed view controller
    func showDetailView(_ index: Int){
        
        // intantiate the view controller
        let detailController = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        
        // set the views properties
        detailController.meme = memes[index]
        detailController.index = index
        
        // push the view
        self.navigationController?.pushViewController(detailController, animated: true)
    }
    
    // function to delete multiple selection of memes
    func deleteMemes(){
        
        /* get all the index paths for selected rows
         * figured it out after reading documentation at:
         * https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableView_Class/
         * and: http://stackoverflow.com/questions/29387462/how-to-delete-a-cell-from-a-uitableview-with-multi-section-in-swift
         */
        if let indexPaths = tableView.indexPathsForSelectedRows {
            
            // iterate over each selected row
            for i in stride(from: (indexPaths.count - 1), through: 0, by: -1) {

            //for(var i = indexPaths.count - 1; i >= 0; i -= 1){
                
                // get the index path
                let indexPath = indexPaths[i] 
                
                // remove from the saved memes array
                appDelegate.memes.remove(at: (indexPath as NSIndexPath).row)
                
                // remove from the class's local memes array
                memes.remove(at: (indexPath as NSIndexPath).row)
                
                // remove the row from the table view
                memeTableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            }
        }
    }
    
    // go to the edit view View Controller
    func goToEditView(){
        let editVC = storyboard?.instantiateViewController(withIdentifier: "EditView") as! ViewController
        
        // Had warnings when presenting the view controller, removed by reading:
        // http://stackoverflow.com/questions/19890761/warning-presenting-view-controllers-on-detached-view-controllers-is-discourage
        // http://stackoverflow.com/questions/8563473/unbalanced-calls-to-begin-end-appearance-transitions-for-uitabbarcontroller
        
        DispatchQueue.main.async {
            // self.navigationController?.tabBarController?.presentViewController(editVC, animated: false, completion: nil)
            self.present(editVC, animated: false, completion: nil)
        }
    }
    
    // function to deselect all the selected rows
    func deselectAll(){
        
        // get all the index paths
        if let selectedRowPaths = memeTableView.indexPathsForSelectedRows {
            // iterate over each index path
            for indexPath in selectedRowPaths {
                // get the cell and deselect
                let cell = memeTableView.cellForRow(at: indexPath) as! CustomTableViewCell
                cell.checkMark.isHidden = true
                memeTableView.deselectRow(at: indexPath, animated: false)
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
            memeTableView.allowsMultipleSelection = true
            
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
    
    // handles the left nav bar actions
    @IBAction func leftNavBarButtonAction(_ sender: UIBarButtonItem) {
        
        // check if in editing mode
        if(isEditingMeme){
            
            // if editing, then delete the selected memes
            deleteMemes()
            
            // turn flag off
            isEditingMeme = false
            
            // reset button title
            leftBarButton.title = "Back"
        }
        else {
            // else, "Back" is being displayed, so go back to Edit View
            goToEditView()
        }
    }
}
