//
//  YPPermissionDeniedPopup.swift
//  YPImagePicker
//
//  Created by Sacha DSO on 12/03/2018.
//  Copyright © 2018 Yummypets. All rights reserved.
//

import UIKit

internal struct YPPermissionDeniedPopup {
    static func buildGoToSettingsAlert(cancelBlock: @escaping () -> Void) -> UIAlertController {
        let alert = UIAlertController(title:
                                        YPConfig.wordings.permissionPopup.title,
                                      message: YPConfig.wordings.permissionPopup.message,
                                      preferredStyle: .alert)
        alert.addAction(
            UIAlertAction(title: YPConfig.wordings.permissionPopup.cancel,
                          style: UIAlertAction.Style.cancel,
                          handler: { _ in
                            cancelBlock()
                          }))
        alert.addAction(
            UIAlertAction(title: YPConfig.wordings.permissionPopup.grantPermission,
                          style: .default,
                          handler: { _ in
                            if #available(iOS 10.0, *) {
                                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                            } else {
                                UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)
                            }
                          }))
        if let alertInterfaceStyle = YPConfig.alertInterfaceStyle {
            alert.overrideUserInterfaceStyle = alertInterfaceStyle
        }
        if let alertTintColor = YPConfig.colors.alertTintColor {
            alert.view.tintColor = alertTintColor
        }
        return alert
    }
}
