//
//  AdvancedSizeClassVC.swift
//  ThinkingAndTesting
//
//  Created by East.Zhang on 2021/5/7.
//  Copyright © 2021 dadong. All rights reserved.
//

import UIKit

@objcMembers
public class _Screen: NSObject {
    public let name: String
    public let width: CGFloat
    public let height: CGFloat
    public let safeArea: UIEdgeInsets
    public let scale: Int
    
    public init(name: String, width: CGFloat, height: CGFloat, safeArea: UIEdgeInsets, scale: Int) {
        self.name = name
        self.width = width
        self.height = height
        self.safeArea = safeArea
        self.scale = scale
    }
    
    public convenience init(name: String, width: CGFloat, height: CGFloat, scale: Int = 3) {
        self.init(name: name, width: width, height: height, safeArea: .zero, scale: scale)
    }
    
    public convenience init(fullDisplay name: String, width: CGFloat, height: CGFloat, top: CGFloat = 44, scale: Int = 3) {
        // 底部安全区域高度 （只有全面屏有）
        let bottom: CGFloat = 34
        let safeArea = UIEdgeInsets(top: top, left: 0, bottom: bottom, right: 0)
        self.init(name: name, width: width, height: height, safeArea: safeArea, scale: scale)
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        if let another = object as? _Screen, another.name == name {
            return true
        }
        return super.isEqual(object)
    }
    
    fileprivate func isAvailable(for screenBounds: CGRect) -> Bool {
        let size = screenBounds.size
        return width <= size.width && height <= size.height
    }
}


public class AdvancedSizeClassVC: UIViewController {
    
    /// 全部的设备
    private let all: [_Screen] = AdvancedSizeClassVC.allScreens()
    
    private var items: [_Screen] = []
    
    private var current: _Screen?

    // 列表
    private lazy var tableView: UITableView = {
        let v = UITableView(frame: view.bounds, style: .plain)
        v.showsVerticalScrollIndicator = false
        v.showsHorizontalScrollIndicator = false
        v.backgroundColor = .white
        v.alwaysBounceVertical = true
        v.alwaysBounceHorizontal = false
        v.delegate = self
        v.dataSource = self
        return v
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupData()
    }
    
    private func setupUI() {
        view.addSubview(tableView)

        let btnSave = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 30))
        btnSave.setTitle("保存", for: .normal)
        btnSave.setTitleColor(.white, for: .normal)
        btnSave.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        btnSave.layer.shadowColor = UIColor.black.cgColor
        btnSave.layer.shadowOffset = CGSize(width: 0, height: 4)
        btnSave.layer.shadowOpacity = 0.5
        btnSave.layer.shadowRadius = 4
        btnSave.layer.cornerRadius = 10
        btnSave.backgroundColor = .systemGray
        btnSave.addTarget(self, action: #selector(actionSave), for: .touchUpInside)
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(actionLongPress))
        btnSave.addGestureRecognizer(gesture)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: btnSave)
    }
    
    private func setupData() {
                
        // 过滤 -> 得到支持变更成的列表
        items = all.filter({ $0.isAvailable(for: Self.originScreenBounds) })
        
        if let last = Self.lastTimeChoosenScreen(), items.contains(last) {
            current = last
        }
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    /// 保存操作
    @objc
    private func actionSave() {
        saveChoosenScreen(current)
        // 强制退出app
        exit(0)
    }
    
    /// 长按
    @objc
    private func actionLongPress(_ gesture: UIGestureRecognizer) {
        if gesture.state == .began {
            let vc = LayoutOptionsVC()
            vc.completion = { [weak self] option in
                self?.saveChoosenScreen(self?.current)
                self?.save(layoutOption: option)
                // 强制退出app
                exit(0)
            }
//            view.addSubview(vc.view)
//            addChild(vc)
            present(vc, animated: true, completion: nil)
        }
    }
}


// MARK: - UITableViewDelegate, UITableViewDataSource

extension AdvancedSizeClassVC: UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.row]
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        }
        cell?.textLabel?.text = item.name
        
        if item == current {
            cell?.accessoryType = .checkmark
        } else {
            cell?.accessoryType = .none
        }
        return cell!
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        if item == current {
            // 再次选中当前选中的，取消勾选
            current = nil
            tableView.reloadRows(at: [indexPath], with: .automatic)
        } else {
            var reloads: [IndexPath] = []
            if let before = current, let index = items.firstIndex(of: before) {
                let ip = IndexPath(item: index, section: 0)
                reloads.append(ip)
            }
            reloads.append(indexPath)

            current = item
            
            tableView.reloadRows(at: reloads, with: .automatic)
        }
    }
}


// MARK: -

