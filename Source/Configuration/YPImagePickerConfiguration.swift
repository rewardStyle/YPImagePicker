//
//  YPImagePickerConfiguration.swift
//  YPImagePicker
//
//  Created by Sacha DSO on 18/10/2017.
//  Copyright © 2016 Yummypets. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
import Photos

/// Typealias for code prettiness
public var YPConfig: YPImagePickerConfiguration { return YPImagePickerConfiguration.shared }

public struct YPImagePickerConfiguration {
    public static var shared: YPImagePickerConfiguration = YPImagePickerConfiguration()
    
    public static var widthOniPad: CGFloat = -1
    
    public static var screenWidth: CGFloat {
		var screenWidth: CGFloat = UIScreen.main.bounds.width
		if UIDevice.current.userInterfaceIdiom == .pad && YPImagePickerConfiguration.widthOniPad > 0 {
			screenWidth =  YPImagePickerConfiguration.widthOniPad
		}
		return screenWidth
    }

    /// If don't want to have logs from picker, set it to false.
    public var isDebugLogsEnabled: Bool = true

    public init() {}
    
    /// Library configuration
    public var library = YPConfigLibrary()
    
    /// Video configuration
    public var video = YPConfigVideo()
    
    /// Gallery configuration
    public var gallery = YPConfigSelectionsGallery()
    
    /// Use this property to modify the default wordings provided.
    public var wordings = YPWordings()
    
    /// Use this property to modify the default icons provided.
    public var icons = YPIcons()
    
    /// Use this property to modify the default colors provided.
    public var colors = YPColors()

    /// Use this property to modify the default fonts provided
    public var fonts = YPFonts()

    /// Scroll to change modes, defaults to true
    public var isScrollToChangeModesEnabled = true

    /// Set this to true if you want to force the camera output to be a squared image. Defaults to true
    public var onlySquareImagesFromCamera = true
    
    /// Enables selecting the front camera by default, useful for avatars. Defaults to false
    public var usesFrontCamera = false
    
    /// Adds a Filter step in the photo taking process.  Defaults to true
    public var showsPhotoFilters = true
    
    /// Adds a Video Trimmer step in the video taking process.  Defaults to true
    public var showsVideoTrimmer = true

    /// Enables you to opt out from saving new (or old but filtered) images to the
    /// user's photo library. Defaults to true.
    public var shouldSaveNewPicturesToAlbum = true
    
    /// Defines the name of the album when saving pictures in the user's photo library.
    /// In general that would be your App name. Defaults to "DefaultYPImagePickerAlbumName"
    public var albumName = "DefaultYPImagePickerAlbumName"

    /// Defines which screen is shown at launch. Video mode will only work if `showsVideo = true`.
    /// Default value is `.photo`
    public var startOnScreen: YPPickerScreen = .photo
    
    /// Defines which screens are shown at launch, and their order.
    /// Default value is `[.library, .photo]`
    public var screens: [YPPickerScreen] = [.library, .photo]

    /// Adds a Crop step in the photo taking process, after filters.  Defaults to .none
    public var showsCrop: YPCropType = .none
    
    /// Controls the visibility of a grid on crop stage. Default it false
    public var showsCropGridOverlay = false
    
    /// Ex: cappedTo:1024 will make sure images from the library or the camera will be
    /// resized to fit in a 1024x1024 box. Defaults to original image size.
    public var targetImageSize = YPImageSize.original
    
    /// Adds a Overlay View to the camera
    public var overlayView: UIView?

    /// Defines if the navigation bar cancel button should be hidden when showing the picker. Default is false
    public var hidesCancelButton = false
    
    /// Defines if the status bar should be hidden when showing the picker. Default is true
    public var hidesStatusBar = true
    
    /// Defines if the bottom bar should be hidden when showing the picker. Default is false.
    public var hidesBottomBar = false

    /// Defines if the title bar should show the button that allows switching between the library and albums. If this is set to false, the button will be shown between the asset view and the library view instead
    public var showsLibraryButtonInTitle = true

    /// Defines if the title bar should show the secondary button next to the library button that can be configured. Default is false.
    public var showsSecondaryLibraryButtonInTitle = false

