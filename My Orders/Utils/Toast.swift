import UIKit

class Toast {
    static func showToast(message: String) {
        
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        
        if let window = windowScene?.windows.first {
            let toastLabel = UILabel(frame: CGRect(x: window.frame.size.width/2 - 150, y: window.frame.size.height-100, width: 300, height: 35))
            toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            toastLabel.textColor = UIColor.white
            toastLabel.textAlignment = .center
            toastLabel.font = UIFont.systemFont(ofSize: 12)
            toastLabel.text = message
            toastLabel.alpha = 1.0
            toastLabel.layer.cornerRadius = 10
            toastLabel.clipsToBounds = true

            window.addSubview(toastLabel)

            UIView.animate(withDuration: 3.0, delay: 0.1, options: .curveEaseOut, animations: {
                toastLabel.alpha = 0.0
            }, completion: { _ in
                toastLabel.removeFromSuperview()
            })
        }
    }
}
