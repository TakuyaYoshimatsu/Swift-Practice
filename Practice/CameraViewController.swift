//
//  CameraViewController.swift
//  Practice
//
//  Created by 吉松拓哉 on 2021/01/19.
//
import UIKit
import AVFoundation

class CameraViewController: UIViewController,AVCapturePhotoCaptureDelegate {
    var device: AVCaptureDevice!
    var session: AVCaptureSession!
    var output: AVCapturePhotoOutput!
    var tempImage:UIImage!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setPicture()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //カメラ準備
    func setPicture(){
        //セッションを生成
        session = AVCaptureSession()
        //背面カメラを選択
        device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        //背面カメラからキャプチャ入力生成
        guard let input = try? AVCaptureDeviceInput(device: device) else {
            print("例外発生")
            return
        }
        session.addInput(input)
        output = AVCapturePhotoOutput()
        session.addOutput(output)
        session.sessionPreset = .photo
        // プレビューレイヤーを生成
        let pvSize = self.view.frame.width
        let pvLayer = AVCaptureVideoPreviewLayer(session: session)
        pvLayer.frame = view.bounds
        //pvLayer.frame = CGRect(x: 0, y: 90, width: pvSize, height: pvSize)
        pvLayer.frame = CGRect(x: 0, y: 90, width: 640, height: 480)
        pvLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        view.layer.addSublayer(pvLayer)
        // セッションを開始
        session.startRunning()
        // 撮影ボタンを生成
        let shutterBtn = UIButton()
        shutterBtn.setTitle("◯", for: .normal)
        shutterBtn.titleLabel?.font = UIFont.systemFont(ofSize: 74)
        shutterBtn.contentMode = .center
        shutterBtn.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        shutterBtn.layer.cornerRadius = 0.5 * shutterBtn.bounds.size.width
        shutterBtn.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        shutterBtn.setTitleColor(UIColor.black, for: UIControl.State())
        shutterBtn.layer.position = CGPoint(x: view.frame.width / 2, y: self.view.bounds.size.height - 80)
        shutterBtn.addTarget(self, action: #selector(photoshot), for: .touchUpInside)
        view.addSubview(shutterBtn)
        //キャンセルボタンを生成
        let cancelBtn = UIButton()
        cancelBtn.setTitle("×", for: .normal)
        cancelBtn.titleLabel?.font = UIFont.systemFont(ofSize: 32)
        cancelBtn.contentMode = .center
        cancelBtn.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        cancelBtn.setTitleColor(UIColor.white, for: UIControl.State())
        cancelBtn.layer.position = CGPoint(x: 20, y: 40)
        cancelBtn.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        view.addSubview(cancelBtn)
    }
    //撮影
    @objc func photoshot(_ sender: AnyObject) {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .off
        settings.isAutoStillImageStabilizationEnabled = true
        output.capturePhoto(with: settings, delegate: self)
    }
    //撮影結果・再撮影・保存ボタンの表示
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if error == nil {
            let outputImageView = UIImageView()
            let pvSize = self.view.frame.width
            //outputImageView.frame = CGRect(x: 0, y: 90, width: pvSize, height: pvSize)
            outputImageView.frame = CGRect(x: 0, y: 90, width: 640, height: 480)
            outputImageView.image = UIImage(data: photo.fileDataRepresentation()!)?.croppingToCenterSquare()
            tempImage = UIImage(data: photo.fileDataRepresentation()!)?.croppingToCenterSquare()
            self.view.addSubview(outputImageView)
            session.stopRunning()
            //再撮影ボタン
            let retryBtn = UIButton()
            retryBtn.setTitle("再撮影", for:.normal)
            retryBtn.frame = CGRect(x:self.view.frame.width/2 - 150,y:self.view.frame.height - 115,width: 70,height: 70)
            retryBtn.addTarget(self, action: #selector(retryPhoto), for: .touchUpInside)
            view.addSubview(retryBtn)
            //保存ボタン
            let saveBtn = UIButton()
            saveBtn.setTitle("保存", for: .normal)
            saveBtn.frame = CGRect(x:self.view.frame.width/2 + 80,y:self.view.frame.height - 115,width: 70,height: 70)
            saveBtn.addTarget(self, action: #selector(savePhoto), for: .touchUpInside)
            view.addSubview(saveBtn)
        }
    }
    //再撮影
    @objc func retryPhoto(sender:UIButton){
        let subViews = view.subviews
        for subView in subViews {
            subView.removeFromSuperview()
        }
        setPicture()
    }
    //カメラロールへの保存
    @objc func savePhoto(sender:UIButton){
        UIImageWriteToSavedPhotosAlbum(tempImage, self, nil, nil)
        let subViews = view.subviews
        for subView in subViews {
            subView.removeFromSuperview()
        }
        setPicture()
    }
    //キャンセル
    @objc func cancelAction(sender:UIButton){
        //
    }
}

extension UIImage {
    func croppingToCenterSquare() -> UIImage {
        let cgImage = self.cgImage!
        var newWidth = CGFloat(cgImage.width)
        var newHeight = CGFloat(cgImage.height)
        if newWidth > newHeight {
            newWidth = newHeight
        } else {
            newHeight = newWidth
        }
        let x = (CGFloat(cgImage.width) - newWidth)/2
        let y = (CGFloat(cgImage.height) - newHeight)/2
        let rect = CGRect(x: x, y: y, width: newWidth, height: newHeight)
        let croppedCGImage = cgImage.cropping(to: rect)!
        return UIImage(cgImage: croppedCGImage, scale: self.scale, orientation: self.imageOrientation)
    }
}