    /// If showsLibraryButtonInTitle is false, this will be used as the title text instead
    public var pickerTitleOverride: String? = nil

    /// Defines the preferredStatusBarAppearance
    public var preferredStatusBarStyle = UIStatusBarStyle.default
    
    /// Defines the text colour to be shown when a bottom option is selected
    public var bottomMenuItemSelectedTextColour: UIColor = .ypLabel
    
    /// Defines the text colour to be shown when a bottom option is unselected
    public var bottomMenuItemUnSelectedTextColour: UIColor = .ypSecondaryLabel
    
    /// Defines the max camera zoom factor for camera. Disable camera zoom with 1. Default is 1.
    public var maxCameraZoomFactor: CGFloat = 1.0
    
    /// List of default filters which will be added on the filter screen
    public var filters: [YPFilter] = [
        YPFilter(name: "Normal", applier: nil),
        YPFilter(name: "Nashville", applier: YPFilter.nashvilleFilter),
        YPFilter(name: "Toaster", applier: YPFilter.toasterFilter),
        YPFilter(name: "1977", applier: YPFilter.apply1977Filter),
        YPFilter(name: "Clarendon", applier: YPFilter.clarendonFilter),
        YPFilter(name: "Chrome", coreImageFilterName: "CIPhotoEffectChrome"),
        YPFilter(name: "Fade", coreImageFilterName: "CIPhotoEffectFade"),
        YPFilter(name: "Instant", coreImageFilterName: "CIPhotoEffectInstant"),
        YPFilter(name: "Mono", coreImageFilterName: "CIPhotoEffectMono"),
        YPFilter(name: "Noir", coreImageFilterName: "CIPhotoEffectNoir"),
        YPFilter(name: "Process", coreImageFilterName: "CIPhotoEffectProcess"),
        YPFilter(name: "Tonal", coreImageFilterName: "CIPhotoEffectTonal"),
        YPFilter(name: "Transfer", coreImageFilterName: "CIPhotoEffectTransfer"),
        YPFilter(name: "Tone", coreImageFilterName: "CILinearToSRGBToneCurve"),
        YPFilter(name: "Linear", coreImageFilterName: "CISRGBToneCurveToLinear"),
        YPFilter(name: "Sepia", coreImageFilterName: "CISepiaTone"),
        YPFilter(name: "XRay", coreImageFilterName: "CIXRay")
        ]
    
    /// Migration
    
    @available(iOS, obsoleted: 3.0.0, renamed: "video.compression")
    public var videoCompression: String { AVAssetExportPresetHighestQuality }

    @available(iOS, obsoleted: 3.0.0, renamed: "video.fileType")
    public var videoExtension: AVFileType { .mov }

    @available(iOS, obsoleted: 3.0.0, renamed: "video.recordingTimeLimit")
    public var videoRecordingTimeLimit: TimeInterval { 60.0 }

    @available(iOS, obsoleted: 3.0.0, renamed: "video.libraryTimeLimit")
    public var videoFromLibraryTimeLimit: TimeInterval { 60.0 }

    @available(iOS, obsoleted: 3.0.0, renamed: "video.minimumTimeLimit")
    public var videoMinimumTimeLimit: TimeInterval { 3.0 }

    @available(iOS, obsoleted: 3.0.0, renamed: "video.trimmerMaxDuration")
    public var trimmerMaxDuration: Double { 60.0 }

    @available(iOS, obsoleted: 3.0.0, renamed: "video.trimmerMinDuration")
    public var trimmerMinDuration: Double { 3.0 }

    @available(iOS, obsoleted: 3.0.0, renamed: "library.onlySquare")
    public var onlySquareImagesFromLibrary: Bool { false }

    @available(iOS, obsoleted: 3.0.0, renamed: "library.onlySquare")
    public var onlySquareFromLibrary: Bool { false }

    @available(iOS, obsoleted: 3.0.0, renamed: "targetImageSize")
    public var libraryTargetImageSize: YPImageSize { .original }

    @available(iOS, obsoleted: 3.0.0, renamed: "library.mediaType")
    public var showsVideoInLibrary: Bool { false }

