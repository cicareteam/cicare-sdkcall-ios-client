//
//  CiCareCallApp.swift
//  CiCareCall
//
//  Created by Mohammad Annas Al Hariri on 15/08/25.
//

import SwiftUI

import Foundation

extension Notification.Name {
    static let apnsTokenUpdated = Notification.Name("apnsTokenUpdated")
    static let voipTokenUpdated = Notification.Name("voipTokenUpdated")
}
@main
struct CiCareCallApp: App {
    // Registrasi AppDelegate ke SwiftUI lifecycle
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
            // Start PushKit manager
            //VoipManager.shared
        }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
