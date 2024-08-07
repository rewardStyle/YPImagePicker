//
//  YPLibraryViewCell.swift
//  YPImgePicker
//
//  Created by Sacha Durand Saint Omer on 2015/11/14.
//  Copyright © 2015 Yummypets. All rights reserved.
//

import UIKit
import Stevia

class YPMultipleSelectionIndicator: UIView {
    
    let circle = UIView()
    let label = UILabel()
    let imageView = UIImageView()
    var unselectedColor = UIColor.white.withAlphaComponent(0.3)
    var unselectedBorderColor = UIColor.white
    var selectionColor = UIColor.ypSystemBlue
    var selectionBorderColor = UIColor.clear

    convenience init() {
        self.init(frame: .zero)

        let size: CGFloat = 20

        if YPConfig.library.isBulkUploading {
            subviews(
                circle,
                imageView
            )
            circle.fillContainer()
            circle.size(size)
            imageView.fillContainer(padding: 3)
            imageView.size(size)
            imageView.image = YPConfig.icons.checkIcon
            imageView.contentMode = .scaleAspectFit
            imageView.clipsToBounds = true
        } else {
            subviews(
                circle,
                label
            )
            circle.fillContainer()
            circle.size(size)
            label.fillContainer()
            label.textAlignment = .center
            label.textColor = .white
            label.font = YPConfig.fonts.multipleSelectionIndicatorFont
        }

        circle.layer.cornerRadius = size / 2.0

        
        set(number: nil)
    }
    
    func set(number: Int?) {
        label.isHidden = (number == nil)
        let isHiddenDuringBulkUploads = YPConfig.library.isBulkUploading && number == nil
        circle.isHidden = isHiddenDuringBulkUploads
        imageView.isHidden = isHiddenDuringBulkUploads
        if let number = number {
            circle.backgroundColor = selectionColor
            circle.layer.borderColor = selectionBorderColor.cgColor
            circle.layer.borderWidth = 1
            label.text = "\(number)"
        } else {
            circle.backgroundColor = unselectedColor
            circle.layer.borderColor = unselectedBorderColor.cgColor
            circle.layer.borderWidth = 1
            label.text = ""
        }
    }
}

class YPLibraryViewCell: UICollectionViewCell {
    
    var representedAssetIdentifier: String!
    let imageView = UIImageView()
    let durationLabel = UILabel()
    let selectionOverlay = UIView()
    let multipleSelectionIndicator = YPMultipleSelectionIndicator()
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        subviews(
            imageView,
            durationLabel,
            selectionOverlay,
            multipleSelectionIndicator
        )

        imageView.fillContainer()
        selectionOverlay.fillContainer()
        layout(
            durationLabel-5-|,
            5
        )
        
        layout(
            3,
            YPConfig.library.isBulkUploading ? |-3-multipleSelectionIndicator : multipleSelectionIndicator-3-|
        )
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        durationLabel.textColor = .white
        durationLabel.font = YPConfig.fonts.durationFont
        durationLabel.isHidden = true
        selectionOverlay.backgroundColor = .white
        selectionOverlay.alpha = 0
        backgroundColor = .ypSecondarySystemBackground
        setAccessibilityInfo()
    }

    override var isUserInteractionEnabled: Bool {
        didSet { refreshSelection() }
    }

    private func refreshSelection() {
        selectionOverlay.backgroundColor = isUserInteractionEnabled ? .white : .black
        if isUserInteractionEnabled {
            let showOverlay = isSelected || isHighlighted
            selectionOverlay.alpha = showOverlay ? 0.4 : 0
        } else {
            selectionOverlay.alpha = 0.4
        }
    }

    private func setAccessibilityInfo() {
        isAccessibilityElement = true
        self.accessibilityIdentifier = "YPLibraryViewCell"
        self.accessibilityLabel = "Library Image"
    }
}