    @available(iOS, obsoleted: 3.0.0, renamed: "library.mediaType")
    public var libraryMediaType: YPlibraryMediaType { .photo }

    @available(iOS, obsoleted: 3.0.0, renamed: "library.maxNumberOfItems")
    public var maxNumberOfItems: Int { 1 }

}

/// Encapsulates library specific settings.
public struct YPConfigLibrary {
    
    public var options: PHFetchOptions?

    public var albumFetchOptions: PHFetchOptions?

    public var smartAlbumFetchOptions: PHFetchOptions?

    public var useAlbumSections = false

    public var smartAlbumsSectionTitle: String?

    public var userAlbumsSectionTitle: String?

    /// Set this to true if you want to force the library output to be a squared image. Defaults to false.
    public var onlySquare = false
    
    /// Sets the cropping style to square or not. Ignored if `onlySquare` is true. Defaults to true.
    public var isSquareByDefault = true
    
	/// Minimum width, to prevent selectiong too high images. Have sense if onlySquare is true and the image is portrait.
    public var minWidthForItem: CGFloat?
    
    public var minAspectRatio: CGFloat?
    
    public var maxAspectRatio: CGFloat?

    /// Pre-selects all of the smart album media when entering the media picker
    /// and renders the media in reverse order. This configuration option will
    /// override any fetch options supplied from `YPConfig.library.options` and
    /// will override the default fetch options which orders media by `creationDate`
    public var shouldPreselectRecentsAlbum: Bool = false

    /// List of aspect ratios allowed for videos (when selecting a single video)
    /// The gallery will auto-crop the media to the closest aspect ratio from this list (without letterboxing)
    public var allowedVideoAspectRatios: [CGFloat]?

    /// List of aspect ratios allowed for all media when multi-selecting
    /// The gallery will auto-crop the media to the closest aspect ratio from this list (without letterboxing)
    public var allowedMultiSelectionAspectRatios: [CGFloat]?

    /// List of "override" aspect ratios allowed for all media in single video selection mode
    /// These aspect ratios will not be used as the list of "allowed" aspect ratios but they are still "allowed"
    public var allowedVideoAspectRatioOverrides: [CGFloat]?

    /// List of "override" aspect ratios allowed for all media in multi-selection mode
    /// These aspect ratios will not be used as the list of "allowed" aspect ratios but they are still "allowed"
    public var allowedMultiSelectionAspectRatioOverrides: [CGFloat]?

    /// Choose what media types are available in the library. Defaults to `.photo`.
    /// If you define custom options PHFetchOptions var, than this will not work.
    public var mediaType = YPlibraryMediaType.photo

    /// Initial state of multiple selection button.
    public var defaultMultipleSelection = false

    /// Pre-selects the current item on setting multiple selection
    public var preSelectItemOnMultipleSelection = true

    /// Anything superior than 1 will enable the multiple selection feature.
    public var maxNumberOfItems = 1

    /// Show warning when user has selected `maxNumberOfItems` and multiple selection is enabled.
    public var showMaxNumberWarning = true

    /// Anything greater than 1 will desactivate live photo and video modes (library only) and
    /// force users to select at least the number of items defined.
    public var minNumberOfItems = 1

    /// Set the number of items per row in collection view. Defaults to 4.
    public var numberOfItemsInRow: Int = 4

    /// Set the spacing between items in collection view. Defaults to 1.0.
    public var spacingBetweenItems: CGFloat = 1.0

    /// Allow to skip the selections gallery when selecting the multiple media items. Defaults to false.
    public var skipSelectionsGallery = false
    
    /// Allow to preselected media items
    public var preselectedItems: [YPMediaItem]?
    
    /// Set the overlay type shown on top of the selected library item
    public var itemOverlayType: YPItemOverlayType = .grid

    /// Set this to true if you want to allow the library video picker to zoom / pan to crop videos
    public var allowZoomToCrop = true

    /// Allow selection of both photo and video from the photo gallery.
    public var allowPhotoAndVideoSelection : Bool = false

    /// A view you set here will be shown underneath the asset preview view in the library screen.
    /// The view will be automatically laid out to fill the screen horizontally, but it should determine its own height.
    public var assetPreviewFooterView: UIView?

