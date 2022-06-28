//
//  ImagePreview.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit
import JXPhotoBrowser
import SDWebImage
import Photos

class ImagePreview {

    static func show(urls: [URL], current: Int) {
        let browser = JXPhotoBrowser()
        browser.numberOfItems = {
            return urls.count
        }
        
        browser.cellClassAtIndex = { _ in
            LoadingImageCell.self
        }
        
        browser.reloadCellAtIndex = { context in
            let url = urls[context.index]
            let browserCell = context.cell as? LoadingImageCell
            browserCell?.index = context.index
            browserCell?.setImage(url: url)
        }
        
        browser.pageIndex = current
        browser.pageIndicator = JXPhotoBrowserNumberPageIndicator()
        
        browser.show()
    }
    
}

private class ProgressView: UIView {
    
    var progress: CGFloat = 0 {
        didSet {
            DispatchQueue.main.async {
                self.fanshapedLayer.path = self.makeProgressPath(self.progress).cgPath
                if self.progress >= 1.0 || self.progress < 0.01 {
                    self.isHidden = true
                } else {
                    self.isHidden = false
                }
            }
        }
    }
    
    let circleLayer = CAShapeLayer()
    
    let fanshapedLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        if self.frame.size.equalTo(.zero) {
            self.frame.size = CGSize(width: 50, height: 50)
        }
        
        backgroundColor = .clear
        let strokeColor = UIColor(white: 1, alpha: 0.8).cgColor
        
        circleLayer.strokeColor = strokeColor
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.path = makeCirclePath().cgPath
        layer.addSublayer(circleLayer)
        
        fanshapedLayer.fillColor = strokeColor
        layer.addSublayer(fanshapedLayer)
        
        progress = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func makeCirclePath() -> UIBezierPath {
        let arcCenter = CGPoint(x: bounds.midX, y: bounds.midY)
        let path = UIBezierPath(arcCenter: arcCenter, radius: 25, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
        path.lineWidth = 2
        return path
    }
    
    func makeProgressPath(_ progress: CGFloat) -> UIBezierPath {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = bounds.midY - 2.5
        let path = UIBezierPath()
        path.move(to: center)
        path.addLine(to: CGPoint(x: bounds.midX, y: center.y - radius))
        path.addArc(withCenter: center, radius: radius, startAngle: -CGFloat.pi / 2, endAngle: -CGFloat.pi / 2 + CGFloat.pi * 2 * progress, clockwise: true)
        path.close()
        path.lineWidth = 1
        return path
    }
}

private class LoadingImageCell: JXPhotoBrowserImageCell {
    
    let progressView = ProgressView()
    
    var localIdentifier = ""
    
    override func setup() {
        super.setup()
        
        addSubview(progressView)
        progressView.autoCenterInSuperview()
    }
    
    func setImage(url: URL, placeholder: UIImage? = nil) {
        progressView.progress = 0
        imageView.sd_setImage(with: url,
                              placeholderImage: placeholder,
                              options: [.retryFailed],
                              progress: { [weak self] (received, total, _) in
            guard let self = self else { return }
            self.progressView.progress = CGFloat(received) / CGFloat(total)
        }) { [weak self] (_, error, _, _) in
            guard let self = self else { return }
            self.progressView.progress = error == nil ? 1.0 : 0
            self.setNeedsLayout()
        }
    }

}
