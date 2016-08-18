//
//  ViewController.swift
//  MemeMe
//
//
//  Created by JeffChiu on 11/17/15.
//  Copyright © 2015 JeffChiu. All rights reserved.


import UIKit

/* This class is used for the Edit View screen. 
 * The edit view screen allows the user to pick an image to be memed from 3 sources:
 * 1) Photo Album
 * 2) Templates
 * 3) From Camera
 *
 * Once the image is picked, the user can enlarge (zoom) and pan the image so that it fits the screen
 * A scroll view is used for this. This way, the image is cropped to the user's liking.
 *
 * The user can also change change the font and the color of the text fields. They can then share the meme.
 * Sharing the meme also temporarly saves it.
 *
 * This ViewController is also used when editing a previously saved meme.
*/

class ViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UIPopoverPresentationControllerDelegate, UIScrollViewDelegate {
    
    // Outlets
    @IBOutlet weak var navTitle: UINavigationItem! // nav bar title
    @IBOutlet weak var colorPick: UIButton! // color picker button
    @IBOutlet weak var cameraButton: UIBarButtonItem! // camera picker button
    @IBOutlet weak var mainToolbar: UIToolbar! // bottom tool bar
    @IBOutlet weak var navigationBar: UINavigationBar! // navigation bar
    @IBOutlet weak var leftBarButton: UIBarButtonItem! // left nav bar button
    @IBOutlet weak var rightBarButton: UIBarButtonItem! // right nav bar button
    @IBOutlet weak var scrollView: UIScrollView! // the scroll view
    
    // Variables
    var editingBottom = false // flag for when editing the bottom text
    var memeImg: UIImage! // the meme image
    var memes: [Meme]! // array of memes
    var editingIndex:Int! // index for determining what meme is being edited from detail view
    var isEditingMeme = false // flag to know if we are editing
    var topTextField: UITextField! // top textfield
    var bottomTextField: UITextField! // bottom textfield
    var imageView = UIImageView() // the image view to display the selected image
    var bottomTextLocation = CGPoint(x: 0, y: 0)
    
    // =========================================================================
    // MARK: Overriden View Functions
    // BELOW ARE ALL THE FUNCTIONS THAT ARE RELATED TO THE VIEW
    // =========================================================================
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // subscribe to keyboard notifications
        self.subscribeToKeyboardNotifications()
        
        // disable camera button in simulator
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // unsubscribe from keyboard functions
        self.unsubscribeFromKeyboardNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get memes array from AppDelegate
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        memes = appDelegate.memes
        
        // set the scrollView delegate
        scrollView.delegate = self
        
        // add imageView to the scrollView
        imageView.frame = CGRectMake(0, 0, scrollView.frame.size.width, scrollView.frame.size.width)
        
        // enable user interactions
        imageView.userInteractionEnabled = true
        
        // add imageView
        scrollView.addSubview(imageView)
        
        // set text field attributes
        let memeTextAttributes = [
            NSStrokeColorAttributeName : UIColor.blackColor(),
            NSForegroundColorAttributeName :UIColor.whiteColor(),
            NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName : NSNumber(float: -3.0)
        ]
        
        // rectangle frame for the textfields
        let rectangle = CGRect(x: 0, y: 0, width: 200, height: 40)
        
        // set texfield properties
        topTextField = UITextField(frame: rectangle)
        bottomTextField = UITextField(frame: rectangle)
        topTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.defaultTextAttributes = memeTextAttributes
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        topTextField.delegate = self
        bottomTextField.delegate = self
        topTextField.tag = 1
        bottomTextField.tag = 2
        topTextField.textAlignment = .Center
        bottomTextField.textAlignment = .Center
        
        topTextField.adjustsFontSizeToFitWidth = true
        bottomTextField.adjustsFontSizeToFitWidth = true
        
        topTextField.minimumFontSize = 8
        bottomTextField.minimumFontSize = 8
        
        // set autocapitalization for textfields
        // from: http://stackoverflow.com/questions/21092182/uppercase-characters-in-uitextfield
        topTextField.autocapitalizationType = UITextAutocapitalizationType.AllCharacters
        topTextField.autocapitalizationType = UITextAutocapitalizationType.AllCharacters

