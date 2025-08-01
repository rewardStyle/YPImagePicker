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
            self.mediaManager.fetchResult = collectionChanges.fetchResultAfterChanges
            if !collectionChanges.hasIncrementalChanges || collectionChanges.hasMoves {
                collectionView.reloadData()
            } else {
                collectionView.performBatchUpdates({
                    if let removedIndexes = collectionChanges.removedIndexes,
                       removedIndexes.count != 0 {
                        collectionView.deleteItems(at: removedIndexes.aapl_indexPathsFromIndexesWithSection(0))
                    }

                    if let insertedIndexes = collectionChanges.insertedIndexes, insertedIndexes.count != 0 {
                        collectionView.insertItems(at: insertedIndexes.aapl_indexPathsFromIndexesWithSection(0))
                    }
                }, completion: { finished in
                    guard finished else { return }
                    guard let changedIndexes = collectionChanges.changedIndexes,
                          changedIndexes.count != 0 else {
                        ypLog("No changes detected")
                        collectionView.reloadData() // If we failed to detect changes, we'll reload everything just in case
                        return
                    }

                    collectionView.reloadItems(at: changedIndexes.aapl_indexPathsFromIndexesWithSection(0))
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
