//
//  ContactsTableViewCell.swift
//  AS8
//
//  Created by Eva H on 11/10/24.
//

import UIKit

class ContactsTableViewCell: UITableViewCell {
    
    var wrapperCellView: UIView!
    var labelName: UILabel!
    var labelSender: UILabel!
    var labelText: UILabel!
    var labelTime: UILabel!
    var id: String!
    var user1: String!
    var user2: String!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupWrapperCellView()
        setupLabelName()
        setupLabelSender()
        setupLabelText()
        setupLabelTime()
        
        initConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupWrapperCellView() {
        wrapperCellView = UIView()
        
        // Working with the shadows and colors...
        wrapperCellView.backgroundColor = .white
        wrapperCellView.layer.cornerRadius = 6.0
        wrapperCellView.layer.shadowColor = UIColor.gray.cgColor
        wrapperCellView.layer.shadowOffset = .zero
        wrapperCellView.layer.shadowRadius = 4.0
        wrapperCellView.layer.shadowOpacity = 0.4
        wrapperCellView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(wrapperCellView)
    }
    
    func setupLabelName() {
        labelName = UILabel()
        labelName.font = UIFont.boldSystemFont(ofSize: 20)
        labelName.translatesAutoresizingMaskIntoConstraints = false
        wrapperCellView.addSubview(labelName)
    }
    
    func setupLabelSender() {
        labelSender = UILabel()
        labelSender.font = UIFont.boldSystemFont(ofSize: 16)
        labelSender.translatesAutoresizingMaskIntoConstraints = false
        wrapperCellView.addSubview(labelSender)
    }
    
    func setupLabelText() {
        labelText = UILabel()
        labelText.font = UIFont.systemFont(ofSize: 16)
        labelText.textColor = .darkGray
        labelText.translatesAutoresizingMaskIntoConstraints = false
        wrapperCellView.addSubview(labelText)
    }
    
    func setupLabelTime() {
        labelTime = UILabel()
        labelTime.font = UIFont.systemFont(ofSize: 14)
        labelTime.textColor = .gray
        labelTime.translatesAutoresizingMaskIntoConstraints = false
        wrapperCellView.addSubview(labelTime)
    }
    
    func initConstraints() {
        NSLayoutConstraint.activate([
            // Wrapper Cell View Constraints
            wrapperCellView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            wrapperCellView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            wrapperCellView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            wrapperCellView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            // Label Name Constraints
            labelName.topAnchor.constraint(equalTo: wrapperCellView.topAnchor, constant: 12),
            labelName.leadingAnchor.constraint(equalTo: wrapperCellView.leadingAnchor, constant: 12),
            labelName.trailingAnchor.constraint(equalTo: wrapperCellView.trailingAnchor, constant: -12),
            
            // Label Sender Constraints
            labelSender.topAnchor.constraint(equalTo: labelName.bottomAnchor, constant: 4),
            labelSender.leadingAnchor.constraint(equalTo: wrapperCellView.leadingAnchor, constant: 12),
            labelSender.widthAnchor.constraint(lessThanOrEqualToConstant: 100), // Adjust as needed for sender name width
            
            // Label Text Constraints
            labelText.centerYAnchor.constraint(equalTo: labelSender.centerYAnchor),
            labelText.leadingAnchor.constraint(equalTo: labelSender.trailingAnchor, constant: 4),
            labelText.trailingAnchor.constraint(equalTo: wrapperCellView.trailingAnchor, constant: -12),
            
            // Label Time Constraints
            labelTime.topAnchor.constraint(equalTo: labelSender.bottomAnchor, constant: 8),
            labelTime.leadingAnchor.constraint(equalTo: labelSender.leadingAnchor),
            labelTime.trailingAnchor.constraint(equalTo: wrapperCellView.trailingAnchor, constant: -12),
            labelTime.bottomAnchor.constraint(equalTo: wrapperCellView.bottomAnchor, constant: -12),
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        labelName.text = nil
        labelSender.text = nil
        labelText.text = nil
        labelTime.text = nil
    }
}


