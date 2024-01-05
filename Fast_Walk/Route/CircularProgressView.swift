//
//  CircularProgressView.swift
//  Fast_Walk
//
//  Created by visitor on 2023/12/22.
//

import UIKit

class CircularProgressView: UIView {
    var progressLayer = CAShapeLayer()
    var progressColor: UIColor = .blue {
        didSet {
            progressLayer.strokeColor = progressColor.cgColor
        }
    }
    var trackColor: UIColor = .lightGray {
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
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineCap = .round
        progressLayer.lineWidth = 10.0
        progressLayer.strokeEnd = 0
        layer.addSublayer(progressLayer)
    }

    func setProgress(to value: CGFloat) {
        progressLayer.strokeEnd = value
    }
}
