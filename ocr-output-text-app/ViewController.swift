//
//  ViewController.swift
//  ocr-output-text-app
//

import UIKit
import PhotosUI

class ViewController: UIViewController {

    /**
     * 初期画面表示
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ナビゲーションコントローラーによる管理
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemTeal
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        navigationController?.navigationBar.scrollEdgeAppearance = appearance

    }

    /**
     * ライブラリから選択
     */
    @IBAction func selectFromPhotoApp(){
        
        // PHPickerConfiguration の設定
        // 画像のみかつ選択できる枚数を1枚に制限
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = PHPickerFilter.images
        // 例 configuration.filter = PHPickerFilter.any(of: [.livePhotos, .videos])
            
        // 定義した構成を元に、実際に表示させるPickerviewを構築
        let pickerViewController = PHPickerViewController(configuration: config)
        pickerViewController.delegate = self
        pickerViewController.modalPresentationStyle = .fullScreen
        self.present(pickerViewController, animated: true, completion: nil)
    }

}

extension ViewController: UINavigationControllerDelegate, PHPickerViewControllerDelegate {
    
    /**
     写真選択完了イベント
     */
    // 配列形式のPHPickerResult形式で取得
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        // 非同期処理の前に写真選択画面を閉じる
        picker.dismiss(animated: true)
        
        // 1つのみ選択なので、先頭を決め打ちで取得
        if let itemProvider = results.first?.itemProvider{
            // 対象のプロバイダーオブジェクトを読み込めるかどうかを識別
            if itemProvider.canLoadObject(ofClass: UIImage.self) {
                
                // 画像の取り込み
                // loadObjectメソッドは非同期で実行されるメソッド
                // completionHandlerから対象のデータとエラーに参照できる
                itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                    guard let selectedImage = image as? UIImage else {
                        return
                    }
                    // 非同期で実行されるので、メインスレッドで画像をセットする処理を行わないと、
                    // 画像がnilのまま進んでしまう
                    DispatchQueue.main.async {
                        
                        // 画像の表示処理
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        if let executeOcrVC =  storyboard.instantiateViewController(withIdentifier: "executeOcr") as? ExecuteOcrViewController {
                            
                            executeOcrVC.selectedUIImage = selectedImage
                            self?.navigationController?.pushViewController(executeOcrVC, animated: true)
                        }
                    }

                }
            }
        }
    }
    
    /**
     *  画面遷移時
     */
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//
//        // 遷移先のViewControllerのプロパティに渡す値をセット
//        if let executeOcrVC = segue.destination as? ExecuteOcrViewController {
//            // 値を渡す
//            executeOcrVC.selectedUIImage = self.selectedUiImage
//        }
//    }

}
