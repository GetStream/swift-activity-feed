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

public final class ImageGalleryViewController: UIViewController {
    
    let scrollView = UIScrollView(frame: .zero)
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    var imageURLs: [URL] = []

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
    
    public func addCloseButton() {
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
        cell.loadImage(imageURLs[indexPath.item])
        
        return cell
    }
}

// MARK: - Cell

public final class ImageGalleryCollectionViewCell: UICollectionViewCell, Reusable {
    let imageView = UIImageView(frame: .zero)
    let activityIndicatorView = UIActivityIndicatorView(style: .white)
    var imageTask: ImageTask?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(imageView)
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        imageView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        addSubview(activityIndicatorView)
        activityIndicatorView.snp.makeConstraints { $0.center.equalToSuperview() }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func prepareForReuse() {
        imageView.image = nil
        imageView.contentMode = .scaleAspectFit
        activityIndicatorView.stopAnimating()
        imageTask?.cancel()
        imageTask = nil
    }
    
    func loadImage(_ url: URL) {
        imageTask?.cancel()
        activityIndicatorView.startAnimating()
        
        imageTask = ImagePipeline.shared.loadImage(with: url) { [weak self] response, error in
            self?.activityIndicatorView.stopAnimating()
            
            if let image = response?.image {
                self?.imageView.image = image
            } else {
                self?.imageView.contentMode = .center
                self?.imageView.image = .imageIcon
            }
        }
    }
}
