
import CoreMotion
import UIKit
import GoogleMaps
import CoreLocation
import GooglePlaces
import HealthKitUI
import HealthKit
import CareKitUI

class EndViewController: EndScreenViewController{
    
    
    // Use lazy var to avoid the "Cannot override with a stored property" error
    lazy var HelpIt = HealthAndCareKitHelp()
    
    @IBOutlet weak var stepsLabelNo: UILabel!
    @IBOutlet weak var distanceLabelNo: UILabel!
    @IBOutlet weak var timeLabelNO: UILabel!
    @IBOutlet weak var paceLabelNo: UILabel!
//    @IBOutlet weak var homeButtonNo: UIButton!
    
    @IBOutlet weak var stepsLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
//    @IBOutlet weak var calorieLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
//    @IBOutlet weak var heartButton: UIButton!
    @IBOutlet weak var calorieLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var finishButton: UIButton!

    


    
    // Declare the UI elements
//    var calorieLabel: UILabel!
//    var dateLabel: UILabel!
//    var heartButton: UIButton!
    var circularProgressView: CircularProgressBarView!

    
    var receivedStepCount: Double = 0
    var receivedDistance: Double = 0
    var receivedTime: Int = 0
    var receivedAvgPace: Float = 0

    var calculatedCalories: Double = 0
    
    var distanceNumberLabel: UILabel!
    var paceNumberLabel: UILabel!
    var calorieNumberLabel: UILabel!


    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ラベルの作成
        distanceNumberLabel = UILabel()
        distanceNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        distanceNumberLabel.textAlignment = .center
        distanceNumberLabel.backgroundColor = UIColor(red: 0.7765, green: 0.8431, blue: 1.0, alpha: 0.5) // Alpha値を少し薄くして調整
        distanceNumberLabel.layer.cornerRadius = 10
        distanceNumberLabel.clipsToBounds = true
        distanceNumberLabel.adjustsFontSizeToFitWidth = true  // ここに追加
        distanceNumberLabel.minimumScaleFactor = 0.5  // 最小フォントサイズの縮小率

        
        paceNumberLabel = UILabel()
        paceNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        paceNumberLabel.textAlignment = .center
        paceNumberLabel.backgroundColor = UIColor(red: 0.7765, green: 0.8431, blue: 1.0, alpha: 0.5)
        paceNumberLabel.layer.cornerRadius = 10
        paceNumberLabel.clipsToBounds = true
        paceNumberLabel.adjustsFontSizeToFitWidth = true  // ここに追加
        paceNumberLabel.minimumScaleFactor = 0.5  // 最小フォントサイズの縮小率

        calorieNumberLabel = UILabel()
        calorieNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        calorieNumberLabel.textAlignment = .center
        calorieNumberLabel.backgroundColor = UIColor(red: 0.7765, green: 0.8431, blue: 1.0, alpha: 0.5)
        calorieNumberLabel.layer.cornerRadius = 10
        calorieNumberLabel.clipsToBounds = true
        calorieNumberLabel.adjustsFontSizeToFitWidth = true  // ここに追加
        calorieNumberLabel.minimumScaleFactor = 0.5  // 最小フォントサイズの縮小率


        
        setupUI()
        
        updateSessionData()

        // FIXED !!!! Calculate the progress based on the received steps and total step goal FIXED!!!
        let stepGoal: CGFloat = 10000.0 // Example step goal
        let progress = CGFloat(receivedStepCount) / stepGoal
        
        setupUI()
        
        // Set progress with animation
        circularProgressView.setProgress(to: progress, animated: true)
        
        // Update the steps label with the actual step count
        stepsLabel.text = "\(Int(receivedStepCount)) 歩"
        timeLabel.text = String(format: "%02d分%02d秒", receivedTime / 60, receivedTime % 60)
        
        // ボタンの見た目を変更
        finishButton.backgroundColor = .black
        finishButton.setTitle("終わる", for: .normal)
        finishButton.setTitleColor(.white, for: .normal)
        
        // フォントを NotoSansJP-Bold に設定
        finishButton.titleLabel?.font = UIFont(name: "NotoSansJP-Bold", size: 30)
        
