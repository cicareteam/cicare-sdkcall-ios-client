import SwiftUI
import UserNotifications
import CiCareSDKCall
import FittedSheets



struct ContentView: View {
    @State private var isLoggedIn = false
    @State private var currentUserId: Int = 0
    @State private var username: String = ""
    @State private var avatar: String = ""
    @State private var loginError: String? = nil   // <-- untuk menampilkan error
    
    var body: some View {
        NavigationStack {
            if isLoggedIn {
                CallView(
                    currentUserId: currentUserId,
                    username: username,
                    onLogout: logout
                )
            } else {
                LoginView(
                    errorMessage: loginError,     // <-- pass error message
                    onLogin: login
                )
            }
        }
        .onAppear {
            // Autologin jika ada data di UserDefaults
            if let savedId = UserDefaults.standard.string(forKey: "currentUserId"),
               let savedUsername = UserDefaults.standard.string(forKey: "username"),
               let avatarUrl = UserDefaults.standard.string(forKey: "avatar") {
                
                currentUserId = Int(savedId)!
                username = savedUsername
                avatar = avatarUrl
                isLoggedIn = true
                
                // Registrasi ulang ke VoipManager
                VoipManager.shared.userId = savedId
                VoipManager.shared.regist()
            }
        }
    }
    
    private func login(username: String, password: String) {
        self.loginError = nil
        guard let url = URL(string: "https://sip-gw.c-icare.cc:4443/api/login") else { return }
        
        let body: [String: Any] = [
            "username": username,
            "password": password,
            "type": "ios"
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.loginError = "Login error: \(error.localizedDescription)"
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.loginError = "No response data"
                }
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                   if let success = json["success"] as? Bool, success == true,
                      let user = json["user"] as? [String: Any] {
                       print(user)
                       if let id = user["id"] as? Int,
                          let username = user["username"] as? String {
                           self.isLoggedIn = true
                           print("login success")
                           
                           DispatchQueue.main.async {
                               self.currentUserId = id
                               self.username = username
                               self.avatar = user["avatar_url"] as? String ?? ""
                               self.isLoggedIn = true
                               self.loginError = nil
                               
                               // Simpan ke UserDefaults
                               UserDefaults.standard.set(id, forKey: "currentUserId")
                               UserDefaults.standard.set(username, forKey: "username")
                               UserDefaults.standard.set(avatar, forKey: "avatar")
                               
                               // Registrasi VoIP
                               VoipManager.shared.userId = "\(id)"
                               VoipManager.shared.regist()
                           }
                       }
                   } else {
                       DispatchQueue.main.async {
                           self.loginError = "Invalid username or password"
                       }
                   }
                    
                } else {
                    DispatchQueue.main.async {
                        self.loginError = "Invalid username or password"
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.loginError = "JSON parse error: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
    
    private func logout() {
        // Hapus data login
        UserDefaults.standard.removeObject(forKey: "currentUserId")
        UserDefaults.standard.removeObject(forKey: "username")
        UserDefaults.standard.removeObject(forKey: "avatar")
        
        currentUserId = 0
        username = ""
        avatar = ""
        isLoggedIn = false
    }
}

struct LoginView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var isLoading = false
    var errorMessage: String?   // <-- tampilkan pesan error
    var onLogin: (String, String) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Login")
                .padding()
                .font(.largeTitle)
            
            TextField("Your Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            if isLoading {
                ProgressView("Logging in...")
            }
            
            Button("Login") {
                guard !username.isEmpty && !password.isEmpty else { return }
                isLoading = true
                onLogin(username, password)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    isLoading = false
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

class MyViewController: UIViewController {

    private let titleLabel = UILabel()
    private let closeButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        // Title
        titleLabel.text = "Hello from MyViewController!"
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)

        // Close button
        closeButton.setTitle("Close", for: .normal)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)

        // Layout
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(titleLabel)
        view.addSubview(closeButton)

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            closeButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            closeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    @objc private func closeTapped() {
        self.dismiss(animated: true)
    }
}

struct CallView: View {
    let currentUserId: Int
    let username: String
    let onLogout: () -> Void
    
    @State private var users: [(id: String, name: String, avatar: String)] = []
    @State private var isLoading = true
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Welcome, \(username)")
                    .font(.headline)
                Spacer()
                Button("Logout") {
                    onLogout()
                }
                .buttonStyle(.bordered)
                .tint(.red)
            }
            
            if isLoading {
                ProgressView("Loading users...")
            } else {
                List(users, id: \.id) { user in
                    HStack {
                        AsyncImage(url: URL(string: user.avatar)) { img in
                            img.resizable()
                                .scaledToFill()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                        } placeholder: {
                            ProgressView()
                        }
                        
                        Text(user.name)
                        
                        Spacer()
                        
                        Button("Call") {
                            makeCall(to: user)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(.vertical, 4)
                }
            }
            Button("Show Sheet") {
                let controller = MyViewController()

                SheetManager.shared.presentSheet(controller)
            }
        }
        .padding()
        .onAppear {
            fetchUsers()
        }
    }
    
    private func fetchUsers() {
        guard let url = URL(string: "https://sip-gw.c-icare.cc:4443/api/user-online?user_id=\(currentUserId)") else { return }
        
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        //request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            defer { DispatchQueue.main.async { isLoading = false } }
            
            if let error = error {
                print("❌ Fetch users error:", error.localizedDescription)
                return
            }
            
            guard let data = data else { return }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                    let fetchedUsers = json.compactMap { item -> (id: String, name: String, avatar: String)? in
                        guard let id = item["id"] as? Int,
                              let name = item["username"] as? String else {
                            return nil
                        }
                        //print("idd \(id)")
                        let avatar = item["avatar_url"] as? String ?? "https://avatar.iran.liara.run/public/boy"
                        return ("\(id)", name, avatar)
                    }
                    DispatchQueue.main.async {
                        self.users = fetchedUsers // exclude diri sendiri
                    }
                } else {
                    print("❌ Invalid user list response")
                }
            } catch {
                print("❌ JSON parse error:", error.localizedDescription)
            }
        }.resume()
    }
    
    func makeCall(to user: (id: String, name: String, avatar: String)) {
        // Setup API pakai token login
        CicareSdkCall.shared.setAPI(baseUrl: "https://sip-gw.c-icare.cc:8443", token: "a1b2c3d4e5f60718293a4b5c6d7e8f90123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef")
        
        CicareSdkCall.shared.outgoing(
            callerId: "\(currentUserId)",
            callerName: username,
            callerAvatar: "https://avatar.iran.liara.run/public/boy",
            calleeId: user.id,
            calleeName: user.name,
            calleeAvatar: user.avatar,
            checkSum: "asdfasdf",
            metaData: [
                "call_title": "Free Call",
                "call_not_found": "Call not found"
            ]
        )
    }
}
