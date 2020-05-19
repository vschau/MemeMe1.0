//
//  MemeDetailViewController.swift
//  MemeMe1.0
//
//  Created by Vanessa on 5/18/20.
//  Copyright © 2020 Vanessa. All rights reserved.
//

import UIKit

class MemeDetailViewController: UIViewController {
    
    // MARK: Properties
    var meme: Meme!
    
    // MARK: Outlets
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //self.tabBarController?.tabBar.isHidden = true
        
        self.imageView!.image = meme.memedImage
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //self.tabBarController?.tabBar.isHidden = false
    }
}
