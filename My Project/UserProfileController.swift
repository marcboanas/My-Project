//
//  UserProfileController.swift
//  My Project
//
//  Created by Sophie Louise Boanas-Levitt on 14/07/2018.
//  Copyright © 2018 Marc Boanas. All rights reserved.
//

import UIKit

class UserProfileController: UICollectionViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = .white
        
        FireService.shared.getCurrentUser { (user) in
            self.navigationItem.title = user.username
        }

    }
}