public extension AdvancedSizeClassVC {
    
    /// 保存选中的屏幕
    private func saveChoosenScreen(_ choosen: _Screen?) {
        if let tmp = choosen {
            UserDefaults.standard.setValue(tmp.name, forKey: "kTestChoosenScreen")
        } else {
            UserDefaults.standard.removeObject(forKey: "kTestChoosenScreen")
        }
    }
    
    /// 上次选中的屏幕
    @objc
    static func lastTimeChoosenScreen() -> _Screen? {
        // 这句代码的位置不能更改。这里使用了首次调用的副作用。
        let bounds = Self.originScreenBounds
        
        if let value = UserDefaults.standard.value(forKey: "kTestChoosenScreen") as? String {
            let all = allScreens()
            for screen in all {
                if screen.name == value {
                    if !screen.isAvailable(for: bounds) {
                        print("你可能更改了屏幕的放大/标准模式，上一次设置的尺寸已经不符合当前状态下的设备，已自动使用原始大小！")
                        return nil
                    }
                    return screen
                }
            }
        }
        return nil
    }
    
    /// 当前主window最适合的frame （在大屏幕里显示小的时候，居中）
    @objc
    static func bestFrameForMainWindow() -> CGRect {
        let originSize = originScreenBounds.size
        let now = UIScreen.main.bounds
        let nowSize = now.size
        let deltaW: CGFloat = originSize.width - nowSize.width
        let deltaH: CGFloat = originSize.height - nowSize.height
        if Int(deltaW) > 0 || Int(deltaH) > 0 {
            // 长或者宽和原来的不相等，则是发生了尺寸变化(设置了不同系列的)
            var x: CGFloat = deltaW / 2
            var y: CGFloat = deltaH / 2
            let option = lastLayoutOption()
            if option.rawValue.hasPrefix("左") {
                x = 0
            } else if option.rawValue.hasPrefix("右") {
                x = deltaW
            }
            if option.rawValue.contains("上") {
                y = 0
            } else if option.rawValue.contains("下") {
                y = deltaH
            }
            return CGRect(origin: CGPoint(x: x, y: y), size: nowSize)
        }
        return now
    }

    @objc static let originScreenBounds: CGRect = UIScreen.main.bounds

    /// 获取原始（真正的)的屏幕大小
    private static func _originScreenBounds() -> CGRect {
        let key = "kTestOriginScreenBounds"
        if let value = UserDefaults.standard.value(forKey: key) as? String {
            return NSCoder.cgRect(for: value)
        }
        
        let bounds = UIScreen.main.bounds
        let value = NSCoder.string(for: bounds)
        UserDefaults.standard.setValue(value, forKey: key)
        return bounds
    }
    
    /// 保存布局选项
    private func save(layoutOption: LayoutOption) {
        UserDefaults.standard.setValue(layoutOption.rawValue, forKey: "test_layout_option")
    }
    
    /// 取出上次存储的布局选项。 如果为空，则使用居中
    fileprivate static func lastLayoutOption() -> LayoutOption {
        if let tmp = UserDefaults.standard.object(forKey: "test_layout_option") as? String,
           let option = LayoutOption(rawValue: tmp) {
            return option
        }
        return .center
    }
    
    /// 目前已知的所有不同尺寸系列的设备
    private static func allScreens() -> [_Screen] {
        var s: [_Screen] = []
        s.append(.init(name: "iPhone 4", width: 320, height: 480, scale: 2))
        s.append(.init(name: "iPhone 5", width: 320, height: 568, scale: 2))
        s.append(.init(name: "iPhone 6", width: 375, height: 667, scale: 2))
        s.append(.init(name: "iPhone 6 Plus", width: 414, height: 736, scale: 3))
        s.append(.init(fullDisplay: "iPhone X / Xs", width: 375, height: 812, scale: 3))
        s.append(.init(fullDisplay: "iPhone Xr", width: 414, height: 896, scale: 2))
        s.append(.init(fullDisplay: "iPhone Xs Max", width: 414, height: 896, scale: 3))
        s.append(.init(fullDisplay: "iPhone 11", width: 414, height: 896, scale: 2))   // 和 Xr 一样
        s.append(.init(fullDisplay: "iPhone 11 Pro", width: 375, height: 812, scale: 3))   // 和 iPhone X / Xs 一样
        s.append(.init(fullDisplay: "iPhone 11 Pro Max", width: 414, height: 896, scale: 3))   // 和 iPhone Xs Max 一样
        s.append(.init(fullDisplay: "iPhone 12 Mini", width: 375, height: 812, top: 50, scale: 3))
        s.append(.init(fullDisplay: "iPhone 12 / 12 Pro", width: 390, height: 844, top: 47, scale: 3))
        s.append(.init(fullDisplay: "iPhone 12 Pro Max", width: 428, height: 926, top: 47, scale: 3))
        s.append(.init(fullDisplay: "iPhone 13 Mini", width: 375, height: 812, top: 50, scale: 3))  // 和 12 Mini 一样
        s.append(.init(fullDisplay: "iPhone 13 / 13 Pro", width: 390, height: 844, top: 47, scale: 3))  // 和 12 / 12 Pro 一样
        s.append(.init(fullDisplay: "iPhone 13 Pro Max", width: 428, height: 926, top: 47, scale: 3))   // 和 12 Pro Max 一样
        return s
    }
}



