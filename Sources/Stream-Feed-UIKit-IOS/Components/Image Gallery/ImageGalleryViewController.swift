//
//  ImageGalleryViewController.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 13/02/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit
import Reusable
import SnapKit
import Nuke

/// An simple image gallery. It loads the
public final class ImageGalleryViewController: UIViewController {
    
    /// A scroll view to dismiss the gellary by pull down.
    public let scrollView = UIScrollView(frame: .zero)
    /// A horizontal collection view with images.
    public let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    /// An image URL's.
    public var imageURLs: [URL] = []
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupScrollView()
        setupCollectionView()
        addCloseButton()
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func addCloseButton() {
        let closeButton = UIButton(frame: .zero)
        closeButton.setImage(.closeIcon, for: .normal)
        closeButton.tintColor = .white
        closeButton.contentMode = .center
        closeButton.addTap { [weak self] _ in self?.dismiss(animated: true) }
        view.addSubview(closeButton)

        closeButton.snp.makeConstraints { make in
            make.top.equalTo(26)
            make.right.equalTo(-16)
            make.width.height.equalTo(40)
        }
    }
}

// MARK: - Scroll View

extension ImageGalleryViewController: UIScrollViewDelegate {
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.delegate = self
        scrollView.backgroundColor = .black
        scrollView.snp.makeConstraints { $0.edges.equalToSuperview() }
        scrollView.contentSize = UIScreen.main.bounds.size
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        collectionView.alpha = CGFloat.maximum(0, 1 - scrollView.contentOffset.y / -150)
        
        if scrollView.contentOffset.y < -100 {
            dismiss(animated: true)
        }
    }
}

// MARK: - Collection View

extension ImageGalleryViewController: UICollectionViewDataSource {
    
    private func setupCollectionView() {
        collectionView.backgroundColor = .black
        collectionView.isPagingEnabled = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.register(cellType: ImageGalleryCollectionViewCell.self)
        scrollView.addSubview(collectionView)
        
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.size.equalToSuperview()
        }
        
        if let flow = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flow.scrollDirection = .horizontal
            flow.itemSize = UIScreen.main.bounds.size
            flow.minimumLineSpacing = 0
            flow.minimumInteritemSpacing = 0
        }
        
        collectionView.reloadData()
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageURLs.count
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(for: indexPath) as ImageGalleryCollectionViewCell
        
        cell.activityIndicatorView.startAnimating()
        
        if indexPath.item < imageURLs.count {
            let url = imageURLs[indexPath.item]
            
            cell.loadImage(url) { [weak self] in
                if $0 != nil, let badIndex = self?.imageURLs.firstIndex(of: url) {
                    self?.imageURLs.remove(at: badIndex)
                    self?.collectionView.reloadData()
                }
            }
        }
        
        return cell
    }
}

// MARK: - Cell

/// An image gallery collection view cell.
public final class ImageGalleryCollectionViewCell: UICollectionViewCell, Reusable {
    /// An image view.
    public let imageView = UIImageView(frame: .zero)
    /// An activity indicator.
    public let activityIndicatorView = UIActivityIndicatorView(style: .white)
    private var imageTask: ImageTask?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(imageView)
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        imageView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        addSubview(activityIndicatorView)
        activityIndicatorView.snp.makeConstraints { $0.center.equalToSuperview() }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func prepareForReuse() {
        imageView.image = nil
        imageView.contentMode = .scaleAspectFit
        activityIndicatorView.stopAnimating()
        imageTask?.cancel()
        imageTask = nil
    }
    
    /// Loads the image by a given URL.
    public func loadImage(_ url: URL, completion: @escaping (_ error: Error?) -> Void) {
        imageTask?.cancel()
        activityIndicatorView.startAnimating()
        
        imageTask = ImagePipeline.shared.loadImage(with: url) { [weak self] result in
            guard let self = self else {
                return
            }
            
            self.activityIndicatorView.stopAnimating()
            
            if let image = try? result.get().image {
                self.imageView.image = image
            } else {
                self.imageView.contentMode = .center
                self.imageView.image = .imageIcon
            }
            
            completion(result.error)
        }
    }
}

// MARK: - Routing to the Gallery

extension UIViewController {
    
    /// Presents the image gallery with a given image URL's.
    public func showImageGallery(with imageURLs: [URL]?, animated: Bool = true) {
        guard let imageURLs = imageURLs else {
            return
        }
        
        let imageGalleryViewController = ImageGalleryViewController()
        imageGalleryViewController.imageURLs = imageURLs
        present(imageGalleryViewController, animated: animated)
    }
}