        finishButton.layer.cornerRadius = 5
        finishButton.clipsToBounds = true
        // 下部の角を丸くしないように設定
        finishButton.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner] // 上部のみ丸くする

        
        finishButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            finishButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            finishButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            finishButton.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            finishButton.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100)
        ])
        
        view.bringSubviewToFront(finishButton)
        
        
        
        // 数値と単位を組み合わせてフォーマットする関数
        func createFormattedLabelText(number: String, unit: String) -> NSAttributedString {
            let numberAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont(name: "NotoSansJP-Bold", size: 30)!
            ]
            let unitAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont(name: "NotoSansJP-Regular", size: 17)!
            ]
            
            let numberAttributedString = NSMutableAttributedString(string: number, attributes: numberAttributes)
            let unitAttributedString = NSAttributedString(string: unit, attributes: unitAttributes)
            
            numberAttributedString.append(unitAttributedString)
            return numberAttributedString
        }
        
        
        





        // 配列をUIViewの配列として作成
        let labels: [UIView] = [distanceNumberLabel, paceNumberLabel, calorieNumberLabel]

        // スタックビューにラベルを追加
        let labelStackView = UIStackView(arrangedSubviews: labels)
        labelStackView.translatesAutoresizingMaskIntoConstraints = false
        labelStackView.axis = NSLayoutConstraint.Axis.horizontal
        labelStackView.distribution = UIStackView.Distribution.fillEqually
        labelStackView.spacing = 5
        view.addSubview(labelStackView)

        // 制約を追加
        NSLayoutConstraint.activate([
            labelStackView.bottomAnchor.constraint(equalTo: finishButton.topAnchor, constant: -10),
            labelStackView.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 60),
            labelStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            labelStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
        ])

        // セッションデータの更新
        updateSessionData()

        
        
        // 今日の日付を取得して表示
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy / MM / dd" // 日付のフォーマットを指定
        let dateString = dateFormatter.string(from: currentDate)
        dateLabel.text = dateString // 今日の日付を表示

        // Set progress with animation
        let totalStepsGoal: CGFloat = 1000.0
        let stepProgress = CGFloat(receivedStepCount) / totalStepsGoal
        circularProgressView.setProgress(to: stepProgress, animated: true)
        
        // Update the steps label with the actual step count
        stepsLabel.text = "\(Int(receivedStepCount)) 歩"
        timeLabel.text = String(format: "%02d分%02d秒", receivedTime / 60, receivedTime % 60)
        
        view.bringSubviewToFront(finishButton)
        
    }
    
    
    
    
// calculate data (New !!!)
    func updateSessionData() {
        // 距離を反映
        let distanceFormatted = String(format: "%.2f", receivedDistance)
        distanceNumberLabel.attributedText = createFormattedLabelText(number: distanceFormatted, unit: " km")
        
        // ペースを反映
        let paceFormatted = String(format: "%.2f", receivedAvgPace)
        paceNumberLabel.attributedText = createFormattedLabelText(number: paceFormatted, unit: " km/min")
        
        // カロリーを計算して反映
        calculatedCalories = calculateCalories(steps: receivedStepCount, distance: receivedDistance, time: receivedTime)
        let caloriesFormatted = String(format: "%.0f", calculatedCalories)
        calorieNumberLabel.attributedText = createFormattedLabelText(number: caloriesFormatted, unit: " cal")
    
        // 数値と単位を組み合わせてフォーマットするやつ
        func createFormattedLabelText(number: String, unit: String) -> NSAttributedString {
            let numberAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont(name: "NotoSansJP-Bold", size: 30)!
            ]
            let unitAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont(name: "NotoSansJP-Regular", size: 17)!
            ]
            
            let numberAttributedString = NSMutableAttributedString(string: number, attributes: numberAttributes)
            let unitAttributedString = NSAttributedString(string: unit, attributes: unitAttributes)
            
            numberAttributedString.append(unitAttributedString)
            return numberAttributedString
        }

    }
    
    func calculateCalories(steps: Double, distance: Double, time: Int) -> Double {
        // MET値（例: 平均歩行 3.5 METs）
        let mets: Double = 3.5
        
        // 体重（例: 平均70kg）
        let weightInKg: Double = 70.0
        
        // 時間（分単位に変換）
        let timeInHours: Double = Double(time) / 3600.0
        
        // 消費カロリーの計算
        let caloriesBurned = mets * weightInKg * timeInHours
        return caloriesBurned
    }


    
    
    
    @IBAction func goToRouteorTime() {
        let storyboard = UIStoryboard(name: "RouteOrTime", bundle: nil)
        if let route = storyboard.instantiateViewController(withIdentifier: "RouteOrTimeViewController") as? RouteOrTimeViewController {
            route.modalPresentationStyle = .fullScreen
            self.present(route, animated: false, completion: nil)
        }
    }

    func setupUI() {
        view.backgroundColor = .white
        
        // 日付ラベルのフォントを NotoSansJP-Regular に設定
        dateLabel.textAlignment = .center
                 dateLabel.translatesAutoresizingMaskIntoConstraints = false
        //         view.addSubview(dateLabel)
        dateLabel.font = UIFont(name: "NotoSansJP-Regular", size: 25)
        
        // Circular progress bar for steps
        circularProgressView = CircularProgressBarView(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
        circularProgressView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(circularProgressView)
        
        // Step count label inside the circular progress
        stepsLabel.font = UIFont(name: "NotoSansJP-Bold", size: 56)
        stepsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Time label below the steps
        timeLabel.font = UIFont(name: "NotoSansJP-Regular", size: 25)
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Heart button
//        heartButton.setImage(UIImage(systemName: "heart"), for: .normal)
//        heartButton.tintColor = .gray
//        heartButton.addTarget(self, action: #selector(toggleHeart), for: .touchUpInside)
//        heartButton.translatesAutoresizingMaskIntoConstraints = false

        distanceLabel.font = UIFont(name: "NotoSansJP-Bold", size: 24)
        calorieLabel.font = UIFont(name: "NotoSansJP-Bold", size: 24)
        
        setupConstraints()
    }


    // Set constraints for all UI elements
    func setupConstraints() {
        
        // Date label at the top, above the circular progress bar
        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            dateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        // Date label at the top
        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            dateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        // Circular progress bar constraints
        NSLayoutConstraint.activate([
            // circularProgressView の位置を上部に移動
            circularProgressView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            circularProgressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20), // ここで画面上部に移動
            circularProgressView.widthAnchor.constraint(equalToConstant: 250),
            circularProgressView.heightAnchor.constraint(equalToConstant: 250)
        ])

        // stepsLabel の位置を調整
        NSLayoutConstraint.activate([
            stepsLabel.centerXAnchor.constraint(equalTo: circularProgressView.centerXAnchor),
            stepsLabel.centerYAnchor.constraint(equalTo: circularProgressView.centerYAnchor)
        ])

        // timeLabel の位置を調整
        NSLayoutConstraint.activate([
            timeLabel.centerXAnchor.constraint(equalTo: stepsLabel.centerXAnchor),
            timeLabel.topAnchor.constraint(equalTo: stepsLabel.bottomAnchor, constant: 5) // `5`で少し下に表示
        ])
        
//健康データ設定追加＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿
        NSLayoutConstraint.activate([
            diseaseProgressView.topAnchor.constraint(equalTo: circularProgressView.bottomAnchor, constant: 20), // 円グラフの下に配置
            diseaseProgressView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            diseaseProgressView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7), // 画面幅の80%に設定
            diseaseProgressView.heightAnchor.constraint(equalToConstant: 20) // 高さを指定
        ])
        
        // 健康グラフなどの設定が完了したらメッセージを追加
        let messageLabel = UILabel()
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont.systemFont(ofSize: 16)
        messageLabel.textColor = .black

        // セッションに基づいた歩行時間を使ってメッセージを表示
        let walkingMinutes = receivedTime / 60 // 秒を分に変換
        messageLabel.text = "本日 \(walkingMinutes) 分のウォーキングで上記の病気を\n予防することに成功しました！\nこれからも継続して健康を保ちましょう！"

        // ラベルをビューに追加
        view.addSubview(messageLabel)

        // 健康グラフの下にメッセージを配置する制約
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: diseaseProgressView.bottomAnchor, constant: 48),
            messageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])

    }
}

