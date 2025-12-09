//
//  YPLibraryViewDelegate.swift
//  YPImagePicker
//
//  Created by Sacha DSO on 26/01/2018.
//  Copyright © 2016 Yummypets. All rights reserved.
//

import Foundation
import UIKit

@objc
public protocol YPLibraryViewDelegate: AnyObject {
    func libraryViewDidTapNext()
    func libraryViewStartedLoadingImage()
    func libraryViewFinishedLoading()
    func libraryViewDidToggleMultipleSelection(enabled: Bool)
    func libraryViewShouldAddToSelection(indexPath: IndexPath, numSelections: Int) -> Bool
    func libraryViewHaveNoItems()
    func libraryViewDidTapAlbum()
    func libraryViewDidTapSecondaryButton()
    func libraryViewDidTapCameraButtonCell()
    func registerViewForCameraButtonCell(_ collectionView: UICollectionView)
    func viewForCameraButtonCell(_ collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell
    func libraryViewWillBeginScrolling()
    func libraryViewDidScroll()
}
