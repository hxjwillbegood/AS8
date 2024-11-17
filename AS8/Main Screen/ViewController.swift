//
//  ViewController.swift
//  AS8
//
//  Created by Eva H on 11/10/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ViewController: UIViewController {

    let mainScreen = MainScreenView()
    
    var contactsList = [Chat]()
    
    var handleAuth: AuthStateDidChangeListenerHandle?
    
    var currentUser:FirebaseAuth.User?

    var chattingUser: String!
    let database = Firestore.firestore()
    
    override func loadView() {
        view = mainScreen
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //MARK: handling if the Authentication state is changed (sign in, sign out, register)...
        handleAuth = Auth.auth().addStateDidChangeListener{ auth, user in
            if user == nil{
                //MARK: not signed in...
                self.currentUser = nil
                self.mainScreen.labelText.text = "Please sign in to see the notes!"
                self.mainScreen.floatingButtonAddContact.isEnabled = false
                self.mainScreen.floatingButtonAddContact.isHidden = true
                
                //MARK: Reset tableView...
                self.contactsList.removeAll()
                self.mainScreen.tableViewContacts.reloadData()
                
                //MARK: Sign in bar button...
                self.setupRightBarButton(isLoggedin: false)
                
            }else{
                //MARK: the user is signed in...
                self.currentUser = user
                self.mainScreen.labelText.text = "Welcome \(user?.displayName ?? "Anonymous")!"
                self.mainScreen.floatingButtonAddContact.isEnabled = true
                self.mainScreen.floatingButtonAddContact.isHidden = false
                
                //MARK: Logout bar button...
                self.setupRightBarButton(isLoggedin: true)
                
                //MARK: Observe Firestore database to display the contacts list...
                self.database.collection("users")
                    .document((self.currentUser?.email)!)
                    .collection("chats")
                    .addSnapshotListener(includeMetadataChanges: false, listener: {querySnapshot, error in
                        if let documents = querySnapshot?.documents{
                            self.contactsList.removeAll()
                            for document in documents{
                                do{
                                    let chat  = try document.data(as: Chat.self)
                                    print(chat)
                                    self.contactsList.append(chat)
                                }catch{
                                    print(error)
                                }
                            }
                            self.contactsList.sort { $0.dateTime > $1.dateTime }
                            self.mainScreen.tableViewContacts.reloadData()
                        }
                    })
                
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "My Contacts"
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleChatIdGeneratedNotification(_:)), name: .chatIdGenerated, object: nil)
        
        //MARK: patching table view delegate and data source...
        mainScreen.tableViewContacts.delegate = self
        mainScreen.tableViewContacts.dataSource = self
        
        //MARK: removing the separator line...
        mainScreen.tableViewContacts.separatorStyle = .none
        
        //MARK: Make the titles look large...
        navigationController?.navigationBar.prefersLargeTitles = true
        
        //MARK: Put the floating button above all the views...
        view.bringSubviewToFront(mainScreen.floatingButtonAddContact)
        
        //MARK: tapping the floating add contact button...
        mainScreen.floatingButtonAddContact.addTarget(self, action: #selector(addContactButtonTapped), for: .touchUpInside)
        
        // update main screen when notification center received a new chat.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handleAuth!)
    }
    
    func signIn(email: String, password: String){
        Auth.auth().signIn(withEmail: email, password: password)
    }
    
    @objc func addContactButtonTapped(){
        let addContactController = SelectContactBottomSheetViewController()
        
        addContactController.modalPresentationStyle = .pageSheet
        // addContactController.currentUser = self.currentUser
        if let sheetPresentationController = addContactController.sheetPresentationController {
            sheetPresentationController.detents = [.medium(), .large()]
            sheetPresentationController.prefersGrabberVisible = true
        }
            
        present(addContactController, animated: true, completion: nil)
    }
    

    @objc func handleChatIdGeneratedNotification(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let chatID = userInfo["chatID"] as? String,
              let otherUser = userInfo["otherUser"] as? Contact,
              let currentUser = userInfo["currentUser"] as? Contact else {
            print("！！Invalid notification payload")
            return
        }
        
        self.chattingUser = otherUser.name

        // for test
        print("Chat ID: \(chatID)")
        print("Current User Name: \(currentUser.name), Current User Email: \(currentUser.email)")
        print("Other User Name: \(otherUser.name), Other User Email: \(otherUser.email)")

        
        let dump = ChatViewController()
        
        dump.chatID = chatID
        dump.currentUserEmail = currentUser.email
        dump.currentUserName = currentUser.name
        dump.chattingPeopleName = otherUser.name
        dump.chattingPeopleEmail = otherUser.email
        
        navigationController?.pushViewController(dump, animated: true)
    }
}

