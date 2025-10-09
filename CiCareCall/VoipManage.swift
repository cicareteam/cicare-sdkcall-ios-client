//
//  VoipManage.swift
//  CiCareCall
//
//  Created by Mohammad Annas Al Hariri on 25/08/25.
//

import Foundation
import PushKit
import CiCareSDKCall

class VoipManager: NSObject, PKPushRegistryDelegate {
    static let shared = VoipManager()
    private var pushRegistry: PKPushRegistry!
    public var userId: String?
    
    private override init() {
        super.init()
    }
    
    public func regist() {
        pushRegistry = PKPushRegistry(queue: DispatchQueue.main)
        pushRegistry.delegate = self
        pushRegistry.desiredPushTypes = [.voIP]
    }
    
    func pushRegistry(
        _ registry: PKPushRegistry,
        didUpdate pushCredentials: PKPushCredentials,
        for type: PKPushType
    ) {
        let voipToken = pushCredentials.token.map { String(format: "%02x", $0) }.joined()
        //print("VoIP Token: \(voipToken)")
        sendTokenToServer(voipToken)
        NotificationCenter.default.post(name: .voipTokenUpdated, object: voipToken)
    }
    
    func pushRegistry(_ registry: PKPushRegistry,
                      didReceiveIncomingPushWith payload: PKPushPayload,
                      for type: PKPushType,
                      completion: @escaping () -> Void) {

        // Ambil data caller dari payload
        guard let aps = payload.dictionaryPayload["aps"] as? [String: Any],
              let token = payload.dictionaryPayload["alert_data"] as? String else {
            
            completion()
            return
        }
        //SheetManager.shared.dismissActiveSheet()
        print("Incoming notification")
        var metaData:[String:String] = [:]
        let callerId: String = payload.dictionaryPayload["callerId"] as! String
        let avatar: String = payload.dictionaryPayload["callerAvatar"] as! String
        let callerName: String = payload.dictionaryPayload["callerName"] as! String
        metaData["alert_data"] = payload.dictionaryPayload["alert_data"] as? String
        CicareSdkCall.shared.incoming(callerId: callerId, callerName: callerName, callerAvatar: avatar, calleeId: "", calleeName: "", calleeAvatar: "", checkSum: "", metaData: metaData) {
            print("message clicked")
        }
        completion() // jangan lupa panggil completion
    }
    
    func pushRegistry(
        _ registry: PKPushRegistry,
        didInvalidatePushTokenFor type: PKPushType
    ) {
        print("VoIP token invalidated")
    }
    
    private func sendTokenToServer(_ token: String) {
            guard let url = URL(string: "https://sip-gw.c-icare.cc:4443/api/save-token-ios") else { return }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            // Example JSON body
            let body: [String: Any] = [
                "device_token": token,
                "type": "ios",
                "user_id": self.userId // optional if you have a logged in user
            ]

            request.httpBody = try? JSONSerialization.data(withJSONObject: body)

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Failed to send token: \(error.localizedDescription)")
                    return
                }
                if let httpResponse = response as? HTTPURLResponse {
                    //print("Token sent, server response: \(httpResponse.statusCode)")
                }
            }.resume()
        }
}
