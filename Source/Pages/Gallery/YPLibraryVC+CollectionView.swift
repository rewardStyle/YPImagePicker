//
//  YPLibraryVC+CollectionView.swift
//  YPImagePicker
//
//  Created by Sacha DSO on 26/01/2018.
//  Copyright © 2018 Yummypets. All rights reserved.
//

import UIKit

extension YPLibraryVC {
    var isLimitExceeded: Bool { return selectedItems.count >= YPConfig.library.maxNumberOfItems }

    /// Map a visible indexPath to an asset index in mediaManager.fetchResult (nil == camera cell at item 0)
    private func assetIndex(for indexPath: IndexPath) -> Int? {
        if showGalleryCameraButton {
            return indexPath.item == 0 ? nil : (indexPath.item - 1)
        } else {
            return indexPath.item
        }
    }

    /// Map an asset index back to its visible indexPath in the collection view
    private func indexPath(forAssetIndex assetIndex: Int) -> IndexPath {
        if showGalleryCameraButton {
            return IndexPath(item: assetIndex + 1, section: 0)
        } else {
            return IndexPath(item: assetIndex, section: 0)
        }
    }

    private var showGalleryCameraButton: Bool {
        YPConfig.library.showGalleryCameraButton
    }

    public func setupCollectionView() {
        v.collectionView.dataSource = self
        v.collectionView.delegate = self
        v.collectionView.register(YPLibraryViewCell.self, forCellWithReuseIdentifier: "YPLibraryViewCell")
        if showGalleryCameraButton {
            delegate?.registerViewForCameraButtonCell(v.collectionView)
        }
        // Long press on cell to enable multiple selection
        let longPressGR = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(longPressGR:)))
        longPressGR.minimumPressDuration = 0.5
        v.collectionView.addGestureRecognizer(longPressGR)
    }
    
    /// When tapping on the cell with long press, clear all previously selected cells.
    @objc func handleLongPress(longPressGR: UILongPressGestureRecognizer) {
        if isMultipleSelectionEnabled || isProcessing || YPConfig.library.maxNumberOfItems <= 1 {
            return
        }
        
        if longPressGR.state == .began {
            let point = longPressGR.location(in: v.collectionView)
            guard let indexPath = v.collectionView.indexPathForItem(at: point) else {
                return
            }
            startMultipleSelection(at: indexPath)
        }
    }
    
    func startMultipleSelection(at indexPath: IndexPath) {
        guard let assetIndex = assetIndex(for: indexPath) else { return }

        currentlySelectedIndex = assetIndex
        selectedItems.removeAll()
        toggleMultipleSelection()
        
        // Update preview.
        changeAsset(mediaManager.getAsset(at: assetIndex))

        // Bring preview down and keep selected cell visible.
        panGestureHelper.resetToOriginalState()
        if !panGestureHelper.isImageShown {
            v.collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
        }
        v.refreshImageCurtainAlpha()
    }
    
    // MARK: - Library collection view cell managing
    
    /// Removes cell from selection
    func deselect(assetIndex: Int) {
        if let positionIndex = selectedItems.firstIndex(where: {
            $0.assetIdentifier == mediaManager.getAsset(at: assetIndex)?.localIdentifier
        }) {
            selectedItems.remove(at: positionIndex)

            // Refresh the numbers
            let selectedIndexPaths = selectedItems.map { indexPath(forAssetIndex: $0.index) }

            // Replace the current selected image with the previously selected one
            if let last = selectedItems.last {
                currentlySelectedIndex = last.index
                let asset = mediaManager.getAsset(with: last.assetIdentifier)
                changeAsset(asset)
            }
            v.collectionView.reloadItems(at: selectedIndexPaths)
            checkLimit()
            updateBulkUploadRemoveAllButton()
        }
    }
    
    /// Adds cell to selection
    func addToSelection(assetIndex: Int) {
        let visibleIndexPath = indexPath(forAssetIndex: assetIndex)

        if !(delegate?.libraryViewShouldAddToSelection(indexPath: visibleIndexPath,
                                                       numSelections: selectedItems.count) ?? true) {
            return
        }
        guard let asset = mediaManager.getAsset(at: assetIndex) else {
            ypLog("No asset to add to selection.")
            return
        }

        let newSelection = YPLibrarySelection(index: assetIndex, assetIdentifier: asset.localIdentifier)
        selectedItems.append(newSelection)
        changeAsset(mediaManager.getAsset(at: assetIndex))
        checkLimit()
        updateBulkUploadRemoveAllButton()
    }

    func updateBulkUploadRemoveAllButton() {
        guard YPConfig.library.isBulkUploading else {
            return
        }
        v.bulkUploadRemoveAllButton.isHidden = selectedItems.isEmpty
        v.bulkUploadRemoveAllButton.setTitle("\(selectedItems.count)", for: .normal)
    }

    func isInSelectionPool(assetIndex: Int) -> Bool {
        return selectedItems.contains(where: {
            $0.assetIdentifier == mediaManager.getAsset(at: assetIndex)?.localIdentifier
        })
    }
    
    /// Checks if there can be selected more items. If no - present warning.
    func checkLimit() {
        guard YPConfig.library.showMaxNumberWarning else { return }
        v.maxNumberWarningView.isHidden = !isLimitExceeded || isMultipleSelectionEnabled == false
    }
}