// MARK: -


/// 布局选项
enum LayoutOption: String, CaseIterable {
    case leftTop        = "左上角"
    case top            = "上边"
    case rightTop       = "右上角"
    case left           = "左边"
    case center         = "居中"
    case right          = "右边"
    case leftBottom     = "左下角"
    case bottom         = "下边"
    case rightBottom    = "右下角"
}

/// 布局选择页
private class LayoutOptionsVC: UIViewController {
    
    let options = LayoutOption.allCases
    
    let current: LayoutOption = AdvancedSizeClassVC.lastLayoutOption()
    
    var completion: ((LayoutOption) -> Void)?
    
    // 列表
    private lazy var listView: UICollectionView = {
        let layout = SCLayout()
        let v = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        v.showsVerticalScrollIndicator = false
        v.showsHorizontalScrollIndicator = false
        v.backgroundColor = .white
        v.alwaysBounceVertical = true
        v.alwaysBounceHorizontal = false
        v.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        v.delegate = self
        v.dataSource = self
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "请选择屏幕的位置"
        view.addSubview(listView)
    }
}

extension LayoutOptionsVC : UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        options.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = options[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        var label = cell.contentView.viewWithTag(100) as? UILabel
        if label == nil {
            let v = UILabel(frame: cell.contentView.bounds)
            v.tag = 100
            v.textAlignment = .center
            label = v
            cell.contentView.addSubview(v)
        }
        label?.text = item.rawValue
        
        if item == .center {
            // 推荐居中，突出
            label?.font = .systemFont(ofSize: 30, weight: .bold)
            cell.contentView.backgroundColor = .gray
        } else if item.rawValue.count == 2 {
            // 上下左右，第二突出
            label?.font = .systemFont(ofSize: 18, weight: .semibold)
            cell.contentView.backgroundColor = .lightGray
        } else {
            // 其他
            label?.font = .systemFont(ofSize: 12, weight: .regular)
            cell.contentView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        }
        
        // 处理当前选中的
        if item == current {
            label?.textColor = .red
        } else {
            label?.textColor = .black
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = options[indexPath.row]
        completion?(item)
    }
}


private class SCLayout: UICollectionViewFlowLayout {
    
    /// 格子相对于宽/高的比例
    enum Size: CGFloat {
        case normal = 0.3
        case large  = 0.4
    }
    
    var attrs: [UICollectionViewLayoutAttributes] = []
    
    override func prepare() {
        super.prepare()
        
        guard let cv = collectionView else {
            return
        }
        
        attrs.removeAll()
        
        var lastRow = 0
        var lastCol = 0
        var last: CGRect = .zero
        var edgeInset = cv.contentInset
        if #available(iOS 11.0, *) {
            edgeInset.top += cv.adjustedContentInset.top
            edgeInset.bottom += cv.adjustedContentInset.bottom
        }
        let width = cv.bounds.width - edgeInset.left - edgeInset.right
        let height = cv.bounds.height - edgeInset.top - edgeInset.bottom
        let count = cv.numberOfItems(inSection: 0)
        for i in 0..<count {
            let indexPath = IndexPath(row: i, section: 0)
            let attr = layoutAttributesForItem(at: indexPath) ?? UICollectionViewLayoutAttributes(forCellWith: indexPath)
            let row = i / 3
            let col = i % 3
            let sizeX: Size = (col == 1 ? .large : .normal)
            let sizeY: Size = (row == 1 ? .large : .normal)
            let w: CGFloat = sizeX.rawValue * width
            let h: CGFloat = sizeY.rawValue * height
            var x: CGFloat = last.minX
            var y: CGFloat = last.minY
            if lastRow != row {
                lastRow = row
                y = last.maxY
                x = 0
            } else if lastCol != col {
                lastCol = col
                x = last.maxX
            }
            let frame = CGRect(x: x, y: y, width: w, height: h)
            attr.frame = frame
            attrs.append(attr)
            last = frame
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attrs
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        true
    }
}
