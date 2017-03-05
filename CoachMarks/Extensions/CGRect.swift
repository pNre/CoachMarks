//
//  CGRect.swift
//  CoachMarks
//
//  Created by Pierluigi D'Andrea on 26/02/17.
//  Copyright © 2017 pNre. All rights reserved.
//

import CoreGraphics

extension CGRect {

    /// Centers the reciver in `rect`.
    ///
    /// - Note: The origin of the centered `CGRect` is relative to `rect`.
    ///
    /// - Parameter rect: `CGRect` into which the receiver will be centered.
    /// - Returns: Centered rect
    func centered(in rect: CGRect) -> CGRect {

        let originX = floor((rect.width - width) / 2.0)
        let originY = floor((rect.height - height) / 2.0)

        return CGRect(x: originX,
                      y: originY,
                      width: width,
                      height: height)
        
    }

}
