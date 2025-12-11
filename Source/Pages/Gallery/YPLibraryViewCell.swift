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
            imageView.image = YPConfig.icons.checkIcon.withTintColor(YPConfig.colors.multipleSelectionIndicatorTextColor ?? .white, renderingMode: .alwaysOriginal)
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
            label.textColor = YPConfig.colors.multipleSelectionIndicatorTextColor ?? .white
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

        let indicatorPadding = YPConfig.gallery.multipleSelectionIndicatorPadding
        layout(
            indicatorPadding,
            multipleSelectionIndicator-indicatorPadding-|
        )
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        durationLabel.textColor = .white
        durationLabel.font = YPConfig.fonts.durationFont
        durationLabel.isHidden = true
        selectionOverlay.backgroundColor = YPConfig.colors.currentSelectedItemOverlayColor ?? .white.withAlphaComponent(0.4)
        selectionOverlay.isHidden = true
        backgroundColor = .ypSecondarySystemBackground
        setAccessibilityInfo()
    }

    func setSelection(number: Int?) {
        multipleSelectionIndicator.set(number: number)
        if number == nil {
            selectionOverlay.isHidden = true
        } else {
            if !isUserInteractionEnabled {
                selectionOverlay.backgroundColor = .black.withAlphaComponent(0.4)
            } else if isSelected || isHighlighted {
                selectionOverlay.backgroundColor = YPConfig.colors.currentSelectedItemOverlayColor ?? .white.withAlphaComponent(0.4)
            } else {
                selectionOverlay.backgroundColor = YPConfig.colors.multipleSelectedItemsOverlayColor
            }
            selectionOverlay.isHidden = false
        }
    }

    private func setAccessibilityInfo() {
        isAccessibilityElement = true
        self.accessibilityIdentifier = "YPLibraryViewCell"
        self.accessibilityLabel = "Library Image"
    }
}
