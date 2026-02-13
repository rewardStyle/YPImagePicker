//
//  YPLibrary+LibraryChange.swift
//  YPImagePicker
//
//  Created by Sacha DSO on 26/01/2018.
//  Copyright © 2018 Yummypets. All rights reserved.
//

import UIKit
import Photos

extension YPLibraryVC: PHPhotoLibraryChangeObserver {
    func registerForLibraryChanges() {
        PHPhotoLibrary.shared().register(self)
    }
    
    public func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let fetchResult = self.mediaManager.fetchResult,
              let collectionChanges = changeInstance.changeDetails(for: fetchResult) else {
            ypLog("Some problems there.")
            return
        }

        DispatchQueue.main.async {
            let collectionView = self.v.collectionView

            // Guard against updates when the view isn't in the hierarchy
            guard collectionView.window != nil else {
                self.mediaManager.fetchResult = collectionChanges.fetchResultAfterChanges
                collectionView.reloadData()
                self.updateAssetSelection()
                self.mediaManager.resetCachedAssets()
                return
            }

            if !collectionChanges.hasIncrementalChanges || collectionChanges.hasMoves {
                self.mediaManager.fetchResult = collectionChanges.fetchResultAfterChanges
                collectionView.reloadData()
            } else {
                // Validate that the current data source count matches what PHChange expects
                // before attempting incremental updates
                let expectedOldCount = collectionChanges.fetchResultBeforeChanges.count
                let cameraButtonOffset = YPConfig.library.showGalleryCameraButton ? 1 : 0
                let actualOldCount = collectionView.numberOfItems(inSection: 0) - cameraButtonOffset

                guard expectedOldCount == actualOldCount else {
                    ypLog("Data source count mismatch (expected: \(expectedOldCount), actual: \(actualOldCount)). Falling back to reloadData.")
                    self.mediaManager.fetchResult = collectionChanges.fetchResultAfterChanges
                    collectionView.reloadData()
                    self.updateAssetSelection()
                    self.mediaManager.resetCachedAssets()
                    return
                }

                collectionView.performBatchUpdates({
                    // Update fetchResult inside performBatchUpdates so that
                    // UICollectionView sees the old count at the start and the
                    // new count at the end, matching the applied deletes/inserts.
                    self.mediaManager.fetchResult = collectionChanges.fetchResultAfterChanges

                    if let removedIndexes = collectionChanges.removedIndexes,
                       removedIndexes.count != 0 {
                        collectionView.deleteItems(at: removedIndexes.aapl_indexPathsFromIndexesWithSection(0, offset: cameraButtonOffset))
                    }

                    if let insertedIndexes = collectionChanges.insertedIndexes, insertedIndexes.count != 0 {
                        collectionView.insertItems(at: insertedIndexes.aapl_indexPathsFromIndexesWithSection(0, offset: cameraButtonOffset))
                    }
                }, completion: { finished in
                    guard finished else { return }
                    guard let changedIndexes = collectionChanges.changedIndexes,
                          changedIndexes.count != 0 else {
                        return
                    }

                    collectionView.reloadItems(at: changedIndexes.aapl_indexPathsFromIndexesWithSection(0, offset: cameraButtonOffset))
                })
            }

            self.updateAssetSelection()
            self.mediaManager.resetCachedAssets()
        }
    }

    fileprivate func updateAssetSelection() {
        // If no items selected in assetView, but there are already photos
        // after photoLibraryDidChange, than select first item in library.
        // It can be when user add photos from limited permission.

        let updatedItems = selectedItems.filter { selection in
            if let asset = PHAsset.fetchAssets(
                withLocalIdentifiers: [selection.assetIdentifier],
                options: PHFetchOptions()
            ).firstObject {
                return true
            }

            return false
        }

        if mediaManager.hasResultItems,
           updatedItems.isEmpty,
           let newAsset = self.mediaManager.getAsset(at: 0) {

            if updatedItems.count != selectedItems.count {
                selectedItems = updatedItems
                refreshMediaRequest()
            } else {
                changeAsset(newAsset)
            }
        }

        // If we had selected items before, we might need to update the currently selected index
        if mediaManager.hasResultItems, !updatedItems.isEmpty, !isMultipleSelectionEnabled {
            // Find the selected item that used to be at currently selected index and fix the index if it changed
            if currentlySelectedIndex >= 0 && currentlySelectedIndex < selectedItems.count {
                let currentlySelectedAssetIdentifier = selectedItems[currentlySelectedIndex].assetIdentifier
                if let currentlySelectedElement = mediaManager.getAsset(with: currentlySelectedAssetIdentifier),
                   let newIndex = mediaManager.fetchResult?.index(of: currentlySelectedElement),
                   newIndex != currentlySelectedIndex {
                    currentlySelectedIndex = newIndex
                }
            }
        }


        // If user decided to forbid all photos with limited permission
        // while using the lib we need to remove asset from assets view.
        if selectedItems.isEmpty == false,
           self.mediaManager.hasResultItems == false {
            self.v.assetZoomableView.clearAsset()
            self.selectedItems.removeAll()
            self.delegate?.libraryViewFinishedLoading()
        }
    }
}
