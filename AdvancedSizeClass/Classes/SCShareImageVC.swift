//
//  SCShareImageVC.swift
//  ThinkingAndTesting
//
//  Created by East.Zhang on 2021/5/9.
//  Copyright © 2021 dadong. All rights reserved.
//
//  分享图片的页面.
//  传入一个图片即可
//

import UIKit
import Photos

public class SCShareImageVC: UIViewController {

    enum Kind: String {
        case save       = "保存图片"
        case airdrop    = "Airdrop"
    }
    
    struct Item {
        let kind: Kind
    }
    
    private lazy var imageView: UIImageView = {
        let v = UIImageView(frame: .zero)
        v.contentMode = .scaleAspectFit
        v.image = image
        return v
    }()
    
    private lazy var optionsView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.itemSize = CGSize(width: 100, height: 44)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        let v = UICollectionView(frame: .zero, collectionViewLayout: layout)
        v.backgroundColor = .clear
        v.showsVerticalScrollIndicator = false
        v.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        v.delegate = self
        v.dataSource = self
        return v
    }()
    
    /// 关闭按钮
    private lazy var btnClose: UIButton = {
        let v = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        v.setTitle("关闭", for: .normal)
        v.setTitleColor(.white, for: .normal)
        v.titleLabel?.font = .systemFont(ofSize: 12)
        v.layer.masksToBounds = true
        v.layer.cornerRadius = v.bounds.width / 2
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.white.cgColor
        v.backgroundColor = .red
        v.addTarget(self, action: #selector(actionClose), for: .touchUpInside)
        return v
    }()
    
    private var items: [Item] = []
    
    /// 外部传入的 - 需要展示的图片
    var image: UIImage? {
        didSet {
            if self.isViewLoaded {
                imageView.image = image
            }
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        view.addSubview(imageView)
        view.addSubview(optionsView)
        view.addSubview(btnClose)
    }
    
    private func setupData() {
        items.append(Item(kind: .save))
        items.append(Item(kind: .airdrop))
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let margin: CGFloat = 8
        var marginBottom: CGFloat = 80
        var width: CGFloat = view.bounds.width - margin * 2
        var height: CGFloat = view.bounds.height - margin - marginBottom
        imageView.frame = CGRect(x: margin, y: margin, width: width, height: height)
        
        width = view.bounds.width
        height = 44
        marginBottom = margin
        var y = view.bounds.height - marginBottom - height
        optionsView.frame = CGRect(x: 0, y: y, width: width, height: height)
        
        let x = view.bounds.width - btnClose.bounds.width - margin
        y = margin
        if #available(iOS 11.0, *) {
            if let top = view.window?.safeAreaInsets.top {
                y = top + margin
            }
        }
        btnClose.frame.origin = CGPoint(x: x, y: y)
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 点击空白地方收回此页面
        closeCurrentPage()
    }
    
    // 关闭当前页面
    private func closeCurrentPage() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    private func actionClose() {
        closeCurrentPage()
    }
}


// MARK: - <UICollectionViewDelegate, UICollectionViewDataSource>

extension SCShareImageVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = items[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        var button = cell.contentView.viewWithTag(100) as? UIButton
        if button == nil {
            let v = UIButton(frame: cell.contentView.bounds)
            v.tag = 100
            v.backgroundColor = .white
            v.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
            v.setTitleColor(.black, for: .normal)
            v.layer.cornerRadius = 4
            v.layer.masksToBounds = true
            v.isUserInteractionEnabled = false
            cell.contentView.addSubview(v)
            button = v
        }
        button?.setTitle(item.kind.rawValue, for: .normal)
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        switch item.kind {
        case .save:
            let save = { [weak self] in
                if let img = self?.image {
                    //  - (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
                    UIImageWriteToSavedPhotosAlbum(img, self, #selector(self!.image1(_:didFinishSavingWith:contextInfo:)), nil)
                }
            }
            let status = PHPhotoLibrary.authorizationStatus()
            if status == .notDetermined {
                PHPhotoLibrary.requestAuthorization { newStatus in
                    if newStatus == .authorized {
                        save()
                    }
                }
            } else if status == .authorized {
                save()
            }
            
        case .airdrop:
            if let image = image {
                let vc = UIActivityViewController(activityItems: [image], applicationActivities: nil)
                present(vc, animated: true, completion: nil)
            }
        }
    }
    
    @objc
    private func image1(_ image: UIImage, didFinishSavingWith error: Error?, contextInfo: UnsafeMutableRawPointer?) {
        if let error = error {
            print("\(error.localizedDescription)")
        } else {
            print("成功存入相册")
            closeCurrentPage()
        }
    }
}


// MARK: -

public extension SCShareImageVC {
    
    /// 触发截图 (截取当前变更后的屏幕)
    /// - Parameter autoShow: 是否自动展示. 默认是true. 一般情况下都传true！  注意：截图失败的情况下不会展示，即该值无效!
    /// - Returns: 截取到的图片
    @objc
    @discardableResult
    static func triggleSnapshot(autoShow: Bool = true) -> UIImage? {
        if let delegate = UIApplication.shared.delegate,
           let response = delegate.window,  // 这个是delegate中的optional方法， 这里只能判定是否实现了window方法
           let window = response,           // 这里才是代表，实现协议的对象里返回了非nil值
           let screen = AdvancedSizeClassVC.lastTimeChoosenScreen() {
            let size = window.bounds.size
            UIGraphicsBeginImageContextWithOptions(size, true, CGFloat(screen.scale))
            window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            if autoShow, let img = image {
                let vc = SCShareImageVC()
                vc.modalPresentationStyle = .fullScreen
                vc.image = img
                window.rootViewController?.present(vc, animated: true, completion: nil)
            }
            return image
        }
        return nil
    }
}
