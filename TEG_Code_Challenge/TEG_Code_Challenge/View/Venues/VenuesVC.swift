//
//  VenuesVC.swift
//  TEG_Code_Challenge
//
//  Created by Ray on 5/8/25.
//

import UIKit
import RxSwift
import RxCocoa

class VenuesVC: UIViewController {
    
    let viewModel = VenuesVM()
    
    lazy var tableView:UITableView = {
        let table = UITableView()
        table.backgroundColor = .clear
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 10
        table.register(VenueCell.self, forCellReuseIdentifier: "venueCell")
        table.separatorStyle = .singleLine
        return table
    }()
    
    lazy var activityView:UIActivityIndicatorView = {
        let activityView = UIActivityIndicatorView(style: .large)
        activityView.startAnimating()
        return activityView
    }()
    
    lazy var loadingLbl:UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .center
        lbl.font = .systemFont(ofSize: 16, weight: .medium)
        lbl.text = "Loading"
        return lbl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        self.title = "Venues"
        
        setupLayout()
        rxBuild()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.beginLocationService()
    }
}

// MARK: Private
extension VenuesVC {
    private func setupLayout() {
        view.addSubview(tableView)
        view.addSubview(activityView)
        view.addSubview(loadingLbl)
        
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        activityView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        loadingLbl.snp.makeConstraints { make in
            make.top.equalTo(activityView.snp.bottom).offset(5)
            make.centerX.equalTo(activityView)
        }
    }
    
    private func rxBuild() {
        viewModel
            .presentState
            .bind { [weak self] view in
                guard let `self` = self else { return }
                self.present(view, animated: true)
            }.disposed(by: rx.disposeBag)
        
        viewModel
            .pushNavState
            .bind { [weak self] view in
                guard let `self` = self else { return }
                self.navigationController?.pushViewController(view, animated: true)
            }.disposed(by: rx.disposeBag)
        
        viewModel
            .venues
            .bind { [weak self] items in
                guard let `self` = self else { return }
                self.activityView.isHidden = !items.isEmpty
                self.loadingLbl.isHidden = !items.isEmpty
                self.tableView.isHidden = items.isEmpty
            }.disposed(by: rx.disposeBag)
        
        viewModel
            .venues
            .asObservable()
            .observe(on: MainScheduler.instance)
            .bind (to: tableView.rx.items(cellIdentifier: "venueCell", cellType: VenueCell.self)) { (_, item, cell) in
                cell.item = item
                cell.selectionStyle = .none
            }.disposed(by: rx.disposeBag)
        
        tableView
            .rx
            .modelSelected(VenueModel.self)
            .bind { [weak self] item in
                guard let `self` = self else { return }
                // Will open the camera
                self.viewModel.openScanTicket(item: item)
            }.disposed(by: rx.disposeBag)
            
    }
}
