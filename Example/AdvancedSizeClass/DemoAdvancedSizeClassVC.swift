//
//  DemoAdvancedSizeClassVC.swift
//  ThinkingAndTesting
//
//  Created by East.Zhang on 2021/5/7.
//  Copyright © 2021 dadong. All rights reserved.
//

import UIKit
import SnapKit
import AdvancedSizeClass

@available(iOS 11.0, *)
class DemoAdvancedSizeClassVC: UIViewController {

    lazy var imageView: UIImageView = {
        let v = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        v.image = UIImage(named: "empty_search")
        v.backgroundColor = .black
        return v
    }()
    
    lazy var titleLabel: UILabel = {
        let v = UILabel(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 60))
        v.text = "哈哈。这是几个文字！我是一个文字！我会有几行呢？"
        v.textColor = .purple
        v.numberOfLines = 0
        v.font = .systemFont(ofSize: 18, weight: .bold)
        return v
    }()
    
    lazy var textLabel: UILabel = {
        let v = UILabel(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 60))
        v.text = "我.y = 安全区域.top"
        v.textColor = .cyan
        v.numberOfLines = 0
        v.font = .systemFont(ofSize: 14, weight: .bold)
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.addSubview(textLabel)
        view.addSubview(imageView)
        view.addSubview(titleLabel)
        
        textLabel.snp.makeConstraints { make in
            let top = UIWindow().safeAreaInsets.top
            make.top.equalToSuperview().offset(top)
            make.left.centerX.equalToSuperview()
            make.height.equalTo(30)
        }
        
        addScreenshotGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        navigationController?.navigationBar.isHidden = true
//        UIApplication.shared.isStatusBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
//        super.viewWillDisappear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageView.center = view.center
        titleLabel.center.y = imageView.frame.maxY + 30
        
        titleLabel.frame.size.width = view.bounds.size.width

    }
    
    private func addScreenshotGesture() {
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(foureFingersSwipe))
        gesture.numberOfTouchesRequired = 4
        gesture.direction = .right
        view.addGestureRecognizer(gesture)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(actionLongPress))
        view.addGestureRecognizer(longPress)
    }
    
    /// 四指滑动
    @objc
    func foureFingersSwipe() {
        // 触发截图并展示
        SCShareImageVC.triggleSnapshot()
    }
    
    
    @objc
    func actionLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            let vc = AdvancedSizeClassVC()
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        delayMain(2.5) {
//            let vc = Scale_RotateVC()
//            self.present(vc, animated: true, completion: nil)
//        }
    }
}
