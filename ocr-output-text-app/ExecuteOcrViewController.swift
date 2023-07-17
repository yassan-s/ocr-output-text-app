//
//  ExecuteOcrViewController.swift
//  ocr-output-text-app
//

import UIKit
import Vision
import PhotosUI

class ExecuteOcrViewController: UIViewController {
    
    // 選択画像
    @IBOutlet weak var imageView: UIImageView!
    // 画像認識文字列
    var recognizedStrings: String!
    // 選択画像
    var selectedUIImage: UIImage!

    
    /**
     * 初期画面表示
     */
    override func viewDidLoad() {
        self.imageView.image = self.selectedUIImage
        super.viewDidLoad()
    }

    /**
     * 「画像解析」を押下時
     */
    @IBAction func buttonTapedSearchImage(sender: UIButton){
            
        // リクエストを実行するCGImageを取得
        // CGImageに型変換する
        guard let cgImage: CGImage = self.imageView.image?.cgImage else { return }

        // image-request handler を新規作成
        let requestHandler = VNImageRequestHandler(cgImage: cgImage)

        // テキストを認識するための新しいリクエストを作成
        let request = VNRecognizeTextRequest(completionHandler: recognizeTextHandler)
        //　日本語を指定する
        request.recognitionLanguages = ["ja-JP"]
        // 速度よりも精度を優先する
        request.recognitionLevel = .accurate
        // 言語補正
        request.usesLanguageCorrection = true

        do {
            // テキスト認識のリクエストを実行
            try requestHandler.perform([request])
        } catch {
            print("Unable to perform the requests: \(error).")
        }
        
        // 画像の表示処理
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let resultOcrVC =  storyboard.instantiateViewController(withIdentifier: "resultOcr") as? ResultOcrViewController {
            
            // 値を渡す
            resultOcrVC.recognizedStrings = self.recognizedStrings
            resultOcrVC.selectedUIImage = self.selectedUIImage
            
            self.navigationController?.pushViewController(resultOcrVC, animated: true)
        }
    }
    
    /**
     * 解析結果の取得処理
     * クロージャ
     */
    func recognizeTextHandler(request: VNRequest, error: Error?) {
        // 画像内のテキスト領域を検出し結果を取得
        guard let observations =
                request.results as? [VNRecognizedTextObservation] else { // as? ダウンキャスト
            return
        }

        let maximumCandidates = 1
        var recognizedText = "" // 解析結果の文字列
        
        for observation in observations {
            // 最も優先度の高い候補の文字列を取得
            guard let candidate = observation.topCandidates(maximumCandidates).first else { continue }
            recognizedText += candidate.string
            recognizedText += "\n"
        }
        
        // 解析結果をTextViewにセット
        self.recognizedStrings = recognizedText
    }
    
    /**
     * 結果への画面遷移
     */
    func recognizeTextHandler(request: VNRequest, error: Error?) {
        
    }

}


