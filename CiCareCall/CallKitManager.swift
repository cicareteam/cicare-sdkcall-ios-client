//
//  CallManager.swift
//  CiCareCall
//
//  Created by Mohammad Annas Al Hariri on 12/01/26.
//


import CallKit
import AVFoundation

final class CallKitManager: NSObject {
    
    static let shared = CallKitManager()

    private let callController = CXCallController()
    private var provider: CXProvider!
    private var currentCallUUID: UUID?

    override init() {
        super.init()
        //setupCallKit()
    }

    public func setupCallKit() {
        let config = CXProviderConfiguration()
        config.supportsVideo = false
        config.maximumCallsPerCallGroup = 1
        config.maximumCallGroups = 1
        config.supportedHandleTypes = [.generic]

        provider = CXProvider(configuration: config)
        provider.setDelegate(self, queue: nil)
    }
}

extension CallKitManager {

    func startCall(to callee: String) {
        let uuid = UUID()
        currentCallUUID = uuid

        let handle = CXHandle(type: .generic, value: callee)
        let action = CXStartCallAction(call: uuid, handle: handle)
        let transaction = CXTransaction(action: action)

        callController.request(transaction) { error in
            if let error = error {
                print("❌ Start call error:", error)
                return
            }

            let update = CXCallUpdate()
            update.remoteHandle = handle
            update.hasVideo = false

            self.provider.reportCall(with: uuid, updated: update)
        }
    }
}

extension CallKitManager {

    func reportIncomingCall(from caller: String) {
        let uuid = UUID()
        currentCallUUID = uuid

        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .generic, value: caller)
        update.hasVideo = false

        provider.reportNewIncomingCall(with: uuid, update: update) { error in
            if let error = error {
                print("❌ Incoming call error:", error)
            }
            
            print("Incoming report executed from simple callkit")
            
            
        }
    }
}

extension CallKitManager: CXProviderDelegate {

    func providerDidReset(_ provider: CXProvider) {
        print("🔄 CallKit reset")
        currentCallUUID = nil
    }

    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        configureAudioSession()
        action.fulfill()
    }

    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        configureAudioSession()
        action.fulfill()
    }

    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        action.fulfill()
        currentCallUUID = nil
    }

    private func configureAudioSession() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playAndRecord, mode: .voiceChat)
        try? session.setActive(true)
    }
}
