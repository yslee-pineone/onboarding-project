//
//  MainVC.swift
//  OnBoardingProject
//
//  Created by pineone on 12/5/23.
//

import UIKit

class MainVC: UIViewController {
    let viewModel: MainViewModel
    
    init(
        viewModel: MainViewModel
    ) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.attribute()
    }
}

extension MainVC {
    func attribute() {
        self.view.backgroundColor = .yellow
    }
}
