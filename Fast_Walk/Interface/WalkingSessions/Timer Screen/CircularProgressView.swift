//
//  CircularProgressView.swift
//  Fast_Walk
//
//  Created by visitor on 2023/12/22.
//

import UIKit

class CircularProgressView: UIView {
    var progressLayer = CAShapeLayer()
    var progressColor = UIColor(red: 221/255, green: 232/255, blue: 252/255, alpha: 1.0){
        didSet {
            progressLayer.strokeColor = progressColor.cgColor
        }
    }
    var trackColor: UIColor = UIColor(red: 79/255, green: 134/255, blue: 255/255, alpha: 1.0) {
        didSet {
            progressLayer.backgroundColor = trackColor.cgColor
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupProgressLayer()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupProgressLayer()
    }

    private func setupProgressLayer() {
        let circularPath = UIBezierPath(arcCenter: CGPoint(x: frame.size.width / 2.0, y: frame.size.height / 2.0), radius: (frame.size.width - 10)/2, startAngle: -CGFloat.pi / 2, endAngle: 2 * CGFloat.pi, clockwise: true)
        progressLayer.path = circularPath.cgPath
        progressLayer.fillColor = CGColor(red: 221/255, green: 232/255, blue: 252/255, alpha: 1.0)
        progressLayer.lineCap = .round
        progressLayer.lineWidth = 10.0
        progressLayer.strokeEnd = 0
        layer.addSublayer(progressLayer)
    }

    func setProgress(to value: CGFloat) {
        progressLayer.strokeEnd = value
    }
}
