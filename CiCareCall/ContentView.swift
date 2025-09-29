import SwiftUI
import UserNotifications
import CiCareSDKCall

struct ContentView: View {
    @State private var showDialog = false
    @State private var inputText = ""
    @State private var navigate = false
    
    var body: some View {

        NavigationStack {
            VStack(spacing: 20) {
                Button("Test Local Notification") {
                    showDialog = true
                }
                Button("Outgoing Call") {
                    makeCall()
                }
                NavigationLink(destination: NextView(name: inputText), isActive: $navigate) {
                    EmptyView()
                }
            }
            .padding()
            .sheet(isPresented: $showDialog) {
                VStack(spacing: 20) {
                    Text("Enter your name")
                        .font(.headline)
                    TextField("Name", text: $inputText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    Button("OK") {
                        CicareSdkCall.shared.incoming(callerId: "2", callerName: "", callerAvatar: "https://avatar.iran.liara.run/public/boy", calleeId: "3", calleeName: "", calleeAvatar: "https://avatar.iran.liara.run/public", checkSum: "asdfasdf", metaData: ["call_not_found":"Call not found"]
                        ) {
                            print("Button message clicked")
                            navigate = true
                        }
                        showDialog = false
                    }
                    Button("Cancel") {
                        showDialog = false
                    }
                }
                .padding()
            }
        }
    }
    
    func makeCall() {
        CicareSdkCall.shared.setAPI(baseUrl: "https://gsm-sdk.c-icare.cc:8443", token: "a1b2c3d4e5f60718293a4b5c6d7e8f90123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef")
        
        CicareSdkCall.shared.outgoing(callerId: "4", callerName: "Anas", callerAvatar: "", calleeId: "2", calleeName: "Ricky", calleeAvatar: "https://avatar.iran.liara.run/public/boy", checkSum: "asdfasdf", metaData: ["call_title":"Call Gratis", "call_not_found":"Call not found"])
    }

    /*func scheduleLocalNotification() {
        // 1. Minta izin sekali saja (bisa juga taruh di AppDelegate)
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("❌ Permission error: \(error)")
            } else {
                print("🔔 Permission granted: \(granted)")
            }
        }

        // 2. Buat konten notifikasi
        let content = UNMutableNotificationContent()
        content.title = "Hello from Local Notification"
        content.body = "This is a local notification test 🚀"
        content.sound = .default

        // 3. Trigger setelah 5 detik
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

        // 4. Buat request
        let request = UNNotificationRequest(identifier: UUID().uuidString,
                                            content: content,
                                            trigger: trigger)

        // 5. Tambah ke Notification Center
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule notification: \(error)")
            } else {
                print("✅ Local notification scheduled")
            }
        }
    }*/
}

struct NextView: View {
    let name: String
    
    var body: some View {
        Text("Hello, message")
            .font(.largeTitle)
    }
}
