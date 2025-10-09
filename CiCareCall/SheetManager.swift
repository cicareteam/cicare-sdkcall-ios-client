//
//  SheetManager.swift
//  CiCareCall
//
//  Created by Mohammad Annas Al Hariri on 07/10/25.
//


import UIKit
import FittedSheets

class SheetManager {
    static let shared = SheetManager()
    private init() {}
    
    var activeSheet: SheetViewController?
    
    func presentSheet(_ controller: UIViewController) {
        let sheet = SheetViewController(controller: controller, sizes: [.fixed(300)])
        sheet.dismissOnPull = true
        sheet.dismissOnOverlayTap = true
        
        if let rootVC = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow })?
            .rootViewController {
            
            rootVC.present(sheet, animated: true, completion: nil)
            self.activeSheet = sheet
        }
    }
    
    func dismissActiveSheet(animated: Bool = false, completion: (() -> Void)? = nil) {
        guard let sheet = activeSheet else {
            completion?()
            return
        }
        sheet.dismiss(animated: animated) {
            self.activeSheet = nil
            completion?()
        }
    }
}
