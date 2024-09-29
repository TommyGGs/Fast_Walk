import UIKit
import GoogleSignIn
import RealmSwift

class ProfileViewController: UIViewController {
    
    @IBOutlet var mail: UILabel!
    @IBOutlet var name: UILabel!
    @IBOutlet var favorites: UILabel!
    @IBOutlet var userIcon: UIImageView!
    @IBOutlet var popupView: UIView!
    @IBOutlet var blurBackground: UIVisualEffectView!
    @IBOutlet var logoutButton: UIButton!
    
    
    
    var user: User = User()
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    //テスト用
        print("ProfileViewController: viewDidLoad")

        self.view.backgroundColor = UIColor.clear
        setupPopupDesign()
        setupProfile()
        
        self.definesPresentationContext = true

        // ジェスチャーでポップアップを閉じる設定
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissPopup))
        blurBackground.addGestureRecognizer(tapGesture)
        blurBackground.isUserInteractionEnabled = true
        self.dismiss(animated: false, completion: nil)

    }
    
    // プロフィール情報をセットアップ
    func setupProfile() {
        if let currentUser = GIDSignIn.sharedInstance.currentUser {
            name.text = currentUser.profile?.name
            mail.text = currentUser.profile?.email
        } else {
            name.text = "ゲスト"
            mail.text = "ログインしていません"
        }
        favorites.text = "\(userFavorite())"
        icon()
    }
    
    
    
    
    
    // ポップアップのデザイン設定
    func setupPopupDesign() {
        blurBackground.isHidden = false
        blurBackground.effect = UIBlurEffect(style: .light)
        blurBackground.alpha = 0.8 // 追加

        // ポップアップの角丸デザイン
        popupView.layer.cornerRadius = 15
        popupView.layer.masksToBounds = true
        // 名前のスタイル設定
        name.font = UIFont.systemFont(ofSize: 28, weight: .bold) // 大きめのボールドフォント
        name.textAlignment = .center // 中央揃え
        
        // メールアドレスのスタイル設定
        mail.font = UIFont.systemFont(ofSize: 17, weight: .regular) // 標準のフォントサイズ
        mail.textAlignment = .center // 中央揃え
        mail.textColor = UIColor.gray // グレーの文字色
        
        // いいね数のスタイル
        favorites.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        favorites.textAlignment = .center
        favorites.textColor = UIColor.darkGray
        
        // アイコンの丸型表示
        userIcon.layer.cornerRadius = userIcon.frame.size.width / 2
        userIcon.layer.masksToBounds = true
        userIcon.layer.borderColor = UIColor.systemBlue.cgColor
        userIcon.layer.borderWidth = 2.0
        
        // ログアウトボタンのスタイル
        logoutButton.backgroundColor = UIColor.black
        logoutButton.setTitleColor(UIColor.white, for: .normal)
        logoutButton.layer.cornerRadius = 10
        logoutButton.setTitle("ログアウト", for: .normal)
        logoutButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        
        
//        view.backgroundColor = UIColor.white.withAlphaComponent(0) // Transparent background
//        view.layer.cornerRadius = 15
//        view.clipsToBounds = false
//
//        // Example: Make the view smaller
//        view.frame = CGRect(x: 50, y: 200, width: UIScreen.main.bounds.width - 100, height: 300)
    }
    
    // ポップアップを閉じる
    @objc func dismissPopup() {
        self.dismiss(animated: false, completion: nil)
    }
    
    // ログアウト処理
    @IBAction func logout(_ sender: Any) {
        print("loggin out button clicked")
        GIDSignIn.sharedInstance.signOut()
        GIDSignIn.sharedInstance.disconnect { error in
            if let error = error {
                print("Error disconnecting: \(error)")
            } else {
                DispatchQueue.main.async {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                    loginVC.modalPresentationStyle = .fullScreen
                    self.present(loginVC, animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func heartViewController() {
        let storyboard = UIStoryboard(name: "Favorite", bundle: nil)
        if let heartVC = storyboard.instantiateViewController(withIdentifier: "HeartViewController") as? HeartViewController {
            heartVC.modalPresentationStyle = .fullScreen
            self.present(heartVC, animated: false, completion: nil)
        }
    }
    
    
    // いいね数を取得
    func userFavorite() -> Int {
        // ユーザーIDを取得
        guard let userID = GIDSignIn.sharedInstance.currentUser?.userID else { return 0 }
        let favCount = realm.objects(FavoriteSpot.self).filter("userID == %@", userID).count
        return favCount
    }
    
    // Googleプロフィール画像を取得
    func icon() {
        if let user = GIDSignIn.sharedInstance.currentUser, let imageUrl = user.profile?.imageURL(withDimension: 80) {
            downloadImage(from: imageUrl) { image in
                DispatchQueue.main.async {
                    if let image = image {
                        self.userIcon.image = image
                        self.userIcon.layer.cornerRadius = self.userIcon.frame.size.width / 2
                    } else {
                        // デフォルトの画像を設定
                        self.userIcon.image = UIImage(named: "default_profile")
                    }
                    // デバッグ用ログ
                    print("Icon image updated")
                }
            }
        }
    }
    
    // 画像をダウンロード
    func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error downloading image: \(error)")
                completion(nil)
                return
            }
            guard let data = data, let image = UIImage(data: data) else {
                print("Failed to convert data to image.")
                completion(nil)
                return
            }
            completion(image)
        }.resume()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        loginVC.modalPresentationStyle = .fullScreen  // Ensuring it covers the full screen
        self.present(loginVC, animated: false, completion: nil)
    }
}