    /// Set this value if you want to restrict the maximum height of the asset preview view
    /// If not set, the asset preview will be a square.
    public var assetPreviewMaxHeight: CGFloat?

    /// Customize UI for bulk uploads flow.
    public var isBulkUploading: Bool = false
}

/// Encapsulates video specific settings.
public struct YPConfigVideo {
    
    /** Choose the videoCompression. Defaults to AVAssetExportPresetHighestQuality
     - "AVAssetExportPresetLowQuality"
     - "AVAssetExportPreset640x480"
     - "AVAssetExportPresetMediumQuality"
     - "AVAssetExportPreset1920x1080"
     - "AVAssetExportPreset1280x720"
     - "AVAssetExportPresetHighestQuality"
     - "AVAssetExportPresetAppleM4A"
     - "AVAssetExportPreset3840x2160"
     - "AVAssetExportPreset960x540"
     - "AVAssetExportPresetPassthrough" // without any compression
     */
    public var compression: String = AVAssetExportPresetHighestQuality

    /// When `true` the video will always be processed using whatever whatever export preset is defined for `YPConfigVideo.compression. 
    /// The default value is `false`.`
    public var shouldAlwaysProcessVideo: Bool = false

    /// Choose the result video extension if you trim or compress a video. Defaults to mov.
    public var fileType: AVFileType = .mov
    
    /// Defines the time limit for recording videos.
    /// Default is 60 seconds.
    public var recordingTimeLimit: TimeInterval = 60.0
    
    /// Defines the size limit in bytes for recording videos.
    /// If this property is not nil, then the recording percentage line tracks buy this.
    /// In bytes. 100000000 is 100 MB.
    /// AVCaptureMovieFileOutput.maxRecordedFileSize.
    public var recordingSizeLimit: Int64?

    /// Minimum free space when recording videos.
    /// AVCaptureMovieFileOutput.minFreeDiskSpaceLimit.
    public var minFreeDiskSpaceLimit: Int64 = 1024 * 1024
    
    /// Defines the time limit for videos from the library.
    /// Defaults to 60 seconds.
    public var libraryTimeLimit: TimeInterval = 60.0
    
    /// Defines the minimum time for the video
    /// Defaults to 3 seconds.
    public var minimumTimeLimit: TimeInterval = 3.0
    
    /// The maximum duration allowed for the trimming. Change it before setting the asset, as the asset preview
    /// - Tag: trimmerMaxDuration
    public var trimmerMaxDuration: Double = 60.0
    
    /// The minimum duration allowed for the trimming.
    /// The handles won't pan further if the minimum duration is attained.
    public var trimmerMinDuration: Double = 3.0

    /// Defines if the trimmer will display the timestamp user interface.
    public var displayTrimmerWithTimeStamps: Bool = false

    /// Defines if the user skips the trimer stage,
    /// the video will be trimmed automatically to the maximum value of trimmerMaxDuration.
    /// This case occurs when the user already has a video selected and enables a
    /// multiselection to pick more than one type of media (video or image),
    /// so, the trimmer step becomes optional.
    /// - SeeAlso: [trimmerMaxDuration](x-source-tag://trimmerMaxDuration)
    public var automaticTrimToTrimmerMaxDuration: Bool = false

    /// Defines whether the coverThumbSelector automatically reloads a trimmed version of the video asset \
    /// whenever the trim selection changes
    public var coverSelectionTrimmed: Bool = false

    /// The maximum resolution allowed for outputted videos, calculated by multiplying the video's height and width.
    /// The video's pixel size will be automatically restricted to fit within this amount (keeping the aspect ratio).
    /// NOTE: Additionally, if this value is set, the resulting resolution values will be rounded down to the nearest even numbers.
    public var maxVideoResolution: Double?

    /// The maximum size of video thumbnail
    public var maxVideoThumbnailSize: CGSize?
}

/// Encapsulates gallery specific settings.
public struct YPConfigSelectionsGallery {
    /// Defines if the remove button should be hidden when showing the gallery. Default is true.
    public var hidesRemoveButton = true
}

public enum YPItemOverlayType {
    case none
    case grid
}

public enum YPlibraryMediaType {
    case photo
    case video
    case photoAndVideo
}
