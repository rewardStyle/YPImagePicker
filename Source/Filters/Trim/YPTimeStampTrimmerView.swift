//
//  YPTimeStampTrimmerView.swift
//  YPImagePicker
//
//  Created by Zeph Cohen on 1/16/24.
//  Copyright © 2024 Yummypets. All rights reserved.
//

import AVFoundation
import UIKit
import PryntTrimmerView

public protocol YPTimeStampTrimmerViewDelegate: AnyObject {
    func positionBarDidStopMoving(_ playerTime: CMTime)
    func didChangePositionBar(to playerTime: CMTime)
}

public class YPTimeStampTrimmerView: UIView {

    // MARK: - Properties

    var timeBarLargeCircleColor: UIColor?
    var timeBarSmallCircleColor: UIColor?
    var timeStampFont: UIFont?
    var timeStampColor: UIColor?
    var trimMaskolor: UIColor?

    let trimmerView = TrimmerView()
    let timeStampScrollableView = YPTimeStampScrollableView()
    let rightHandleTimeStamp = UILabel()
    let leftHandleTimeStamp = UILabel()
    private(set) var rightHandleTimeStampConstraint: NSLayoutConstraint?
    private(set) var leftHandleTimeStampConstraint: NSLayoutConstraint?
    private(set) var trimViewTopAnchor: NSLayoutConstraint?
    private(set) var isLaidOut = false
    public var style: TrimmerStyle = .default
    weak var timeStampTrimmerViewDelegate: YPTimeStampTrimmerViewDelegate?

    public enum Constant {
        public static let timeStampTrimViewPadding: CGFloat = 30
    }

    public enum TrimmerStyle {
        case `default`
        case trimmerWithTimeStamps
    }

    public var startTime: CMTime? {
        trimmerView.startTime
    }

    public var endTime: CMTime? {
        trimmerView.endTime
    }

    public var asset: AVAsset? {
        trimmerView.asset
    }

    // MARK: - Init

    public override func layoutSubviews() {
        super.layoutSubviews()
        if !isLaidOut {
            setupSubviews()
            isLaidOut = true
            constraintTrimView()
            constraintTimeStampView()
            constrainRightHandleTimeStamp()
            constraintLeftHandleTimeStamp()
        }
    }

    // MARK: - UI Configuration

    func setupSubviews() {
        setupTrimmerView()
        setupTimeStampView()
        setupRightHandleTimeStamp()
        setupLeftHandleTimeStamp()
    }

    func setupLeftHandleTimeStamp() {
        leftHandleTimeStamp.translatesAutoresizingMaskIntoConstraints = false
        leftHandleTimeStamp.isHidden = true
        addSubview(leftHandleTimeStamp)
        leftHandleTimeStamp.text = ""
        leftHandleTimeStamp.textColor = timeStampColor
        leftHandleTimeStamp.font = timeStampFont
    }

    func setupRightHandleTimeStamp() {
        rightHandleTimeStamp.translatesAutoresizingMaskIntoConstraints = false
        rightHandleTimeStamp.isHidden = true
        addSubview(rightHandleTimeStamp)
        rightHandleTimeStamp.text = ""
        rightHandleTimeStamp.textColor = timeStampColor
        rightHandleTimeStamp.font = timeStampFont
    }

    func setupTimeStampView() {
        timeStampScrollableView.translatesAutoresizingMaskIntoConstraints = false
        timeStampScrollableView.timeBarLargeCircleColor = timeBarLargeCircleColor
        timeStampScrollableView.timeBarSmallCircleColor = timeBarSmallCircleColor
        timeStampScrollableView.timeStampFont = timeStampFont
        timeStampScrollableView.timeStampColor = timeStampColor
        timeStampScrollableView.isHidden = true
        timeStampScrollableView.trimmerMaxDuration = trimmerView.maxDuration
        addSubview(timeStampScrollableView)
    }

    func setupTrimmerView() {
        trimmerView.translatesAutoresizingMaskIntoConstraints = false
        trimmerView.delegate = self
        trimmerView.updateTrimMaskColor(to: trimMaskolor)
        addSubview(trimmerView)
    }

