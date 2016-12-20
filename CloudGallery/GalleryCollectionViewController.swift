//
//  GalleryCollectionViewController.swift
//  CloudGallery
//
//  Created by Jack Weber on 12/12/16.
//  Copyright © 2016 Jack Weber. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

private let reuseIdentifier = "photo"

class GalleryCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    //Variables used in multiple functions
    var photoInfoArray: [String] = []
    var photoArray: [UIImage]! = []
    var sortby = "date"
    var sortArray: [Double] = []
    var dictForSort = [Double: String]()
    var dictForCompletion = [String: UIImage]()
    
    //Clear arrays
    func clearArrays(){
        photoInfoArray.removeAll()
        photoArray.removeAll()
        sortArray.removeAll()
        dictForSort.removeAll()
        dictForCompletion.removeAll()
    }
    
    //Code for pull to refresh
    var refresher = UIRefreshControl()
    
    //Story Board Connections
    @IBAction func logOut(_ sender: Any) {
        AppState.sharedInstance.displayName = nil
        AppState.sharedInstance.photoURL = nil
        AppState.sharedInstance.signedIn = false
        
        do{
            try FIRAuth.auth()?.signOut()
        }
        catch{
            print("Error Signing Out")
        }
        
        performSegue(withIdentifier: "logOutSegue", sender: nil)
    }
    
    //Child Functions
    
    //get info about the photos from remote database
    func loadphotos(){
        //Check to see if the user is logged in.
        if AppState.sharedInstance.signedIn == true{
            //Create the variables needed
            let database = FIRDatabase.database().reference()
            let userID = FIRAuth.auth()?.currentUser?.uid
            //Observe only once, the data within the userID section
            database.child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
                if let photoDic = snapshot.value as? NSDictionary{
                    for (picture, info) in photoDic{
                        //Add all the items to the photo info Array
                        if var filename = picture as? String{
                            filename = filename + ".png"
                            if let dict = info as? NSDictionary{
                                let sortname = dict[self.sortby] as! Double
                                self.sortArray.append(sortname)
                                self.dictForSort[sortname] = filename
                            }
                        }
                    }
                    self.oragnizePhotos()
                }
                
            }, withCancel: { (error) in
                print(error.localizedDescription)
            })
        }
        else{
        }
    }
    
    //Oragnize the dictionary into an array that can be used by retrievePhotos()
    func oragnizePhotos(){
        sortArray.sort()
        for num in sortArray{
            if let filename = dictForSort[num]{
                photoInfoArray.append(filename)
                //print(photoInfoArray)
                //print(sortArray)
            }
        }
        retrievePhotos()
    }
    
    //Get the photos in the array from remote storage
    func retrievePhotos(){
        let userID = FIRAuth.auth()?.currentUser?.uid
        let storage = FIRStorage.storage()
        let libraryRef = storage.reference().child(userID!)
        for photo in photoInfoArray{
            let photoRef = libraryRef.child(photo)
            photoRef.data(withMaxSize: 1 * 1024 * 1024, completion: { (data, error) in
                if error != nil{
                    print("could not find photo with name: " + photo)
                }
                else{
                    let image = UIImage(data: data!)
                    self.dictForCompletion[photo] = image
                    self.complete()
                }
            })
        }
    }
    
    //function to be ran when retrieving photos is complete. It sorts the photos
    //in the photoArray according to the Strings in the photoInfoArray
    func complete(){
        if photoInfoArray.count == dictForCompletion.count{
            for i in 0...(photoInfoArray.count - 1){
                let photo = photoInfoArray[i]
                let image = dictForCompletion[photo]
                photoArray.append(image!)
            }
            self.collectionView?.reloadData()
            refresher.endRefreshing()
        }
    }
    
    //Function to refresh photos.
    func refresh(){
        clearArrays()
        loadphotos()
    }
    
    //Override Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        //self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        //Add the refresher
        self.collectionView!.alwaysBounceVertical = true
        refresher.tintColor = UIColor.darkGray
        refresher.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
        collectionView!.addSubview(refresher)
        

        // Do any additional setup after loading the view.
        
        
        //Begin loading the photos
        loadphotos()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource
    
    //Below are functions for loading the photos from photoArray into the the actual
    //Collection cells

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return photoArray.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CellCollectionViewCell
        
        // Configure the cell
        let image = photoArray[indexPath.row]
        cell.theImageView.image = image
        
        return cell
    }
    
    

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
    
    //Flow Delegate functions
    //these functions will change the appearance of the cells.
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: 100, height: 100)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}