// FIXED !!! Custom Circular Progress Bar FIXED!!!
class CircularProgressBarView: UIView {
    var progressLayer = CAShapeLayer()
    var trackLayer = CAShapeLayer()

    var progress: CGFloat = 0.0 {
        didSet {
            progressLayer.strokeEnd = progress
            setNeedsDisplay()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        createCircularPath()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        createCircularPath()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // ビューのレイアウトが更新されたときにパスを再作成
        updateCircularPath()
    }


    private func createCircularPath() {
           // ＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿円の半径を変更する部分＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿
           let radius = (frame.size.width - 10) / 2 // この数値を調整して円を大きく
           let circularPath = UIBezierPath(arcCenter: CGPoint(x: frame.size.width / 2, y: frame.size.height / 2), radius: radius, startAngle: -.pi / 2, endAngle: .pi * 3 / 2, clockwise: true)
        
        // Track layer (background of the progress)
        trackLayer.path = circularPath.cgPath
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = UIColor.lightGray.cgColor
        trackLayer.lineWidth = 15
        trackLayer.strokeEnd = 1.0
        layer.addSublayer(trackLayer)
        
        // Progress layer (actual progress bar)
        progressLayer.path = circularPath.cgPath
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = UIColor.systemBlue.cgColor // Set the color to blue as requested
        progressLayer.lineWidth = 15
        progressLayer.strokeEnd = 0.0
        layer.addSublayer(progressLayer)
    }

    //＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿オーバーライド部分＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿
    private func updateCircularPath() {
        // サイズ変更時にパスを更新
        let radius = (bounds.width - 10) / 2
        let circularPath = UIBezierPath(arcCenter: CGPoint(x: bounds.midX, y: bounds.midY),
                                        radius: radius,
                                        startAngle: -.pi / 2,
                                        endAngle: .pi * 3 / 2,
                                        clockwise: true)
        trackLayer.path = circularPath.cgPath
        progressLayer.path = circularPath.cgPath
    }

    
    
    
    
    func setProgress(to progress: CGFloat, animated: Bool) {
        if animated {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.duration = 1.0
            animation.fromValue = progressLayer.strokeEnd
            animation.toValue = progress
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            progressLayer.strokeEnd = progress
            progressLayer.add(animation, forKey: "animateProgress")
        } else {
            progressLayer.strokeEnd = progress
        }
    }
    
    
}
