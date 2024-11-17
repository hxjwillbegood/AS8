//
//  Contact.swift
//  AS8
//
//  Created by Eva H on 11/10/24.

import Foundation
import FirebaseFirestore

struct Contact: Codable{
    //var id: String
    var name: String
    var email: String
    var phone: Int
    
    init(name: String, email: String, phone: Int) {
        self.name = name
        self.email = email
        self.phone = phone
        //self.id = id
    }
}


struct Message: Codable {
    var dateTime: Date
    var name: String
    var text: String
    
    init(dateTime: Date, name: String, text: String) {
        self.dateTime = dateTime
        self.name = name
        self.text = text
    }
}


struct Chat: Codable {
    var dateTime: Date
    var lastUser: String
    var lastMessage: String
    
    var id: String?
    var user1: String!
    var user2: String!
    var chattingPeopleEmail: String!
    
    init(dateTime: Date, lastUser: String, lastMessage: String, id: String, user1: String, user2: String,chattingPeopleEmail: String ) {
        self.dateTime = dateTime
        self.lastUser = lastUser
        self.lastMessage = lastMessage
        self.id = id
        self.user1 = user1
        self.user2 = user2
        self.chattingPeopleEmail = chattingPeopleEmail
    }
}




