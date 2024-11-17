//
//  ContactService.swift
//  AS8
//  this file is for working with backend.
//  Created by 李方一 on 11/12/24.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

extension SelectContactBottomSheetViewController {
    
    func fetchContactsFromFirebase() {
        let database = Firestore.firestore()
        
        guard let currentUserEmail = Auth.auth().currentUser?.email else {
                print("current user does not sign in.")
                return
            }
        
        database.collection("users")
            .getDocuments { [weak self] (snapshot, error) in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error fetching contacts: \(error)")
                    return
                }
                
                guard let snapshot = snapshot else {
                    print("No snapshot found")
                    return
                }
                
                print("Fetched \(snapshot.documents.count) documents")
                
        
                self.contactsList = snapshot.documents.compactMap { document in
                    
                    guard let name = document.get("name") as? String,
                          let email = document.get("email") as? String,
                            email != currentUserEmail
                    else {
                        return nil
                    }
                    return Contact(name: name, email: email, phone: 0)
                }
                
               
                self.contactsList.sort(by: { $0.name < $1.name })
             
                DispatchQueue.main.async {
                    self.selectContactScreen.selectContactsTabelView.reloadData()
                }
            }
    }
    
    
    
    func updateChatID(currentUserEmail: String, selectedContactEmail: String, chatID: String,otherUserName: String,currentUserName:String, completion: @escaping (Bool, Error?) -> Void) {
        
        let database = Firestore.firestore()
        let usersRef = database.collection("users")
        
        let currentUserQuery = usersRef.whereField("email", isEqualTo: currentUserEmail)
        
        print("Current User Email: \(currentUserEmail)")

        
        currentUserQuery.getDocuments { (snapshot, error) in
            if let error = error {
                completion(false, error)
                return
            }
            
            guard let document = snapshot?.documents.first else {
                completion(false, NSError(domain: "ContactService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Current user not found"]))
                return
            }
            
            let currentUserChatsRef = document.reference.collection("chats").document(chatID)
         
            currentUserChatsRef.setData([
                "id": chatID,
                "dateTime": FieldValue.serverTimestamp(),
                "lastMessage": "",
                "lastUser": "",
                "user1": currentUserName,
                "user2": otherUserName,
                "chattingPeopleEmail": selectedContactEmail
                
            ]) { error in
                if let error = error {
                    completion(false, error)
                } else {
                    completion(true, nil)
                }
            }
        }
        
        
        let selectedUserQuery = usersRef.whereField("email", isEqualTo: selectedContactEmail)
        
        selectedUserQuery.getDocuments { (snapshot, error) in
            if let error = error {
                completion(false, error)
                return
            }
            
            guard let selectedUserDocument = snapshot?.documents.first else {
                completion(false, NSError(domain: "ContactService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Selected contact not found"]))
                return
            }
            
            let selectedUserChatsRef = selectedUserDocument.reference.collection("chats").document(chatID)
            
          
            selectedUserChatsRef.setData([
                "id": chatID,
                "dateTime": FieldValue.serverTimestamp(),
                "lastMessage": "",
                "lastUser": "",
                "user1": currentUserName,
                "user2": otherUserName,
                "chattingPeopleEmail": selectedContactEmail
            ]) { error in
                if let error = error {
                    completion(false, error)
                } else {
                    completion(true, nil)
                }
            }
        }
    }

    
    func createChatDocument(chatID: String, completion: @escaping (Bool, Error?) -> Void) {
        let database = Firestore.firestore()
        let chatRef = database.collection("chats").document(chatID)
        
        chatRef.setData([:]) { error in
            if let error = error {
                completion(false, error)
            } else {
                completion(true, nil)
            }
        }
    }


}
