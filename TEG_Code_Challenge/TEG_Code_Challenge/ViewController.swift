//
//  ViewController.swift
//  TEG_Code_Challenge
//
//  Created by Ray on 5/8/25.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let nav = UINavigationController(rootViewController: VenuesVC())
        nav.modalPresentationStyle = .fullScreen
        nav.modalTransitionStyle = .crossDissolve
        self.present(nav, animated: true)
    }
}

