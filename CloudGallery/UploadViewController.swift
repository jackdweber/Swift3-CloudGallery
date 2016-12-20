//
//  UploadViewController.swift
//  CloudGallery
//
//  Created by Jack Weber on 12/12/16.
//  Copyright © 2016 Jack Weber. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class UploadViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    //Set up constants to be storage
    var database: FIRDatabaseReference!
    var storage: FIRStorage!
    
    //Variables used in multiple functions
    var pickedImage: UIImage!
    var imageURL: NSURL!
    var imageData: Data!
    
    //UIKit variables
    var activityIndicator: UIActivityIndicatorView!
    
    //Storyboard outlets
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var mainView: UIView!
    
    //Child functions
    
    //Functions to pause and resume app while uploading.
    func pauseApp(){
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 50, y: 50, width: 100, height: 100))
        activityIndicator.hidesWhenStopped = true
        activityIndicator.layer.zPosition = 2
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    func resumeApp(){
        activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    
    //Functions to recieve image from the library.
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage{
            //Set variables for the local file that was just chosen
            imageView.image = image;
            pickedImage = image;
            imageData = UIImagePNGRepresentation(image)
            imageURL = info[UIImagePickerControllerReferenceURL] as? NSURL
        }
        else{
            print("Could not get image")
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func selectPhoto(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = false
        imagePickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(imagePickerController, animated: true, completion: nil)
        
    }
    
    //Upload the photo
    
    @IBAction func uploadPhoto(_ sender: Any) {
        
        
        //reference where we sill store our phots
        let userID = FIRAuth.auth()?.currentUser?.uid
        let libraryRef = storage.reference().child(userID!)
        let picname = NSUUID().uuidString
        let filename = "\(picname).png"
        let photoRef = libraryRef.child(filename)
        
        //Upload the File
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image/png"
        pauseApp()
        photoRef.put(imageData, metadata: metadata, completion: {(meta, error) in
            if error != nil{
                self.resumeApp()
                print("error")
            }
            else{
                let date = NSDate().timeIntervalSinceReferenceDate
                self.database.child(userID!).child(picname).setValue(["date": date])
                self.resumeApp()
            }
        })
    }
    
    //Override Functions

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //Fill constants with the current storage and database
        storage = FIRStorage.storage()
        database = FIRDatabase.database().reference()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
