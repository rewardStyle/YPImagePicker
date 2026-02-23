//
//  IndexSet+IndexPath.swift
//  YPImagePicker
//
//  Created by Sacha DSO on 26/01/2018.
//  Copyright © 2018 Yummypets. All rights reserved.
//

import Foundation

internal extension IndexSet {
    func aapl_indexPathsFromIndexesWithSection(_ section: Int, offset: Int = 0) -> [IndexPath] {
        var indexPaths: [IndexPath] = []
        indexPaths.reserveCapacity(count)
        (self as NSIndexSet).enumerate({idx, _ in
            indexPaths.append(IndexPath(item: idx + offset, section: section))
        })
        return indexPaths
    }
}
