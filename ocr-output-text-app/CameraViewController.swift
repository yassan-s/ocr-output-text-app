//
//  CameraViewController.swift
//  ocr-output-text-app
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController, AVAudioPlayerDelegate {

    // デバイスからの入力と出力を管理するオブジェクトの作成
    var captureSession = AVCaptureSession()
    
    /* カメラデバイスを管理するオブジェクトの作成 */
    // メインカメラの管理オブジェクトの作成
    var mainCamera : AVCaptureDevice? // オプショナル型
    // インカメラの管理オブジェクトの作成
    var innerCamera : AVCaptureDevice?
    // 現在使用しているカメラデバイスの管理オブジェクトの作成
    var currentDevice : AVCaptureDevice?
    
    // キャプチャーの出力データを受け取るオブジェクト
    var photoOutput : AVCapturePhotoOutput?
    
    // プレビュー表示用のレイヤ
    var cameraPreviewLayer : AVCaptureVideoPreviewLayer?
    
    // シャッターボタン
    @IBOutlet weak var cameraButton: UIButton!
    

    /**
     初期画面表示
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        // 各種管理オブジェクトの設定を行う
        setupCaptureSession()
        setupDevice()
        setupInputOutput()
        setupPreviewLayer()
        captureSession.startRunning()
        styleCaptureButton()

    }
    
    /**
     シャッターボタンが押された時のアクション
     */
    @IBAction func cameraButton_TouchUpInside(sender: Any) {
        let settings = AVCapturePhotoSettings()
        // フラッシュの設定
        settings.flashMode = .off
        // カメラの手ぶれ補正
        settings.isAutoStillImageStabilizationEnabled = true
        // 撮影された画像をdelegateメソッドで処理
        self.photoOutput?.capturePhoto(with: settings, delegate: self as AVCapturePhotoCaptureDelegate)
    }
    
}


/**
画像がキャプチャされる直前に呼び出されるデリゲート
 */
extension CameraViewController: AVCapturePhotoCaptureDelegate{
    
    /**
     画像の保存機能。
     */
    // 撮影した画像データが生成されたときに呼び出されるデリゲートメソッド
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation() {
            // Data型をUIImageオブジェクトに変換
            let uiImage = UIImage(data: imageData)
            // 写真ライブラリに画像を保存
            UIImageWriteToSavedPhotosAlbum(uiImage!, nil,nil,nil)
            
            // 画像の表示処理
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let executeOcrVC =  storyboard.instantiateViewController(withIdentifier: "executeOcr") as? ExecuteOcrViewController {
                
                executeOcrVC.selectedUIImage = uiImage
                self.navigationController?.pushViewController(executeOcrVC, animated: true)
            }
        }
    }

    /**
    シャッターサウンドの無効化。
    */
   func photoOutput(_ output: AVCapturePhotoOutput, willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
       // シャッターサウンドの無効化
       AudioServicesDisposeSystemSoundID(1108)
   }
}


/*
初期画面表示前にカメラの設定を行う拡張メソッド
 */
extension CameraViewController {
    
    /**
     カメラの画質の設定
     */
    func setupCaptureSession() {
        // 高解像度の画像出力ができるphoto
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
    }
    
    /**
     デバイスの設定を行いセッションを取得。

     deviceTypes: カメラデバイスの種類
     mediaType: 取得するメディアの種類
     position: FaceTimeカメラとiSightカメラ

     builtInWideAngleCamera: カメラの種類[広角カメラ]
     video: メディアの種類に描画
     unspecified: FaceTimeカメラとiSight(背面)カメラのどちらも設定
     */
    func setupDevice() {
        // カメラデバイスのプロパティ設定
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        // プロパティの条件を満たしたカメラデバイスの取得
        let devices = deviceDiscoverySession.devices
        
        // FaceTimeカメラとiSightカメラそれぞれの管理オブジェクトに代入
        for device in devices {
            if device.position == AVCaptureDevice.Position.back {
                mainCamera = device
            } else if device.position == AVCaptureDevice.Position.front {
                innerCamera = device
            }
        }
        
        // 背面カメラを起動時のカメラとして設定する
        currentDevice = mainCamera
    }
    
    /**
     入出力データの設定。
     deviceInput Outputを取得し、sessionに設定する。
     */
    func setupInputOutput() {
        do {
            // 指定したデバイスを使用するために入力を初期化
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentDevice!)
            // 指定した入力をセッションに追加
            captureSession.addInput(captureDeviceInput)
            // 出力データを受け取るオブジェクトの作成
            photoOutput = AVCapturePhotoOutput()
            // 出力ファイルのフォーマットを指定 jpeg
            photoOutput!.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])], completionHandler: nil)
            captureSession.addOutput(photoOutput!)
        } catch {
            print(error)
        }
    }
    
    /**
     カメラの取得している映像の表示
     
     カメラのプレビューを表示するレイヤの設定
     View ； 実際の描画や画面のイベント処理を行うオブジェクト
     Layer ： Viewに描画する内容を管理するオブジェクト
     
     AVCaptureVideoPreviewLayerクラス ； カメラの取得している映像を画面に表示する
     videoGravityプロパティ ： プレビューレイヤが、カメラからの映像をどのように表示するかを設定
     resizeAspectFill ： 縦横比を維持したまま表示する
     videoOrientationプロパティ ： 表示するプレビューレイヤの向きを指定
     定数AVCaptureVideoOrientation.portrait ： カメラのキャプチャーをそのままの向きで表示するため
     */
    func setupPreviewLayer() {
        // 指定したAVCatureSessionでプレビューレイヤを初期化する
        self.cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        // プレビューレイヤが、カメラのキャプチャーを縦横比を維持した状態で表示するように設定
        self.cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        // プレビューレイヤの表示の向きを設定
        self.cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        
        // レイヤのフレームにビューのフレームを設定
        self.cameraPreviewLayer?.frame = view.frame
        // AVCaptureVideoPreviewLayerオブジェクトをビューのレイヤに追加する
        // -> カメラのキャプチャが画面に表示するように設定
        self.view.layer.insertSublayer(self.cameraPreviewLayer!, at: 0)
    }

    /**
     ボタンのデザイン(スタイル)を作成
     */
    func styleCaptureButton() {
        cameraButton.layer.borderColor = UIColor.white.cgColor
        cameraButton.layer.backgroundColor = UIColor.white.cgColor
        cameraButton.layer.borderWidth = 5
        cameraButton.clipsToBounds = true
        cameraButton.layer.cornerRadius = min(cameraButton.frame.width, cameraButton.frame.height) / 2
    }
}



