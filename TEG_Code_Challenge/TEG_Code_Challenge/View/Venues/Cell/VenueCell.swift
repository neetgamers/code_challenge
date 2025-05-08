//
//  VenueCell.swift
//  TEG_Code_Challenge
//
//  Created by Ray on 5/8/25.
//

import UIKit
import RxSwift
import SnapKit

class VenueCell: UITableViewCell {
    
    var item:VenueModel? {
        didSet {
            guard let item = self.item else { return }
            lblName.text = item.name
        }
    }
    
    lazy var lblName:UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 17, weight: .medium)
        return lbl
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        lblName.text = nil
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
extension VenueCell {
    private func setupLayout() {
        addSubview(lblName)
        
        lblName.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview().inset(10)
        }
    }
}
