//
//  UIView.swift
//  CoachMarks
//
//  Created by Pierluigi D'Andrea on 26/02/17.
//  Copyright © 2017 pNre. All rights reserved.
//

import UIKit

extension UIView {

    /// Snapshots a view and crops it to `rect`.
    ///
    /// - Parameters:
    ///   - rect: `CGRect` defining the area to crop the image to
    ///   - view: View to snapshot
    /// - Returns: Cropped snapshot or `nil` on failure.
    func snapshot(of rect: CGRect, from view: UIView) -> UIImage? {

        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, UIScreen.main.scale)

        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }

        view.layer.render(in: context)

        defer {
            UIGraphicsEndImageContext()
        }

        guard let image = UIGraphicsGetImageFromCurrentImageContext(), let cgImage = image.cgImage else {
            return nil
        }

        guard let croppedImageRef = cgImage.cropping(to: rect.applying(.init(scaleX: image.scale, y: image.scale))) else {
            return nil
        }

        return UIImage(cgImage: croppedImageRef, scale: image.scale, orientation: image.imageOrientation)

    }

}
