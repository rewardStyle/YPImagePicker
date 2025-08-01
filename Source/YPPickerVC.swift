//
//  YYPPickerVC.swift
//  YPPickerVC
//
//  Created by Sacha Durand Saint Omer on 25/10/16.
//  Copyright © 2016 Yummypets. All rights reserved.
//

import UIKit
import Stevia
import Photos

protocol YPPickerVCDelegate: AnyObject {
    func libraryHasNoItems()
    func shouldAddToSelection(indexPath: IndexPath, numSelections: Int) -> Bool
}

open class YPPickerVC: YPBottomPager, YPBottomPagerDelegate {
    
    let albumsManager = YPAlbumsManager()
    var shouldHideStatusBar = false
    var initialStatusBarHidden = false
    weak var pickerVCDelegate: YPPickerVCDelegate?
    
    override open var prefersStatusBarHidden: Bool {
        return (shouldHideStatusBar || initialStatusBarHidden) && YPConfig.hidesStatusBar
    }
    
    /// Private callbacks to YPImagePicker
    public var didTapNext:(() -> Void)?
    public var didClose:(() -> Void)?
    public var didSelectItems: (([YPMediaItem]) -> Void)?
    public var didTapMultipleSelection: ((Bool) -> Void)?
    public var didTapSecondaryLibraryButton: (() -> Void)?
    public var viewDidAppear: ((AnyObject) -> Void)?
    
    enum Mode {
        case library
        case camera
        case video
    }
    
    public var libraryVC: YPLibraryVC?
    public var cameraVC: YPCameraVC?
    public var videoVC: YPVideoCaptureVC?
    
    var mode = Mode.camera
    
    var capturedImage: UIImage?
    
    open override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = YPConfig.colors.safeAreaBackgroundColor
        
        delegate = self
        
        // Force Library only when using `minNumberOfItems`.
        if YPConfig.library.minNumberOfItems > 1 {
            YPImagePickerConfiguration.shared.screens = [.library]
        }
        
        // Library
        if YPConfig.screens.contains(.library) {
            libraryVC = YPLibraryVC()
            libraryVC?.delegate = self
        }
        
        // Camera
        if YPConfig.screens.contains(.photo) {
            cameraVC = YPCameraVC()
            cameraVC?.didCapturePhoto = { [weak self] img in
                self?.didSelectItems?([YPMediaItem.photo(p: YPMediaPhoto(image: img,
                                                                         fromCamera: true))])
            }
        }
        
        // Video
        if YPConfig.screens.contains(.video) {
            videoVC = YPVideoCaptureVC()
            videoVC?.didCaptureVideo = { [weak self] videoURL in
                self?.didSelectItems?([YPMediaItem
                                        .video(v: YPMediaVideo(thumbnail: thumbnailFromVideoPath(videoURL),
                                                               videoURL: videoURL,
                                                               fromCamera: true))])
            }
        }
        
        // Show screens
        var vcs = [UIViewController]()
        for screen in YPConfig.screens {
            switch screen {
            case .library:
                if let libraryVC = libraryVC {
                    vcs.append(libraryVC)
                }
            case .photo:
                if let cameraVC = cameraVC {
                    vcs.append(cameraVC)
                }
            case .video:
                if let videoVC = videoVC {
                    vcs.append(videoVC)
                }
            }
        }
        controllers = vcs
        
        // Select good mode
        if YPConfig.screens.contains(YPConfig.startOnScreen) {
            switch YPConfig.startOnScreen {
            case .library:
                mode = .library
            case .photo:
                mode = .camera
            case .video:
                mode = .video
            }
        }
        
        // Select good screen
        if let index = YPConfig.screens.firstIndex(of: YPConfig.startOnScreen) {
            startOnPage(index)
        }
        
        YPHelper.changeBackButtonIcon(self)
        YPHelper.changeBackButtonTitle(self)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraVC?.v.shotButton.isEnabled = true
        
        updateMode(with: currentController)
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        shouldHideStatusBar = true
        initialStatusBarHidden = true
        UIView.animate(withDuration: 0.3) {
            self.setNeedsStatusBarAppearanceUpdate()
        }

