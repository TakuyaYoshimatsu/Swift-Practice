//
//  CameraViewController.swift
//  Practice
//
//  Created by 吉松拓哉 on 2021/01/13.
//

import UIKit
import Photos

class SelectViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    
    @IBOutlet weak var outputLabel: UILabel!
    
    @IBOutlet weak var BackImageView: UIImageView!
    
    var outputValue : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        outputLabel.text = outputValue
        
//        PHPhotoLibrary.requestAuthorization
//        {(status) in
//
//            switch(status)
//            {
//            case .authorized:
//                print("許可")
//            case .denied:
//                print("拒否")
//            case .notDetermined:
//                print("notDetermined")
//            case .restricted:
//                print("restricted")
        //            default: break
//                print("")
//            }
//        }
    }
    
    
    
    @IBAction func Back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func Camera(_ sender: Any) {
    }
    
}
