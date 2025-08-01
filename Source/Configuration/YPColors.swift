//
//  YPColors.swift
//  YPImagePicker
//
//  Created by Nik Kov || nik-kov.com on 13.04.2018.
//  Copyright © 2018 Yummypets. All rights reserved.
//

import UIKit

public struct YPColors {
    
    // MARK: - Common
    
    /// The common cancel color which is used for cancel button in navigation bar.
    public var cancelButtonColor = UIColor.ypSystemBlue
    
    /// The common tint color which is used for done buttons in navigation bar, multiple items selection and so on.
    public var tintColor = UIColor.ypSystemBlue
    
    /// A color for navigation bar spinner.
    /// Default is nil, which is default iOS gray UIActivityIndicator.
    public var navigationBarActivityIndicatorColor: UIColor?
    
    /// A color for circle for unselected items in multiple selection
    /// Default is nil, which takes white.withAlphaComponent(0.3) color.
    public var multipleItemsUnselectedCircleColor: UIColor?

    /// A color for circle border for unselected items in multiple selection
    /// Default is nil, which takes white color.
    public var multipleItemsUnselectedCircleBorderColor: UIColor?

    /// A color for circle for selected items in multiple selection
    /// Default is nil, which takes tintColor.
    public var multipleItemsSelectedCircleColor: UIColor?

    /// A color for circle border for selected items in multiple selection
    /// Default is nil, which takes clear color.
    public var multipleItemsSelectedCircleBorderColor: UIColor?

    /// The background color of the bottom of photo and video screens.
    public var photoVideoScreenBackgroundColor: UIColor = .offWhiteOrBlack

    /// The background color of the library and space between collection view cells.
    public var libraryScreenBackgroundColor: UIColor = .offWhiteOrBlack

    /// The background color of safe area. For example under the menu items.
    public var safeAreaBackgroundColor: UIColor = .offWhiteOrBlack

    /// A color for background of the asset container. You can see it when bouncing the image.
    public var assetViewBackgroundColor: UIColor = .offWhiteOrBlack
    
    /// A color for background in filters.
    public var filterBackgroundColor: UIColor = .offWhiteOrBlack

    /// A color for background in selections gallery. When multiple items selected.
    public var selectionsBackgroundColor: UIColor = .offWhiteOrBlack

    /// A color for bottom buttons (photo, video, all photos).
    public var bottomMenuItemBackgroundColor: UIColor = .clear

    /// A color for for bottom buttons selected text.
    public var bottomMenuItemSelectedTextColor: UIColor = .ypLabel

    /// A color for for bottom buttons not selected text.
    public var bottomMenuItemUnselectedTextColor: UIColor = .ypSecondaryLabel

    /// The color of the crop overlay.
    public var cropOverlayColor: UIColor = .ypSystemBackground.withAlphaComponent(0.4)

    /// The default color of all navigation bars except album's.
    public var defaultNavigationBarColor: UIColor = .offWhiteOrBlack

    /// The color for album section header label (if album sections are on)
    public var albumSectionHeaderTextColor: UIColor?

    /// The color of the button that changes between library and albums _when_ showsLibraryButtonInTitle is false
    public var libraryScreenAlbumsButtonColor: UIColor = .ypLabel

    /// The color of the secondary library button.
    public var secondaryLibraryButtonTextColor: UIColor = .ypSecondaryLabel

    // MARK: - Trimmer
    
    /// The color of the main border of the view
    public var trimmerMainColor: UIColor = .ypLabel
    /// The color of the handles on the side of the view
    public var trimmerHandleColor: UIColor = .ypSystemBackground
    /// The color of the position indicator
    public var positionLineColor: UIColor = .ypSystemBackground
    /// The color of the trimmer time stamp
    public var trimmerTimeStampColor: UIColor = .ypSystemBackground
    /// The color of the large circle on the time bar
    public var trimmerTimeBarLargeCircle: UIColor = .ypSystemBackground
    /// The color of the small circle on the time bar
    public var trimmerTimeBarSmallCircle: UIColor = .ypSystemBackground
    /// The color of the trim view mask
    public var trimmerMaskColor: UIColor = .ypSystemBackground

    // MARK: - Cover selector
    
    /// The color of the cover selector border
    public var coverSelectorBorderColor: UIColor = .offWhiteOrBlack
    
    // MARK: - Progress bar
    
    /// The color for the progress bar when processing video or images. The all track color.
    public var progressBarTrackColor: UIColor = .ypSystemBackground
    /// The color of completed track for the progress bar
    public var progressBarCompletedColor: UIColor?

    // MARK: - Albums (unused)

    /// The color of the Album's NavigationBar background
    public var albumBarTintColor: UIColor = .ypSystemBackground
    /// The color of the Album's left and right items color
    public var albumTintColor: UIColor = .ypLabel
    /// The color of the Album's title color
    public var albumTitleColor: UIColor = .ypLabel
}
