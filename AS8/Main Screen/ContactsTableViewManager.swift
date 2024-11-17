//
//  ContactsTableViewManager.swift
//  AS8
//
//  Created by Eva H on 11/10/24.
//

import Foundation
import UIKit

extension ViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Configs.tableViewContactsID, for: indexPath) as! ContactsTableViewCell
        
        let contact = contactsList[indexPath.row]
        
        let currentUserName = currentUser?.displayName ?? "Anonymous"
        
        let otherUserName = (contact.user1 == currentUserName) ? contact.user2 : contact.user1
        
        cell.labelName.text = otherUserName
        cell.labelSender.text = contact.lastUser
        cell.labelText.text = contact.lastMessage
        cell.id = contact.id
        cell.user1 = contact.user1
        cell.user2 = contact.user2
        
        // Date Formatting
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short    // E.g., "11/07/24"
        dateFormatter.timeStyle = .short    // E.g., "12:05 PM"
        
        // Format dateTime directly as it's not optional
        cell.labelTime.text = dateFormatter.string(from: contact.dateTime)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedContact = contactsList[indexPath.row]
        
        guard let chatID = selectedContact.id else {
            print("Error: chatID is nil for contact \(selectedContact)")
            return
        }

        let currentUserName = currentUser?.displayName ?? "Anonymous"
        let chattingPeopleName = (selectedContact.user1 == currentUserName) ? selectedContact.user2 : selectedContact.user1
        
        let chatViewController = ChatViewController()
        
        // Pass the necessary data to ChatViewController
        chatViewController.chatID = chatID
        chatViewController.currentUserName = currentUserName
        chatViewController.currentUserEmail = currentUser?.email ?? ""
        chatViewController.chattingPeopleName = chattingPeopleName
        chatViewController.chattingPeopleEmail = selectedContact.chattingPeopleEmail

        // Navigate to the chat screen
        navigationController?.pushViewController(chatViewController, animated: true)
    }

}

