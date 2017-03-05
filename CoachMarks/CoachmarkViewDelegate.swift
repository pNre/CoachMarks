//
//  CoachmarkViewDelegate.swift
//  CoachMarks
//
//  Created by Pierluigi D'Andrea on 26/02/17.
//  Copyright © 2017 pNre. All rights reserved.
//

import UIKit

// MARK: - CoachmarkViewAppearanceDelegate
public protocol CoachmarkViewAppearanceDelegate: class {

    /// Duration of the presentation and dismissal animations of `view`.
    ///
    /// - Parameter view: CoachmarkView asking for the animations duration.
    /// - Returns: Duration of the CoachmarkView animations
    func coachmarkViewAnimationsDuration(_ view: CoachmarkView) -> TimeInterval

}

// MARK: - CoachmarkViewDelegate
public protocol CoachmarkViewDelegate: class {

    /// Notifies the delegate that a CoachmarkView was dismissed.
    ///
    /// - Parameters:
    ///   - view: CoachmarkView that was dismissed.
    func coachmarkViewDidComplete(_ view: CoachmarkView)

}
