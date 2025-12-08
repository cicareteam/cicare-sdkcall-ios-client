import UIKit
import SwiftUI

public class CallScreenViewController: UIViewController {
    // Public properties for preview
    public var calleeName: String = "John Doe"
    public var callStatus: String = "connected" // incoming / connected
    public var avatarUrl: String? = nil
    public var metaData: [String:String] = [
        "call_title": "Call Free",
        "call_incoming": "Incoming Call",
        "call_connected": "Connected",
        "call_btn_mute": "Mute",
        "call_btn_speaker": "Speaker"
    ]

    // UI Components
    var statusLabel = UILabel()
    var avatarImageView = UIImageView()
    var nameLabel = UILabel()
    var connectionLabel = UILabel()
    var muteButton: CircleIconButton!
    var speakerButton: CircleIconButton!
    var endButton: CircleIconButton!
    var incomingButtonStack = UIStackView()
    var connectedButtonStack = UIStackView()

    var dismissed = false
    var pendingDismissed = false
    var isConnected = false
    var isMuted = true
    var isSpeakerOn = false

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue
        let gradientBackground = MultiLayerGradientView(frame: view.bounds)
        gradientBackground.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(gradientBackground, at: 0)
        setupUI()
    }

    // MARK: - UI Setup
    private func setupUI() {
        self.dismissed = false
        self.pendingDismissed = false
        self.isConnected = false

        let titleLabel = UILabel()
        titleLabel.text = metaData["call_title"] ?? "Call Free"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 22)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .black

        let titleStack = UIStackView(arrangedSubviews: [titleLabel])
        titleStack.axis = .vertical
        titleStack.spacing = 10
        titleStack.alignment = .center
        titleStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleStack)
        
        nameLabel.text = calleeName
        nameLabel.font = UIFont.boldSystemFont(ofSize: 18)
        nameLabel.textColor = .black
        nameLabel.textAlignment = .center

        statusLabel.text = self.metaData["call_\(callStatus)"] ?? callStatus
        statusLabel.font = UIFont.systemFont(ofSize: 16)
        statusLabel.textColor = .black
        statusLabel.textAlignment = .center

        let statusStack = UIStackView(arrangedSubviews: [nameLabel, statusLabel])
        statusStack.axis = .vertical
        statusStack.spacing = 8
        statusStack.alignment = .center
        statusStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statusStack)

        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.layer.cornerRadius = 80
        avatarImageView.clipsToBounds = true
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(avatarImageView)

        if let urlStr = avatarUrl, let url = URL(string: urlStr) {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data {
                    DispatchQueue.main.async { self.avatarImageView.image = UIImage(data: data) }
                }
            }.resume()
        } else {
            avatarImageView.image = UIImage(systemName: "person.fill")
            avatarImageView.tintColor = .black
            avatarImageView.backgroundColor = .systemGray5
        }

        connectionLabel.text = ""
        connectionLabel.font = UIFont.systemFont(ofSize: 14)
        connectionLabel.textColor = .red
        connectionLabel.textAlignment = .center

        let nameLabelStack = UIStackView(arrangedSubviews: [ connectionLabel])
        nameLabelStack.axis = .vertical
        nameLabelStack.spacing = 8
        nameLabelStack.alignment = .center
        nameLabelStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabelStack)

        incomingButtonStack = UIStackView(arrangedSubviews: incomingButtons())
        incomingButtonStack.axis = .vertical
        incomingButtonStack.spacing = 50
        incomingButtonStack.alignment = .center
        incomingButtonStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(incomingButtonStack)

        connectedButtonStack = UIStackView(arrangedSubviews: connectedButtons())
        connectedButtonStack.axis = .vertical
        connectedButtonStack.spacing = 50
        connectedButtonStack.alignment = .center
        connectedButtonStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(connectedButtonStack)

        NSLayoutConstraint.activate([
            titleStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            statusStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusStack.bottomAnchor.constraint(equalTo: avatarImageView.topAnchor, constant: -20),

            avatarImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            avatarImageView.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            avatarImageView.widthAnchor.constraint(equalToConstant: 160),
            avatarImageView.heightAnchor.constraint(equalToConstant: 160),

            nameLabelStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nameLabelStack.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 30),

            incomingButtonStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            incomingButtonStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),

            connectedButtonStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            connectedButtonStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40)
        ])

        if callStatus == "incoming" {
            incomingButtonStack.isHidden = false
            connectedButtonStack.isHidden = true
        } else {
            incomingButtonStack.isHidden = true
            connectedButtonStack.isHidden = false
        }
    }

    private func incomingButtons() -> [UIView] {
        let mute = CircleIconButton(icon: UIImage(systemName: "mic.slash")!, labelText: "Mute", iconColor: .black, backgroundColor: UIColor.systemGray.withAlphaComponent(0.1)) {}
        mute.widthAnchor.constraint(equalToConstant: 64).isActive = true

        let speaker = CircleIconButton(icon: UIImage(systemName: "speaker.wave.2")!, labelText: "Speaker", iconColor: .black, backgroundColor: UIColor.systemGray.withAlphaComponent(0.1)) {}
        speaker.widthAnchor.constraint(equalToConstant: 64).isActive = true

        let endCall = CircleIconButton(icon: UIImage(systemName: "xmark")!, labelText: "", iconColor: .white, backgroundColor: .red) {}
        endCall.widthAnchor.constraint(equalToConstant: 64).isActive = true

        let answerCall = CircleIconButton(icon: UIImage(systemName: "phone.fill")!, labelText: "", iconColor: .white, backgroundColor: .green) {}
        answerCall.widthAnchor.constraint(equalToConstant: 64).isActive = true

        let audioStack = UIStackView(arrangedSubviews: [speaker, mute])
        audioStack.axis = .horizontal
        audioStack.spacing = 120
        audioStack.alignment = .center

        let actionStack = UIStackView(arrangedSubviews: [endCall, answerCall])
        actionStack.axis = .horizontal
        actionStack.spacing = 120
        actionStack.alignment = .center

        return [audioStack, actionStack]
    }

    private func connectedButtons() -> [UIView] {
        let mute = CircleIconButton(icon: UIImage(systemName: "mic.slash")!, labelText: "Mute", iconColor: .black, backgroundColor: UIColor.systemGray.withAlphaComponent(0.1)) {}
        mute.widthAnchor.constraint(equalToConstant: 64).isActive = true

        let speaker = CircleIconButton(icon: UIImage(systemName: "speaker.wave.2")!, labelText: "Speaker", iconColor: .black, backgroundColor: UIColor.systemGray.withAlphaComponent(0.1)) {}
        speaker.widthAnchor.constraint(equalToConstant: 64).isActive = true

        let end = CircleIconButton(icon: UIImage(systemName: "xmark")!, labelText: "", iconColor: .white, backgroundColor: .red) {}
        end.widthAnchor.constraint(equalToConstant: 64).isActive = true

        let audioStack = UIStackView(arrangedSubviews: [speaker, mute])
        audioStack.axis = .horizontal
        audioStack.spacing = 120
        audioStack.alignment = .center

        return [audioStack, end]
    }
}

// MARK: - Preview Wrapper
struct CallScreenPreview: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let vc = CallScreenViewController()
        vc.calleeName = "John Doe"
        vc.callStatus = "conected"
        vc.avatarUrl = "https://via.placeholder.com/150"
        return vc
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

struct CallScreenPreview_Previews: PreviewProvider {
    static var previews: some View {
        CallScreenPreview()
            .previewDevice("iPhone 14 Pro")
    }
}
