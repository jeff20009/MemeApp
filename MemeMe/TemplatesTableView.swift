//
//  TemplatesTableView.swift
//  MemeMe


import UIKit

/* This class is used for the templates table view. It creates a table view with pre-determined
 * templates that the user can pick from to make a Meme. It uses the same custom table cell as the one
 * that is used for the Sent memes table.
*/
class TemplatesTableViewController: UITableViewController {
    
    // Variables
    var templates = [Template]() // the array of template objects
    
    // an array of all the template titles
    var titles = [
        "American Sherman Tank",
        "Solider",
        "Turret",
        "Airplane"
    ]
    // array that will contain the paths to all the images
    var images = [String]()
    
    // definie the Template Struct
    struct Template {
        var image: UIImage // image of the template
        var title: String // template's title
        
        init(image: UIImage, title: String){
            self.image = image
            self.title = title
        }
    }
    
    // delegate View Conterller (in this case it will be the editor view
    var delegate: ViewController? = nil
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        
        // fill the templates array
        fillTemplates()
    }
    
    // MARK: TableView Functions
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return templates.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // deque the cell as a custom table view cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemeTableCell") as! CustomTableViewCell
        
        // create a template
        let template = templates[(indexPath as NSIndexPath).row]
        
        // Set the name and image
        cell.topText.text = template.title
        cell.memeImage.image = template.image
        cell.bottomText.text = ""
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // enable the share button in the Edit View
        delegate?.leftBarButton.isEnabled = true
        
        // call the function in the edit view ViewController to display the chosen Meme
        delegate?.showTemplate(templates[(indexPath as NSIndexPath).row].image)
        
        // dismiss the tableView
        dismiss(animated: false, completion: nil)
    }
    
    // MARK:] OTHER FUNCTIONS
    // function to fill the templates array
    // this is much quicker than doing each template by itself
    func fillTemplates(){
        // iterates over each title, creates a new template and appends it to the array
        // update to the Swift 3.0
//        for i = 0, range(through: titles.count, by: 1){
        
        for i in 0..<titles.count{
            //print(i)
            
            // set the image
            let image = UIImage(named: "t\(i + 1).png")
            
            // create the template
            let template = Template(image: image!, title: titles[i])
            
            // append
            templates.append(template)
        }
    }
}