    func constraintLeftHandleTimeStamp() {
        leftHandleTimeStampConstraint = leftHandleTimeStamp.leftAnchor.constraint(equalTo: trimmerView.leftAnchor)
        leftHandleTimeStamp.bottomAnchor.constraint(equalTo: trimmerView.topAnchor, constant: -4.0).isActive = true
        leftHandleTimeStampConstraint?.isActive = true
    }

    func constrainRightHandleTimeStamp() {
        rightHandleTimeStampConstraint = rightHandleTimeStamp.rightAnchor.constraint(equalTo: trimmerView.rightAnchor)
        rightHandleTimeStamp.bottomAnchor.constraint(equalTo: trimmerView.topAnchor, constant: -4.0).isActive = true
        rightHandleTimeStampConstraint?.isActive = true
    }

    func constraintTrimView() {
        trimmerView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        trimmerView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        trimViewTopAnchor = trimmerView.topAnchor.constraint(equalTo: topAnchor, constant: style == .trimmerWithTimeStamps ? 15 : 0)
        trimViewTopAnchor?.isActive = true
        trimmerView.heightAnchor.constraint(equalToConstant: 60).isActive = true
    }

    func constraintTimeStampView() {
        timeStampScrollableView.topAnchor.constraint(equalTo: trimmerView.bottomAnchor, constant: 7).isActive = true
        timeStampScrollableView.leftAnchor.constraint(equalTo: leftAnchor, constant: -Constant.timeStampTrimViewPadding).isActive = true
        timeStampScrollableView.rightAnchor.constraint(equalTo: rightAnchor, constant: Constant.timeStampTrimViewPadding).isActive = true
        timeStampScrollableView.heightAnchor.constraint(greaterThanOrEqualToConstant: 23).isActive = true
    }

    func constructAttributedString(for text: String) -> NSMutableAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 0.97
        return NSMutableAttributedString(string: text, attributes: [NSAttributedString.Key.kern: 0.1, NSAttributedString.Key.paragraphStyle: paragraphStyle])
    }

    func configure(asset: AVAsset, delegate: YPTimeStampTrimmerViewDelegate?) {
        trimmerView.asset = asset
        timeStampTrimmerViewDelegate = delegate
    }

    func toggleTrimmerVisibility(shouldHide: Bool) {
        trimmerView.isHidden = shouldHide
        if style == .trimmerWithTimeStamps {
            timeStampScrollableView.isHidden = shouldHide
        }
    }

    public func seek(to time: CMTime) {
        trimmerView.seek(to: time)
    }
}

// MARK: - TrimmerViewDelegate Conformance

extension YPTimeStampTrimmerView: TrimmerViewDelegate {
    public func didChangeAsset(asset: AVAsset) {
        timeStampScrollableView.asset = asset
        timeStampScrollableView.contentSize = trimmerView.previewContentSize
        timeStampScrollableView.renderRanges()
    }
    
    public func didScrollTrimmer(_ scrollView: UIScrollView) {
        timeStampScrollableView.setContentOffset(scrollView.contentOffset, animated: false)
    }

    public func didBeginDraggingLeftHandleBar() {
        leftHandleTimeStamp.isHidden = false
    }

    public func didBeginDraggingRightHandleBar() {
        rightHandleTimeStamp.isHidden = false
    }

    public func didDragLeftHandleBar(to updatedConstant: CGFloat) {
        self.leftHandleTimeStampConstraint?.constant = updatedConstant
    }

    public func didDragRightHandleBar(to updatedConstant: CGFloat) {
        self.rightHandleTimeStampConstraint?.constant = updatedConstant
    }

    public func didChangePositionBar(_ playerTime: CMTime) {
        if style == .trimmerWithTimeStamps {
            if rightHandleTimeStamp.isHidden {
                leftHandleTimeStamp.attributedText = constructAttributedString(for: playerTime.durationText)
            } else {
                rightHandleTimeStamp.attributedText = constructAttributedString(for: playerTime.durationText)
            }
        }
        timeStampTrimmerViewDelegate?.didChangePositionBar(to: playerTime)
    }

    public func positionBarStoppedMoving(_ playerTime: CMTime) {
        timeStampTrimmerViewDelegate?.positionBarDidStopMoving(playerTime)
        rightHandleTimeStamp.isHidden = true
        leftHandleTimeStamp.isHidden = true
    }
}

