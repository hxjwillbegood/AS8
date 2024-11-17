//
//  SelectContactViewController.swift
//  AS8
//
//  Created by 李方一 on 11/11/24.
//

import UIKit
import FirebaseAuth



class SelectContactBottomSheetViewController: UIViewController {
    
    
    let selectContactScreen = SelectContactBottonSheetView()
    
    var contactsList = [Contact]()
    
    
    private var isExpanded = true
    
    override func loadView() {
            view = selectContactScreen
        }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = "start chatting!"
        
        setupBottomSheet()
        
        selectContactScreen.selectContactsTabelView.delegate = self
        selectContactScreen.selectContactsTabelView.dataSource = self
        
        selectContactScreen.selectContactsTabelView.separatorStyle = .none
        
        fetchContactsFromFirebase()
        
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveContactSelection(_:)), name: .contactSelected, object: nil)
        let selectContactVC = SelectContactBottomSheetViewController()
        let navController = UINavigationController(rootViewController: selectContactVC)
        navController.modalPresentationStyle = .pageSheet
        present(navController, animated: true, completion: nil)
        
        selectContactScreen.selectContactsTabelView.reloadData()
    }
    
    
    private func setupBottomSheet() {
        if let sheetPresentationController = self.sheetPresentationController {
            sheetPresentationController.detents = [.medium(), .large()]
            sheetPresentationController.prefersGrabberVisible = true
            sheetPresentationController.prefersScrollingExpandsWhenScrolledToEdge = false
        }
    }
    
    @objc func didReceiveContactSelection(_ notification: Notification) {
        
        // get email for current user and selected user
        guard let otherUser = notification.userInfo?["contact"] as? Contact,
              let currentUserName = Auth.auth().currentUser?.displayName,
              let currentUserEmail = Auth.auth().currentUser?.email else { return }
        
        let currentUser = Contact(name: currentUserName, email: currentUserEmail, phone: 0)
        // generate chat id
        let chatID = generateChatID(for: currentUserEmail, and: otherUser.email)
        
        updateChatID(currentUserEmail: currentUserEmail, selectedContactEmail: otherUser.email, chatID: chatID, otherUserName:otherUser.name, currentUserName: currentUserName) { success, error in
            if success {
                print("Users chats updated successfully")
                print(chatID)

                
            } else if let error = error {
                print("Error updating users chats: \(error)")
            }
        }
        
        
        
        // call function to update Chats db
        createChatDocument(chatID: chatID) { success, error in
            if success {
                print("Chat document created successfully")
                print(chatID)
                print(otherUser.name)
                print(currentUser.name)
                NotificationCenter.default.post(
                                name: .chatIdGenerated,
                                object: nil,
                                userInfo: [
                                    "chatID": chatID,
                                    "otherUser": otherUser,
                                    "currentUser": currentUser
                                ]
                            )
            } else if let error = error {
                print("Error creating chat document: \(error)")
            }
        }
    }
    
    func generateChatID(for user1: String, and user2: String) -> String {
        // email1 + email2 as id for a chat， sorted to avoid a + b and b + a as same
        let sortedEmails = [user1, user2].sorted()
        return "\(sortedEmails[0])_\(sortedEmails[1])"
    }


}

extension SelectContactBottomSheetViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactsList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Configs.tableSelectChatID, for: indexPath) as! SelectContactTabelViewCell
        cell.labelName.text = contactsList[indexPath.row].name
//        cell.labelEmail.text = contactsList[indexPath.row].email
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedContact = contactsList[indexPath.row]
        
        NotificationCenter.default.post(name: .contactSelected, object: nil, userInfo: ["contact": selectedContact])
        
        dismiss(animated: true, completion: nil)
        }
}
