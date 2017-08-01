//
//  CoachmarkView.swift
//  CoachMarks
//
//  Created by Pierluigi D'Andrea on 31/01/17.
//  Copyright © 2017 pNre. All rights reserved.
//

import UIKit

public class CoachmarkView: UIView {

    /// Key of the dismissal animation when the coachmark was dismissed
    fileprivate static let dismissalAnimationKey = "dismissalAnimationKey"

    // MARK: - Properties
    weak var delegate: CoachmarkViewDelegate?
    weak var appearanceDelegate: CoachmarkViewAppearanceDelegate?

    private var animationDuration: TimeInterval {
        return appearanceDelegate?.coachmarkViewAnimationsDuration(self) ?? 0.2
    }

    // MARK: - Appearance
    public var textEdgeInsets: UIEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20) {
        didSet {
            guard textEdgeInsets != oldValue else {
                return
            }

            setNeedsLayout()
        }
    }

    /// Area that the coachmark is focusing on.
    fileprivate private(set) var sourceRect: CGRect = .zero {
        didSet {
            subviews.forEach { $0.setNeedsLayout() }
            setNeedsLayout()
            layoutIfNeeded()
        }
    }

    /// Background CircularView.
    fileprivate private(set) lazy var outerCircle: CircularView = {

        let view = CircularView()

        view.shapeLayer.fillColor = self.tintColor.cgColor
        view.delegate = self
        view.circleScale = 0.95
        view.isHidden = true

        view.addSubview(self.textLabel)

        return view

    }()

    /// CircularView used as background for the `snapshotView` (when visible).
    fileprivate private(set) lazy var innerCircle: CircularView = {

        let view = CircularView()

        view.shapeLayer.fillColor = UIColor.white.cgColor
        view.circleScale = 1.2
        view.isHidden = true

        return view

    }()

    /// Snapshot of the view the coachmark is focusing on.
    private var snapshotView: UIView? {
        didSet {
            oldValue?.removeFromSuperview()

            if let snapshotView = snapshotView {
                addSubview(snapshotView)
                insertSubview(snapshotView, aboveSubview: innerCircle)
            }
        }
    }

    /// Content of the coachmark
    public private(set) lazy var textLabel: UILabel = {

        let label = UILabel()

        label.numberOfLines = 0
        label.textColor = .white
        label.font = UIFont.preferredFont(forTextStyle: .headline)

        return label

    }()

    // MARK: - Init
    override init(frame: CGRect) {

        super.init(frame: frame)
        commonInit()

    }

    required public init?(coder aDecoder: NSCoder) {

        super.init(coder: aDecoder)
        commonInit()

    }

    private func commonInit() {

        isUserInteractionEnabled = false
        isHidden = true

        addSubview(innerCircle)
        addSubview(outerCircle)

        let recognizer = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        recognizer.numberOfTapsRequired = 1
        recognizer.delegate = self

        addGestureRecognizer(recognizer)

    }

    // MARK: - Tint
    public override func tintColorDidChange() {

        super.tintColorDidChange()

        outerCircle.shapeLayer.fillColor = tintColor.cgColor

    }

    // MARK: - Layout
    override public func layoutSubviews() {

        super.layoutSubviews()

        //  outer circle
        outerCircle.frame = {

            let size = CGSize(width: ceil(frame.width * 2.0),
                              height: ceil(frame.width * 2.0))

            let origin = CGPoint(x: sourceRect.midX - (size.width / 2.0),
                                 y: sourceRect.midY - (size.height / 2.0))

            return CGRect(origin: origin, size: size)

        }()

        var rect = sourceRect
        let dimension = max(rect.width, rect.height)
        rect.size = CGSize(width: dimension, height: dimension)

        //  inner circle
        innerCircle.frame = rect
        innerCircle.center = outerCircle.center

        //  text content
        textLabel.frame = {

            //  diameter and radius of the outer circle
            let diameter = outerCircle.shapeLayer.path?.boundingBox.width ?? (outerCircle.bounds.width * outerCircle.circleScale)
            let radius = diameter / 2.0

            //  size of the rect inscribed into outerCricle
            let inscribedRectWidth = radius * sqrt(3)
            let inscribedRectHeight = radius

            //  origin of the rect relative to outerCircle
            let inscribedRectX = (outerCircle.bounds.width - diameter) / 2.0 + (diameter - inscribedRectWidth) / 2.0
            let inscribedRectY = (outerCircle.bounds.height - diameter) / 2.0 + radius / 2.0

            let inscribedRect = CGRect(x: inscribedRectX, y: inscribedRectY, width: inscribedRectWidth, height: inscribedRectHeight).integral

            //  rect relative to self
            let relativeInscribedRect = outerCircle.convert(inscribedRect, to: self)

            //  intersection of the rect with the view bounds
            var intersection = convert(relativeInscribedRect.intersection(bounds), to: outerCircle)

            //  text insets
            let insets = textEdgeInsets

            //  innerCircle frame relative to outerCircle
            let innerCircleRelativeFrame = convert(innerCircle.frame, to: outerCircle)

            //  if the innerCircle is hidden there's no need to move the label
            if !innerCircle.isHidden, intersection.intersects(innerCircleRelativeFrame) {

                //  the label is over the circle
                if intersection.midY < innerCircleRelativeFrame.midY {
                    let extraMargin = intersection.maxY - innerCircleRelativeFrame.minY
                    intersection.size.height -= extraMargin
                } else {
                    let extraMargin = innerCircleRelativeFrame.maxY - intersection.minY
                    intersection.origin.y += extraMargin
                    intersection.size.height -= extraMargin
                }

            }

            var frameWithEdges = UIEdgeInsetsInsetRect(intersection, insets)

            //  adjust the label size to fit the content
            let size = textLabel.sizeThatFits(frameWithEdges.size)

            if frameWithEdges.midY < outerCircle.bounds.midY {
                frameWithEdges.origin.y += (frameWithEdges.size.height - size.height) / 2.0
            }

            frameWithEdges.size.height = size.height

            return frameWithEdges

        }()

    }

    override public func didMoveToSuperview() {

        super.didMoveToSuperview()

        guard superview == nil else {
            return
        }

        snapshotView = nil

        isHidden = true
        isUserInteractionEnabled = false

    }

    // MARK: - Presentation

    /// Presents the coachmark from the `rect` of a `view`.
    ///
    /// - Parameters:
    ///   - view: View that is requesting the presentation.
    ///   - rect: `CGRect` in which the coachmark is centered.
    ///   - focusingOnElement: If `true`, takes a snapshot of `view` and add it as a subview.
    public func present(in view: UIView, from rect: CGRect, focusingOnElement: Bool = true) {

        isUserInteractionEnabled = true
        isHidden = false

        sourceRect = rect

        textLabel.alpha = 0

        UIView.animate(withDuration: animationDuration) {
            self.textLabel.alpha = 1
        }

        let dimension = sqrt(rect.width * rect.width + rect.height * rect.height)
        let snapshotRect = CGRect(x: rect.origin.x + (rect.width - dimension) / 2.0,
                                  y: rect.origin.y + (rect.height - dimension) / 2.0,
                                  width: dimension,
                                  height: dimension).integral.intersection(view.bounds)

        if focusingOnElement, let snapshot = view.snapshot(of: snapshotRect, from: view) {

            view.layoutIfNeeded()

            snapshotView = UIImageView(image: snapshot)
            snapshotView?.frame = snapshotRect

            innerCircle.isHidden = false
            innerCircle.animatePath(withDuration: animationDuration, fromValue: 0.0)

        } else {

            innerCircle.isHidden = true

        }

        outerCircle.isHidden = false

        if #available(iOS 9, *) {
            outerCircle.animatePath(fromValue: 0.0)
        } else {
            outerCircle.animatePath(withDuration: animationDuration, fromValue: 0.0)
        }

        setNeedsLayout()
        layoutIfNeeded()

    }

    /// Dismisses the coachmark.
    func dismiss() {

        isUserInteractionEnabled = false

        outerCircle.animatePathCompression(withDuration: animationDuration, animationTag: CoachmarkView.dismissalAnimationKey)

        if !innerCircle.isHidden {
            innerCircle.animatePathCompression(withDuration: animationDuration, animationTag: CoachmarkView.dismissalAnimationKey)
        }

        UIView.animate(withDuration: animationDuration, animations: {
            self.textLabel.alpha = 0
        }, completion: { [weak self] _ in
            self?.snapshotView = nil
        })

    }

}

// MARK: - Gesture recognizer
extension CoachmarkView: UIGestureRecognizerDelegate {

    func tapAction(_ recognizer: UITapGestureRecognizer) {

        guard recognizer.state == .recognized else {
            return
        }

        dismiss()

    }

}

// MARK: - CircularViewDelegate
extension CoachmarkView: CircularViewDelegate {

    public func circularView(_ view: CircularView, animationDidStop anim: CAAnimation, finished flag: Bool) {

        let tag = anim.value(forKey: CircularView.animationTagKey) as? String

        guard tag == CoachmarkView.dismissalAnimationKey else {
            return
        }

        view.isHidden = true
        isHidden = true

        delegate?.coachmarkViewDidComplete(self)

    }

    public func circularView(_ view: CircularView, pathFrom path: UIBezierPath) -> UIBezierPath {

        guard !innerCircle.isHidden else {
            return path
        }

        var rect = sourceRect
        let dimension = max(rect.width, rect.height)
        rect.size = CGSize(width: dimension, height: dimension)

        //  Cut a hole in the center of the path
        let cutoutPath = UIBezierPath(roundedRect: rect.centered(in: path.bounds).integral, cornerRadius: dimension / 2.0)
        path.append(cutoutPath.reversing())

        return path

    }

}
