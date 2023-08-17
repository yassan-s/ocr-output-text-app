//
//  ResultOcrViewController.swift
//  ocr-output-text-app
//

import UIKit

class ResultOcrViewController: UIViewController {
    
    // 画像認識文字列
    var recognizedStrings: String!
    // 選択画像
    var selectedUIImage: UIImage!
    // 結果表示
    @IBOutlet var textView: UITextView!
    // 選択画像
    @IBOutlet weak var imageView: UIImageView!
    
    // 最初の画面に戻るボタン
    var returnFirstViewBarButtonItem: UIBarButtonItem!
    

    override func viewDidLoad() {
        // 画面表示
        super.viewDidLoad()
        
        // 文字の背景色を白色、文字を黒色
        textView.backgroundColor = UIColor.white
        textView.textColor = UIColor.black
        // 渡ってきた値をセット
        self.textView.text = self.recognizedStrings
        self.imageView.image = self.selectedUIImage
        
        // ボタンを初期化
        returnFirstViewBarButtonItem = UIBarButtonItem(title: "選択画面へ", style: .done, target: self, action: #selector(returnFirstViewBarButtonTapped(_:)))
        // barにボタンを追加
        self.navigationItem.rightBarButtonItems = [returnFirstViewBarButtonItem]

    }

    /**
     * 選択画面へボタン押下時の処理
     */
    @objc func returnFirstViewBarButtonTapped(_ sender: UIBarButtonItem) {
        navigationController?.popToRootViewController(animated: true)
    }
}
