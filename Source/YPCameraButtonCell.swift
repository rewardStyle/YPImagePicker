//
//  YPCameraButtonCell.swift
//  YPImagePicker
//
//  Created by Spencer Halverson on 10/28/25.
//  Copyright © 2025 Yummypets. All rights reserved.
//

import UIKit

final class YPCameraButtonCell: UICollectionViewCell {

    // MARK: - Subviews

    private let iconView = UIImageView()
    private let iconBackgroundView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.backgroundColor = .darkGray
        return view
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        forceDarkAppearance()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        forceDarkAppearance()
    }

    // MARK: - Setup

    private func setupView() {
        contentView.addSubview(iconBackgroundView)
        contentView.addSubview(iconView)
        contentView.backgroundColor = .black

        iconBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconBackgroundView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            iconBackgroundView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconBackgroundView.widthAnchor.constraint(equalToConstant: 32),
            iconBackgroundView.heightAnchor.constraint(equalToConstant: 32)
        ])

        iconView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalToConstant: 20)
        ])

        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = .white
        iconView.image = UIImage(systemName: "camera")
    }

    private func forceDarkAppearance() {
        contentView.overrideUserInterfaceStyle = .dark
    }
}