        topTextField.center.x = self.view.center.x
        topTextField.center.y = self.view.frame.origin.y + 150
        bottomTextField.center.x = self.view.center.x
        bottomTextField.center.y = self.view.frame.origin.y + self.view.frame.height - 150
        
        // add texfields to subview
        view.addSubview(topTextField)
        view.addSubview(bottomTextField)
        
        // set nav bar titles and button states
        navTitle.title = "MemeMe"
        rightBarButton.title = "Back"
        
        // disable share button and back button if no memes are present
        if(memes.count == 0) {
            leftBarButton.enabled = false
            rightBarButton.enabled = false
        }
        
        // add gesture recogizers so that the textfields can me moved with the finger
        // from: http://stackoverflow.com/questions/24758671/swift-moving-and-releasing-object-with-touch
        let dragBottomTextField = UIPanGestureRecognizer(target: self, action:#selector(ViewController.dragText(_:)))
        bottomTextField.addGestureRecognizer(dragBottomTextField)
        
        let dragTopTextField = UIPanGestureRecognizer(target: self, action:#selector(ViewController.dragText(_:)))
        topTextField.addGestureRecognizer(dragTopTextField)
        
        // add gesture recognizer for tapping the screen. This is to dismiss the keyboard when 
        // tapping. This will also be used to stop editing a texfield when screen is tapped. 
        // from: http://stackoverflow.com/questions/5306240/iphone-dismiss-keyboard-when-touching-outside-of-uitextfield
        let tapScreen = UITapGestureRecognizer(target: self, action: #selector(ViewController.tapScreen))
        self.view.addGestureRecognizer(tapScreen)
        
    }
    
    // =========================================================================
    // MARK: Gesture Recognizer Related Functions
    // BELOW ARE ALL THE FUNCTIONS THAT ARE RELATED TO THE GESTURE RECOGNIZERS
    // =========================================================================
    
    // handle the tapped screen
    // from: http://stackoverflow.com/questions/5306240/iphone-dismiss-keyboard-when-touching-outside-of-uitextfield
    func tapScreen(){
        topTextField.resignFirstResponder()
        bottomTextField.resignFirstResponder()
    }
    
    // handle the dragging of text
    // from: http://stackoverflow.com/questions/24758671/swift-moving-and-releasing-object-with-touch
    func dragText(recognizer: UIPanGestureRecognizer) {
        
        // determine what texfield was dragged and set it to textField
        let textField = (recognizer.view?.tag == 2) ? bottomTextField : topTextField
        
        // obtain the location of the recognizer as a point
        let point = recognizer.locationInView(self.view)
        
        // set the textfield's location to this point
        textField.center.x = point.x
        
        // only allow textfields to move in between the nav bar and the tool bar
        if(!(point.y > self.view.frame.height - 64) && !(point.y < 84)){
            textField.center.y = point.y
        }
    }
    
    // =========================================================================
    // MARK: ScrollView Related Functions
    // BELOW ARE ALL THE FUNCTIONS THAT ARE RELATED TO THE SCROLL VIEW
    // MOST CODE WAS OBTAINED AND MODIFIED FROM LOOKING AT: https://www.youtube.com/watch?v=hz9pMw4Y2Lk
    // =========================================================================
    
    // set the scrollView
    // this function sets the various properties of the scrollview (for zooming and content size) based on the image that the imageView is displaying.
    func setScrollView(){
        let image = imageView.image
        imageView.contentMode = UIViewContentMode.Center
        imageView.frame = CGRectMake(0, 0, image!.size.width, image!.size.height)
        
        scrollView.contentSize = image!.size
        
        // zoom factors
        let scrollViewFrame = scrollView.frame
        let scaleWidth = scrollViewFrame.size.width / scrollView.contentSize.width
        let scaleHeight = scrollViewFrame.size.height / scrollView.contentSize.height
        
        // get minimum scale
        let minScale = min(scaleHeight, scaleWidth)
        
        scrollView.minimumZoomScale = minScale
        scrollView.maximumZoomScale = 2
        scrollView.zoomScale = minScale
    }
    
    // center the scroll view contents
    func centerScrollViewContents(){
        
        // get the bounds and the frame of the contents
        let boundsSize = scrollView.bounds.size
        var contentsFrame = imageView.frame
        
        if(contentsFrame.size.width < boundsSize.width){
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2
        }
        else {
            contentsFrame.origin.x = 0
        }
        
        if(contentsFrame.size.height < boundsSize.height){
            contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2
        }
        else {
            contentsFrame.origin.y = 0
        }
        
        imageView.frame = contentsFrame
        
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        centerScrollViewContents()
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    // =========================================================================
    // MARK: Keyboard Related Functions
    // BELOW ARE ALL THE FUNCTIONS THAT ARE RELATED TO THE KEYBOARD
    // =========================================================================
    
    // subscribe to keyboard notifications
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.keyboardWillShow(_:))    , name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.keyboardWillHide(_:))    , name: UIKeyboardWillHideNotification, object: nil)
    }
    
    // unsubscribe to keyboard notifications
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    // function to move the view and its contents up when the keyboard is shown
    func keyboardWillShow(notification: NSNotification) {
        // check that we are only editing the bottom textfield
        if(editingBottom){
            // move view up
            self.view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    // function that moves the view and its contents back down when the keyboard is hidden
    func keyboardWillHide(notification: NSNotification) {
        // check that we are only editing the bottom textfield
        if(editingBottom){
            // move view down
            self.view.frame.origin.y += getKeyboardHeight(notification)
        }
        // reset flag
        editingBottom = false
    }
    
    // function that gets the height of the keyboard
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    // =========================================================================
    // MARK: Textfield Protocol Functions
    // BELOW ARE ALL THE FUNCTIONS THAT ARE RELATED TO THE TEXTFIELDS
    // =========================================================================
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        // Force only upper case letters
        // Used a combination of the following sources:
        // Source for basic code : http://stackoverflow.com/questions/21092182/uppercase-characters-in-uitextfield
        // Source for help with swift code: http://stackoverflow.com/questions/25241188/get-a-range-from-a-string
        // Source that helped with using NSString: http://oleb.net/blog/2014/07/swift-strings/
        
        let textFieldText = textField.text! as NSString
        
        if let lowCharRange = string.rangeOfCharacterFromSet(NSCharacterSet.lowercaseLetterCharacterSet()) {
            
            textField.text = textFieldText.stringByReplacingCharactersInRange(range, withString: string.uppercaseString)
            
            
            return false
        }
        else {
            return true
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        // If the text is either TOP of BOTTOM, remove when editing
        if(textField.text == "TOP"){
            textField.text = ""
        }
        else if(textField.text == "BOTTOM"){
            textField.text = ""
        }
        
        // set editing bottom flag to true when editing bottom textfield
        if(textField.tag == 2){
            editingBottom = true
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        // If text fields are left empty after editing, replace contents with default text
        if(textField.text == ""){
            
            textField.text = "BOTTOM"
            
            if(textField.tag == 1){
                textField.text = "TOP"
            }
        }
        
        // make sure text is uppercase
        textField.text = textField.text!.uppercaseString
        
        textField.resignFirstResponder()
    }
    
    // =========================================================================
    // MARK: Image Picking Functions
    // BELOW ARE ALL THE FUNCTIONS THAT ARE RELATED TO PICKING IMAGES
    // =========================================================================
    
    // function for the imagePicker controller
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]){
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = image
            setScrollView()
            centerScrollViewContents()
            leftBarButton.enabled = true
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // pick image from photo library
    func pickImage() {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(pickerController, animated: true, completion: nil)
    }

    // =========================================================================
    // MARK: Generating and Saving Memes Functions
    // BELOW ARE ALL THE FUNCTIONS THAT ARE RELATED TO GENERATING AND SAVING MEMES
    // =========================================================================
    
    func save(activityType:String?, completed: Bool, returnedItems: [AnyObject]?, error: NSError?) {
        //Create the meme
        if completed {
            
            // create the meme
            let meme = Meme(
                topText: topTextField.text!,
                bottomText: bottomTextField.text!,
                original: imageView.image!,
                zoom: self.scrollView.zoomScale,
                meme: memeImg,
                font: topTextField.font!,
                fontColor: topTextField.textColor!,
                offset: scrollView.contentOffset,
                bottomTextCenter: bottomTextField.center,
                topTextCenter: topTextField.center
            )
            
            // Add it to the memes array in the Application Delegate
            let object = UIApplication.sharedApplication().delegate
            let appDelegate = object as! AppDelegate
            
            // check if this is not a meme that was previously saved and we are editing
            if(!isEditingMeme){
                // if not editing, append
                appDelegate.memes.append(meme)
            }
            else
            {
                // if editing, replace the previous meme with this new edited one
                appDelegate.memes[editingIndex] = meme
                
                // set the editing flag to false
                isEditingMeme = false
            }
            
            // go to the tab bar view
            goToTabBarView()
        }
    }
    
    // generate the memed image
    func generateMemedImage() -> UIImage {
        
        // this additive variable is based on the screen orientation
        var additive = CGFloat(64.0)
        
        if(UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation)){
            additive = 44
        }
        
        // hide nav bar and tool bar
        mainToolbar.hidden = true
        navigationBar.hidden = true
        
        // get the scroll views frame
        let frame = scrollView.frame
        
        // generate the memed image to be saved
        UIGraphicsBeginImageContext(frame.size)
        
        // this rectangle will only cover the parts of the screen that we want as an image
        let rectangle = CGRectMake(
            scrollView.frame.origin.x,
            self.scrollView.frame.origin.y - 44 - additive - 20,
            self.scrollView.frame.width,
            self.scrollView.frame.height + additive + 44
        )
        
        self.view.drawViewHierarchyInRect(rectangle, afterScreenUpdates: true)
        
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // show the toolbar and nav bar
        mainToolbar.hidden = false
        navigationBar.hidden = false
        
        return memedImage
    }
    
    // =========================================================================
    // MARK: Functions When Editing a Saved Meme
    // =========================================================================
    // function to set the screen with the meme to be edited
    func setForEditing(meme: Meme, index: Int){
        // set the image and textfields
        imageView.image = meme.originalImg
        setTextFont(meme.font)
        setTextColor(meme.fontColor)
        bottomTextField.text = meme.bottomText
        topTextField.text = meme.topText
        
        // set textfield locations
        bottomTextField.center = meme.bottomTextFieldCenter
        topTextField.center = meme.topTextFieldCenter
        
        // set the image to display correctly in the scroll view
        setScrollView()
        scrollView.zoomScale = meme.zoomScale
        
        // set contents offset so that image in imageView is at "same"
        // position as the original saved image
        // from: https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIScrollView_Class/#//apple_ref/occ/instp/UIScrollView/contentOffset
        scrollView.contentOffset = meme.originalContentOffset
        
        // set the editing flag and the index for the meme being edited
        isEditingMeme = true
        editingIndex = index
        
        // set the button to display cancel, if the user wants to cancel editing
        rightBarButton.title = "Cancel"
    }
    
    // =========================================================================
    // MARK: Other Functions
    // BELOW ARE ALL THE OTHER FUNCTIONS USED
    // =========================================================================
    
    // Override the iPhone behavior that presents a popover as fullscreen
    // Used with the font and color pickers
    // From: https://github.com/EthanStrider/iOS-Projects/tree/master/ColorPickerExample
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        // Return no adaptive presentation style, use default presentation behaviour
        return .None
    }
    
    // set the color of the textfields and the color picker button
    func setTextColor (color: UIColor) {
        // set texfield colors
        topTextField.textColor = color
        bottomTextField.textColor  = color
        
        // set the color of the colorpicker button
        colorPick.setTitleColor(color, forState: UIControlState.Normal)
    }
    
    // set the textfield fonts
    func setTextFont(font: UIFont){
        topTextField.font = font
        bottomTextField.font = font
    }
    
    // go to the tab view
    func goToTabBarView(){
        let tabBarVC = storyboard?.instantiateViewControllerWithIdentifier("tabBarView") as! UITabBarController
        presentViewController(tabBarVC, animated: false, completion: nil)
    }
    
    // show a template image in the image view
    func showTemplate(image: UIImage){
        imageView.image = image
        setScrollView()
    }
    
    // view the templates picker table view
    func viewTemplates() {
        let templatesVC = storyboard?.instantiateViewControllerWithIdentifier("TemplatesTableView") as! TemplatesTableViewController
        templatesVC.delegate = self
        presentViewController(templatesVC, animated: false, completion: nil)
    }
    
    // show an alert
    func showAlert(title: String, message: String){
        let alertController = UIAlertController(title: title, message:
            message, preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // =========================================================================
    // MARK: @IBAction Functions
    // BELOW ARE ALL THE IBACTION FUNCTIONS
    // =========================================================================
    
    // handle the rigt bar button when canceling the editing of a saved meme
    @IBAction func handleRightBarButton(sender: UIBarButtonItem) {
        // set title and go back to the tab bar view
        goToTabBarView()
    }
    
    // show the pick image choice when the album button is pressed
    // http://www.ioscreator.com/tutorials/action-sheet-tutorial-ios8-swift
    @IBAction func pickImageChoices(){
        
        // create a new action sheet alert
        let pickAlert = UIAlertController(title: "Choose Source", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        // photo album choice
        pickAlert.addAction(UIAlertAction(title: "Photo Album", style: .Default, handler: { (action: UIAlertAction) in
            // show the photo album
            self.pickImage()
        }))
        
        // template image choice
        pickAlert.addAction(UIAlertAction(title: "Meme Templates", style: .Default, handler: { (action: UIAlertAction) in
            // show templates table view
            self.viewTemplates()
        }))
        
        // present the action sheet
        presentViewController(pickAlert, animated: true, completion: nil)
    }
    
    // pick image from camera when camera button is pressed
    @IBAction func pickAnImageFromCamera (sender: UIBarButtonItem) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    // handle the color picker button
    // from: https://github.com/EthanStrider/iOS-Projects/tree/master/ColorPickerExample
    @IBAction func colorPickerButton(sender: UIButton) {
        
        let popoverVC = storyboard?.instantiateViewControllerWithIdentifier("colorPickerPopover") as! ColorPickerViewController
        
        popoverVC.modalPresentationStyle = .Popover
        
        popoverVC.preferredContentSize = CGSizeMake(284, 446)
        
        if let popoverController = popoverVC.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = CGRect(x: 0, y: 0, width: 85, height: 30)
            popoverController.permittedArrowDirections = .Any
            popoverController.delegate = self
            popoverVC.delegate = self
        }
        
        presentViewController(popoverVC, animated: false, completion: nil)
        
    }
    
    // handle font picker button
    // used modified code from: https://github.com/EthanStrider/iOS-Projects/tree/master/ColorPickerExample
    @IBAction func fontPickerButton(sender: UIButton) {
        
        let popoverVC = storyboard?.instantiateViewControllerWithIdentifier("fontPickerPopover") as! FontPickerViewController
        
        popoverVC.modalPresentationStyle = .Popover
        
        popoverVC.preferredContentSize = CGSizeMake(284, 446)
        
        if let popoverController = popoverVC.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = CGRect(x: 0, y: 0, width: 85, height: 30)
            popoverController.permittedArrowDirections = .Any
            popoverController.delegate = self
            popoverVC.delegate = self
        }
        presentViewController(popoverVC, animated: false, completion: nil)
    }
    
    // handle the share memes button
    @IBAction func shareMeme(sender: UIBarButtonItem) {
        
        // check if there is an image present
        if imageView.image != nil {
            
            // share the meme image
            
            // 1) first we generate the image
            memeImg = generateMemedImage()
            
            // 2) next we present the activity view controller
            let objectsToShare = [memeImg]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            self.presentViewController(activityVC, animated: true, completion: nil)
            
            // 3) and last, we save the image
            activityVC.completionWithItemsHandler = save
            
        }
        else {
            // no image present, show alert
            showAlert("Error", message: "Must Select an Image First!")
        }
    }
}