        if let button = libraryVC?.v.multipleSelectionButton {
            viewDidAppear?(button)
        }
    }

    internal func pagerScrollViewDidScroll(_ scrollView: UIScrollView) { }
    
    func modeFor(vc: UIViewController) -> Mode {
        switch vc {
        case is YPLibraryVC:
            return .library
        case is YPCameraVC:
            return .camera
        case is YPVideoCaptureVC:
            return .video
        default:
            return .camera
        }
    }
    
    func pagerDidSelectController(_ vc: UIViewController) {
        updateMode(with: vc)
    }
    
    func updateMode(with vc: UIViewController) {
        stopCurrentCamera()
        
        // Set new mode
        mode = modeFor(vc: vc)
        
        // Re-trigger permission check
        if let vc = vc as? YPLibraryVC {
            vc.doAfterLibraryPermissionCheck { [weak vc] in
                vc?.initialize()
            }
        } else if let cameraVC = vc as? YPCameraVC {
            cameraVC.start()
        } else if let videoVC = vc as? YPVideoCaptureVC {
            videoVC.start()
        }

        updateUI()
    }
    
    func stopCurrentCamera() {
        switch mode {
        case .library:
            libraryVC?.pausePlayer()
        case .camera:
            cameraVC?.stopCamera()
        case .video:
            videoVC?.stopCamera()
        }
    }

    public func pausePlayer() {
        libraryVC?.pausePlayer()
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        shouldHideStatusBar = false
    }
    
    deinit {
        stopAll()
        ypLog("YPPickerVC deinited ✅")
    }
    
    @objc
    func navBarTapped() {
        guard !(libraryVC?.isProcessing ?? false) else {
            return
        }
        
        let vc = YPAlbumVC(albumsManager: albumsManager)
        let navVC = UINavigationController(rootViewController: vc)
        navVC.navigationBar.tintColor = .ypLabel
        
        vc.didSelectAlbum = { [weak self] album in
            self?.libraryVC?.setAlbum(album)
            if YPConfig.showsLibraryButtonInTitle {
                self?.setTitleViewWithTitle(aTitle: album.title)
            }
            navVC.dismiss(animated: true, completion: nil)
        }
        present(navVC, animated: true, completion: nil)
    }
    
    func setTitleViewWithTitle(aTitle: String) {
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 200, height: 40)
        
        let label = UILabel()
        label.text = aTitle
        // Use YPConfig font
        label.font = YPConfig.fonts.pickerTitleFont

        // Use custom textColor if set by user.
        if let navBarTitleColor = UINavigationBar.appearance().titleTextAttributes?[.foregroundColor] as? UIColor {
            label.textColor = navBarTitleColor
        }
        
        if YPConfig.library.options != nil {
            titleView.subviews(
                label
            )
            |-(>=8)-label.centerHorizontally()-(>=8)-|
            align(horizontally: label)
        } else {
            let arrow = UIImageView()
            arrow.image = YPConfig.icons.arrowDownIcon
            arrow.image = arrow.image?.withRenderingMode(.alwaysTemplate)
            arrow.tintColor = .ypLabel
            
            let attributes = UINavigationBar.appearance().titleTextAttributes
            if let attributes = attributes, let foregroundColor = attributes[.foregroundColor] as? UIColor {
                arrow.image = arrow.image?.withRenderingMode(.alwaysTemplate)
                arrow.tintColor = foregroundColor
            }
            
            let button = UIButton()
            button.addTarget(self, action: #selector(navBarTapped), for: .touchUpInside)
            button.setBackgroundColor(UIColor.white.withAlphaComponent(0.5), forState: .highlighted)
            
            titleView.subviews(
                label,
                arrow,
                button
            )
            button.fillContainer()
            |-(>=8)-label.centerHorizontally()-arrow-(>=8)-|
            align(horizontally: label-arrow)
        }
        
        label.firstBaselineAnchor.constraint(equalTo: titleView.bottomAnchor, constant: -14).isActive = true
        
        titleView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        navigationItem.titleView = titleView
    }

    @objc
    open func updateUI() {
        if !YPConfig.hidesCancelButton {
            // Update Nav Bar state.
            if let cancelButtonIcon = YPConfig.icons.cancelButtonIcon {
                navigationItem.leftBarButtonItem = UIBarButtonItem(image: cancelButtonIcon,
                                                                   style: .plain,
                                                                   target: self,
                                                                   action: #selector(close))
            } else {
                navigationItem.leftBarButtonItem = UIBarButtonItem(title: YPConfig.wordings.cancel,
                                                                   style: .plain,
                                                                   target: self,
                                                                   action: #selector(close))
            }
            navigationItem.leftBarButtonItem?.setTitleTextAttributes([.foregroundColor : YPConfig.colors.cancelButtonColor], for: .normal)
        }
        switch mode {
        case .library:
            if YPConfig.showsLibraryButtonInTitle {
                setTitleViewWithTitle(aTitle: libraryVC?.title ?? "")
            }
            else if YPConfig.pickerTitleOverride != nil {
                navigationItem.title = YPConfig.pickerTitleOverride
            }

            navigationItem.rightBarButtonItem = UIBarButtonItem(title: YPConfig.wordings.next,
                                                                style: .done,
                                                                target: self,
                                                                action: #selector(done))
            navigationItem.rightBarButtonItem?.tintColor = YPConfig.colors.tintColor

            // Disable Next Button until minNumberOfItems is reached.
            navigationItem.rightBarButtonItem?.isEnabled =
                libraryVC!.selectedItems.count >= YPConfig.library.minNumberOfItems

        case .camera:
            navigationItem.titleView = nil
            title = cameraVC?.title
            navigationItem.rightBarButtonItem = nil
        case .video:
            navigationItem.titleView = nil
            title = videoVC?.title
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    @objc
    func close() {
        // Cancelling exporting of all videos
        if let libraryVC = libraryVC {
            libraryVC.mediaManager.forceCancelExporting()
        }
        self.didClose?()
    }
    
    // When pressing "Next"
    @objc
    open func done() {
        guard let libraryVC = libraryVC else { ypLog("YPLibraryVC deallocated"); return }
        if libraryVC.isAnimating {
            self.navigationItem.rightBarButtonItem = YPLoaders.defaultLoader
            retryDoneUntilAnimatingStops(retryCount: 0)
            return
        }
        didTapNext?()
        
        if mode == .library {
            libraryVC.selectedMedia(photoCallback: { photo in
                self.didSelectItems?([YPMediaItem.photo(p: photo)])
            }, videoCallback: { video in
                self.didSelectItems?([YPMediaItem
                                        .video(v: video)])
            }, multipleItemsCallback: { items in
                self.didSelectItems?(items)
            })
        }
    }

    let maxRetryCount = 6
    func retryDoneUntilAnimatingStops(retryCount: Int = 0) {
        guard let libraryVC = libraryVC else { ypLog("YPLibraryVC deallocated"); return }
        if libraryVC.isAnimating, retryCount < maxRetryCount {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self ] in
                self?.retryDoneUntilAnimatingStops(retryCount: retryCount + 1)
            }
        } else {
            done()
        }
    }

    func stopAll() {
        libraryVC?.v.assetZoomableView.videoView.deallocate()
        videoVC?.stopCamera()
        cameraVC?.stopCamera()
    }
}

extension YPPickerVC: YPLibraryViewDelegate {
    
    public func libraryViewDidTapNext() {
        libraryVC?.isProcessing = true
        DispatchQueue.main.async {
            self.v.scrollView.isScrollEnabled = false
            self.libraryVC?.v.fadeInLoader()
            self.navigationItem.rightBarButtonItem = YPLoaders.defaultLoader
        }
    }
    
    public func libraryViewStartedLoadingImage() {
        // TODO remove to enable changing selection while loading but needs cancelling previous image requests.
        libraryVC?.isProcessing = true
        DispatchQueue.main.async {
            self.libraryVC?.v.fadeInLoader()
        }
    }
    
    public func libraryViewFinishedLoading() {
        libraryVC?.isProcessing = false
        DispatchQueue.main.async {
            self.v.scrollView.isScrollEnabled = YPConfig.isScrollToChangeModesEnabled
            self.libraryVC?.v.hideLoader()
            self.updateUI()
        }
    }
    
    public func libraryViewDidToggleMultipleSelection(enabled: Bool) {
        v.layoutIfNeeded()
        updateUI()
        didTapMultipleSelection?(enabled)
    }
    
    public func libraryViewHaveNoItems() {
        pickerVCDelegate?.libraryHasNoItems()
    }
    
    public func libraryViewShouldAddToSelection(indexPath: IndexPath, numSelections: Int) -> Bool {
        return pickerVCDelegate?.shouldAddToSelection(indexPath: indexPath, numSelections: numSelections) ?? true
    }

    public func libraryViewDidTapSecondaryButton() {
        didTapSecondaryLibraryButton?()
    }

    public func libraryViewDidTapAlbum() {
        navBarTapped()
    }
}
