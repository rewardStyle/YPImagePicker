//
//  PHFetchResult + IndexPath.swift
//  YPImagePicker
//
//  Created by Sacha DSO on 26/01/2018.
//  Copyright © 2018 Yummypets. All rights reserved.
//

import Foundation
import Photos

@inline(__always)
func ypAssetsAtIndexPaths(
    _ indexPaths: [IndexPath],
    in fetchResult: PHFetchResult<PHAsset>,
    includeCameraButton: Bool
) -> [PHAsset] {
    guard !indexPaths.isEmpty else { return [] }

    var assets: [PHAsset] = []
    assets.reserveCapacity(indexPaths.count)

    for ip in indexPaths {
        var assetIndex = ip.item

        // If camera button is included as index 0, skip it and offset
        if includeCameraButton {
            guard ip.item > 0 else { continue }
            assetIndex = ip.item - 1
        }

        guard assetIndex >= 0 && assetIndex < fetchResult.count else { continue }
        assets.append(fetchResult.object(at: assetIndex))
    }

    return assets
}
