//
//  ChatViewController.swift
//  AS8
//
//  Created by Eva H on 11/10/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ChatViewController: UIViewController {
    var currentUser:FirebaseAuth.User?
    
    let chatView = ChatView()
    
    let database = Firestore.firestore()
    
    var chatID: String?
    
    var currentUserName: String!
    
    var currentUserEmail: String!
    
    var chattingPeopleName: String!
    
    var chattingPeopleEmail: String!
    
    var messages: [Message] = []
     
    
    override func loadView() {
        
       
        view = chatView
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print("Registering observer for .contactSelected")
        //NotificationCenter.default.addObserver(self, selector: #selector(handleContactSelected(_:)), name: .contactSelected, object: nil)
        
        //MARK: patching table view delegate and data source...
        chatView.tableViewMessages.delegate = self
        chatView.tableViewMessages.dataSource = self
        
        //MARK: removing the separator line...
        chatView.tableViewMessages.separatorStyle = .none
        
        chatView.tableViewMessages.rowHeight = UITableView.automaticDimension
        chatView.tableViewMessages.estimatedRowHeight = 100
        
        
        /*NotificationCenter.default.addObserver(self, selector: #selector(handleContactSelected(_:)), name: .contactSelected, object: nil)*/

        title = "Chat with \(chattingPeopleName ?? "Unknown")"
        
        chatView.buttonSend.addTarget(self, action: #selector(onSendButtonTapped), for: .touchUpInside)
        
        getMessageList()
    }
    
    /*@objc func handleContactSelected(_ notification: Notification) {
        print("handleContactSelected triggered")
        
        if let userInfo = notification.userInfo,
           let selectedContact = userInfo["contact"] as? Contact,
           let unwrappedChatID = selectedContact.id ?? nil{
            // Assign values to the corresponding properties
            chattingPeopleName = selectedContact.name
            chattingPeopleEmail = selectedContact.email
            chatID = unwrappedChatID // Assign the unwrapped value to chatID

            // Update the title of the ChatViewController
//            title = "Chat with \(chattingPeopleName ?? "Unknown")"
            
            print("Chatting with: \(chattingPeopleName ?? "Unknown")")
            print("Chat ID: \(chatID ?? "No Chat ID")")
        } else {
            print("Error: Missing or invalid data in notification userInfo.")
        }
    }*/

    @objc func onSendButtonTapped() {
        guard let messageText = chatView.textFieldMessage.text, !messageText.isEmpty,
              let chatID = chatID,
              let currentUserEmail = currentUserEmail,
              let chattingPeopleEmail = chattingPeopleEmail else {
            print("Message text is empty or chatID/currentUserEmail/chattingPeopleEmail is nil")
            return
        }
        
        let name = currentUserName ?? "No one" // Replace with sender's name
        let date = Date()
        
        // Create a message instance
        let message = Message(dateTime: date, name: name, text: messageText)
        print(message)
        
        // Add the message to the "message" collection in Firestore
        let collectionMessage = database
            .collection("chats")
            .document(chatID) // Use the chatID from the notification or context
            .collection("message")
        
        do {
            try collectionMessage.addDocument(from: message) { error in
                if let error = error {
                    print("Error adding message document: \(error)")
                } else {
                    // Message successfully added to Firestore
                    // No manual addition to `messages` array here
                    self.clearInputText()
                    
                    // Update the chatsDB fields for the current user
                    let currentUserChatsDB = self.database
                        .collection("users")
                        .document(currentUserEmail)
                        .collection("chats")
                        .document(chatID)
                    
                    currentUserChatsDB.updateData([
                        "lastUser": name,
                        "lastMessage": messageText,
                        "dateTime": Timestamp(date: date)
                    ]) { error in
                        if let error = error {
                            print("Error updating currentUserChatsDB fields: \(error)")
                        } else {
                            print("currentUserChatsDB updated successfully with last message details")
                        }
                    }
                    
                    // Update the chatsDB fields for the chatting person
                    let chattingPeopleChatsDB = self.database
                        .collection("users")
                        .document(chattingPeopleEmail)
                        .collection("chats")
                        .document(chatID)
                    
                    chattingPeopleChatsDB.updateData([
                        "lastUser": name,
                        "lastMessage": messageText,
                        "dateTime": Timestamp(date: date)
                    ]) { error in
                        if let error = error {
                            print("Error updating chattingPeopleChatsDB fields: \(error)")
                        } else {
                            print("chattingPeopleChatsDB updated successfully with last message details")
                        }
                    }
                }
            }
        } catch {
            print("Error adding document: \(error)")
        }
    }

    
    
    func getMessageList() {
        guard let chatID = chatID else {
            print("Chat ID is nil")
            return
        }
        
        let collectionMessage = database
            .collection("chats")
            .document(chatID)
            .collection("message")
            .order(by: "dateTime", descending: false) // Ensure messages are fetched in chronological order
        
        // Set up a real-time listener
        collectionMessage.addSnapshotListener { querySnapshot, error in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                // Clear the messages array before adding new data
                self.messages = []
                
                for document in querySnapshot!.documents {
                    if let message = try? document.data(as: Message.self) {
                        self.messages.append(message)
                    }
                }
                
                // Messages are now in chronological order
                
                // Reload the table view to display messages
                DispatchQueue.main.async {
                    self.chatView.tableViewMessages.reloadData()
                    
                    // Scroll to the bottom to show the most recent message
                    if !self.messages.isEmpty {
                        let lastIndexPath = IndexPath(row: self.messages.count - 1, section: 0)
                        self.chatView.tableViewMessages.scrollToRow(at: lastIndexPath, at: .bottom, animated: true)
                    }
                }
            }
        }
    }


    
    // functional function
    func clearInputText() {
        chatView.textFieldMessage.text = ""
    }
    
    func showAlert(withMessage message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    

}

extension ChatViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Configs.tableViewChatID, for: indexPath) as! ChatTableViewCell
        
        let message = messages[indexPath.row]
        cell.labelSenderName.text = message.name
        cell.labelMessageText.text = message.text
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        cell.labelTime.text = dateFormatter.string(from: message.dateTime)
        
        // Change background color based on sender
        if currentUserName == message.name {
            cell.wrapperCellView.backgroundColor = .white // Sent by the current user
        } else {
            cell.wrapperCellView.backgroundColor = UIColor(red: 0.9, green: 0.95, blue: 1.0, alpha: 1.0) // Sent by another user
        }
        
        return cell
    }
}
