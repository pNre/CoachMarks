//
//  CircularView.swift
//  CoachMarks
//
//  Created by Pierluigi D'Andrea on 28/10/16.
//  Copyright © 2017 pNre. All rights reserved.
//

import UIKit

public class CircularView: UIView {

    /// Key that is used to set the tag on path animations.
    public static let animationTagKey = "CircularViewAnimationTag"

    /// `CAShapeLayer` having the circular shape.
    public private(set) lazy var shapeLayer = CAShapeLayer()

    /// Delegate class that can control the `shapeLayer` path and receive path animations events.
    public weak var delegate: CircularViewDelegate?

    /// Scale to apply to the bounds of the `shapeLayer` path.
    public var circleScale: CGFloat = 0.9

    // MARK: - Init
    override public init(frame: CGRect) {

        super.init(frame: frame)
        commonInit()

    }

    required public init?(coder aDecoder: NSCoder) {

        super.init(coder: aDecoder)
        commonInit()

    }

    private func commonInit() {

        layer.addSublayer(shapeLayer)

        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.actions = ["bounds": NSNull()]

    }

    // MARK: - Layout
    public override func layoutSublayers(of layer: CALayer) {

        super.layoutSublayers(of: layer)

        guard layer == self.layer else {
            return
        }

        updateLayout()

    }

    private func updateLayout() {

        let size = min(bounds.width, bounds.height)

        let layerBounds = CGRect(x: 0, y: 0, width: size, height: size)
            .applying(.init(scaleX: circleScale, y: circleScale))
            .integral

        let layerFrame = layerBounds.centered(in: bounds).integral

        let basePath = UIBezierPath(roundedRect: layerBounds,
                                    cornerRadius: layerBounds.height / 2.0)

        shapeLayer.frame = layerFrame
        shapeLayer.path = (delegate?.circularView(self, pathFrom: basePath) ?? basePath).cgPath

    }

    /// Animates the `scale` of `shapeLayer`.
    ///
    /// - Note: This method animates the path using a `CASpringAnimation`.
    ///
    /// - parameter fromValue: Initial scale value
    @available(iOS 9.0, *)
    public func animatePath(fromValue: CGFloat = 0.5, animationTag: String? = nil) {

        updateLayout()

        let pathAnimation = CASpringAnimation(keyPath: "transform.scale")

        pathAnimation.initialVelocity = 5.0
        pathAnimation.damping = 8
        pathAnimation.isCumulative = true

        pathAnimation.fromValue = fromValue
        pathAnimation.toValue = 1.0
        pathAnimation.duration = pathAnimation.settlingDuration

        pathAnimation.isRemovedOnCompletion = false
        pathAnimation.fillMode = kCAFillModeForwards

        pathAnimation.setValue(true, forKey: "isCircularViewPathAnimation")
        pathAnimation.setValue(animationTag, forKey: CircularView.animationTagKey)
        
        pathAnimation.delegate = self
        
        shapeLayer.add(pathAnimation, forKey: "pathAnimation")
        
    }

    /// Animates the `scale` of `shapeLayer`.
    ///
    /// - Note: This method animates the path using a `CABasicAnimation`.
    ///
    /// - Parameter duration: Duration of the animation
    /// - parameter fromValue: Initial scale value
    public func animatePath(withDuration duration: TimeInterval, fromValue: CGFloat = 0.5, animationTag: String? = nil) {

        updateLayout()

        let pathAnimation = CABasicAnimation(keyPath: "transform.scale")

        pathAnimation.fromValue = fromValue
        pathAnimation.toValue = 1.0
        pathAnimation.duration = duration

        pathAnimation.isRemovedOnCompletion = false
        pathAnimation.fillMode = kCAFillModeForwards

        pathAnimation.setValue(true, forKey: "isCircularViewPathAnimation")
        pathAnimation.setValue(animationTag, forKey: CircularView.animationTagKey)

        pathAnimation.delegate = self
    
        shapeLayer.add(pathAnimation, forKey: "pathAnimation")

    }

    /// Scale down the circle, animated.
    ///
    /// - Parameters:
    ///   - duration: Animation duration
    ///   - animationTag: Tag to set on the animation
    public func animatePathCompression(withDuration duration: TimeInterval, animationTag: String? = nil) {

        let pathAnimation = CABasicAnimation(keyPath: "transform.scale")

        pathAnimation.fromValue = 1.0
        pathAnimation.toValue = 0.0
        pathAnimation.duration = duration

        pathAnimation.isRemovedOnCompletion = false
        pathAnimation.fillMode = kCAFillModeForwards

        pathAnimation.setValue(true, forKey: "isCircularViewPathAnimation")
        pathAnimation.setValue(animationTag, forKey: CircularView.animationTagKey)

        pathAnimation.delegate = self

        shapeLayer.add(pathAnimation, forKey: "pathAnimation")

    }

    /// Cancels an animation previously added calling `animatePath`.
    public func cancelPathAnimation() {

        shapeLayer.removeAnimation(forKey: "pathAnimation")

    }

}

extension CircularView: CAAnimationDelegate {

    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {

        guard anim.value(forKey: "isCircularViewPathAnimation") as? Bool == true else {
            return
        }

        delegate?.circularView(self, animationDidStop: anim, finished: flag)

    }

}

public protocol CircularViewDelegate: class {

    /// Gives the delegate the opportunity to customize the path of the `shapeLayer`.
    ///
    /// - Parameters:
    ///   - view: The CircularView that is updating its `shapeLayer`.
    ///   - path: The default UIBezierPath initialized by the CircularView.
    ///   The path is a circle centered in the view bounds having `d = min(bounds.h, bounds.w) * circleScale`.
    /// - Returns: UIBezierPath to set on the `shapeLayer`.
    func circularView(_ view: CircularView, pathFrom path: UIBezierPath) -> UIBezierPath

    /// Tells the delegate the animation an animation (either started from `animatePath` or
    /// `animatePathCompression`) has ended.
    ///
    /// - Parameters:
    ///   - view: The CircularView that was animated.
    ///   - anim: The CAAnimation object that has ended.
    ///   - flag: A flag indicating whether the animation has completed by reaching the end of its duration.
    func circularView(_ view: CircularView, animationDidStop anim: CAAnimation, finished flag: Bool)

}