extension YPLibraryVC: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let resultCount = mediaManager.fetchResult?.count ?? 0
        return showGalleryCameraButton ? resultCount + 1 : resultCount
    }
}

extension YPLibraryVC: UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView,
                               cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if showGalleryCameraButton && indexPath.item == 0, let delegate {
            return delegate.viewForCameraButtonCell(collectionView, indexPath: indexPath)
        }

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "YPLibraryViewCell", for: indexPath) as? YPLibraryViewCell else {
            fatalError("unexpected cell in collection view")
        }
        guard let assetIndex = assetIndex(for: indexPath),
              let asset = mediaManager.getAsset(at: assetIndex) else {
            return cell
        }

        cell.representedAssetIdentifier = asset.localIdentifier
        cell.multipleSelectionIndicator.selectionColor =
            YPConfig.colors.multipleItemsSelectedCircleColor ?? YPConfig.colors.tintColor
        cell.multipleSelectionIndicator.selectionBorderColor =
            YPConfig.colors.multipleItemsSelectedCircleBorderColor ?? .clear
        cell.multipleSelectionIndicator.unselectedColor =
            YPConfig.colors.multipleItemsUnselectedCircleColor ?? .white.withAlphaComponent(0.3)
        cell.multipleSelectionIndicator.unselectedBorderColor =
            YPConfig.colors.multipleItemsUnselectedCircleBorderColor ?? .white
        mediaManager.imageManager?.requestImage(for: asset,
                                   targetSize: v.cellSize(),
                                   contentMode: .aspectFill,
                                   options: nil) { image, _ in
                                    // The cell may have been recycled when the time this gets called
                                    // set image only if it's still showing the same asset.
                                    if cell.representedAssetIdentifier == asset.localIdentifier && image != nil {
                                        cell.imageView.image = image
                                    }
        }
        
        let isVideo = (asset.mediaType == .video)
        cell.durationLabel.isHidden = !isVideo
        cell.durationLabel.text = isVideo ? YPHelper.formattedStrigFrom(asset.duration) : ""

        cell.isSelected = !disableAutomaticCellSelection && currentlySelectedIndex == assetIndex && selectedItems.contains(where: { $0.assetIdentifier == asset.localIdentifier })

        if !YPImagePickerConfiguration.shared.library.allowPhotoAndVideoSelection {
            cell.multipleSelectionIndicator.isHidden = !isMultipleSelectionEnabled || (isMultipleSelectionEnabled && isVideo)
            cell.isUserInteractionEnabled = !(isMultipleSelectionEnabled && isVideo)
        } else {
            cell.multipleSelectionIndicator.isHidden = !isMultipleSelectionEnabled
            cell.isUserInteractionEnabled = true
        }

        // Set correct selection number
        if let index = selectedItems.firstIndex(where: { $0.assetIdentifier == asset.localIdentifier }) {
            let currentSelection = selectedItems[index]
            if currentSelection.index < 0 {
                selectedItems[index] = YPLibrarySelection(index: assetIndex,
                                                      cropRect: currentSelection.cropRect,
                                                      scrollViewContentOffset: currentSelection.scrollViewContentOffset,
                                                      scrollViewZoomScale: currentSelection.scrollViewZoomScale,
                                                      assetIdentifier: currentSelection.assetIdentifier)
            }
            cell.setSelection(number: index + 1) // start at 1, not 0
        } else {
            cell.setSelection(number: nil)
        }

        // Prevent weird animation where thumbnail fills cell on first scrolls.
        UIView.performWithoutAnimation {
            cell.layoutIfNeeded()
        }
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if showGalleryCameraButton && indexPath.item == 0 {
            delegate?.libraryViewDidTapCameraButtonCell()
            return
        }

        guard let tappedAssetIndex = assetIndex(for: indexPath) else { return }

        let previouslySelectedAssetIndex = currentlySelectedIndex
        let previouslySelectedIndexPath = self.indexPath(forAssetIndex: previouslySelectedAssetIndex)
        currentlySelectedIndex = tappedAssetIndex
        let previouslySelectedItemIdentifier = selectedItems.first(where: { $0.index == currentlySelectedIndex })?.assetIdentifier

        var shouldChangeAsset = true
        panGestureHelper.resetToOriginalState()
        
        // Only scroll cell to top if preview is hidden.
        if !panGestureHelper.isImageShown {
            collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
        }
        v.refreshImageCurtainAlpha()
            
        if isMultipleSelectionEnabled {
            let cellIsInTheSelectionPool = isInSelectionPool(assetIndex: tappedAssetIndex)
            let cellIsCurrentlySelected = previouslySelectedAssetIndex == currentlySelectedIndex
            if cellIsInTheSelectionPool {
                if cellIsCurrentlySelected && !disableAutomaticCellSelection {
                    shouldChangeAsset = false
                    deselect(assetIndex: tappedAssetIndex)
                }
            } else if isLimitExceeded == false {
                shouldChangeAsset = false
                addToSelection(assetIndex: tappedAssetIndex)
            }
            if (cellIsCurrentlySelected && !cellIsInTheSelectionPool) || !cellIsCurrentlySelected || disableAutomaticCellSelection {
                disableAutomaticCellSelection = false
                collectionView.cellForItem(at: indexPath)?.isSelected = true
            }

            collectionView.reloadItems(at: [indexPath, previouslySelectedIndexPath])
        } else if previouslySelectedIndexPath != indexPath {
            selectedItems.removeAll()
            addToSelection(assetIndex: tappedAssetIndex)
            shouldChangeAsset = false

            // Force deseletion of previously selected cell.
            // In the case where the previous cell was loaded from iCloud, a new image was fetched
            // which triggered photoLibraryDidChange() and reloadItems() which breaks selection.
            //
            if let previousCell = collectionView.cellForItem(at: previouslySelectedIndexPath) as? YPLibraryViewCell {
                previousCell.isSelected = false
            }
            collectionView.reloadItems(at: [indexPath, previouslySelectedIndexPath])
        } else if previouslySelectedIndexPath == indexPath, let currentItemIdentifier = mediaManager.getAsset(at: tappedAssetIndex)?.localIdentifier, currentItemIdentifier != previouslySelectedItemIdentifier {
            // If we clicked on the cell index that was already selected, but the identifier is different, let's re-select the cell
            selectedItems.removeAll()
            addToSelection(assetIndex: tappedAssetIndex)
            shouldChangeAsset = true
            collectionView.reloadItems(at: [indexPath])
        }
        if shouldChangeAsset {
            changeAsset(mediaManager.getAsset(at: tappedAssetIndex))
        }
        disableAutomaticCellSelection = false
    }
    
    public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return isProcessing == false
    }
    
    public func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        return isProcessing == false
    }
}

extension YPLibraryVC: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        let margins = YPConfig.library.spacingBetweenItems * CGFloat(YPConfig.library.numberOfItemsInRow - 1)
        let width = (collectionView.frame.width - margins) / CGFloat(YPConfig.library.numberOfItemsInRow)
        return CGSize(width: width, height: width)
    }

    public func collectionView(_ collectionView: UICollectionView,
							   layout collectionViewLayout: UICollectionViewLayout,
							   minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return YPConfig.library.spacingBetweenItems
    }

    public func collectionView(_ collectionView: UICollectionView,
							   layout collectionViewLayout: UICollectionViewLayout,
							   minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return YPConfig.library.spacingBetweenItems
    }
}
