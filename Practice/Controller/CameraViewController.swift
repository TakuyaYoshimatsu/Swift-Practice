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
    var screenWidth:CGFloat = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        setPicture()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    //カメラ準備
    
    @IBOutlet weak var CameraView: UIView!
    func setPicture(){

        CameraView.isHidden = false
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
        let pvWidthSize = self.view.frame.width
        let pvHeightSize = self.view.frame.height
        // プレビューレイヤーを生成
        let pvLayer = AVCaptureVideoPreviewLayer(session: session)
        pvLayer.frame = view.bounds
        pvLayer.frame = CGRect(x: 0, y: 0, width: pvWidthSize, height: pvHeightSize)
        //pvLayer.frame = CGRect(x: 0, y: 0, width: 680, height: 480)
        pvLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        CameraView.layer.addSublayer(pvLayer)
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
        initImageView()
    }
    
    var imageView:UIImageView?
    //ガイドライン
    private func initImageView(){
            // UIImage インスタンスの生成
            let image1:UIImage = UIImage(named:"target")!
            // UIImageView 初期化
            imageView = UIImageView(image:image1)
            // スクリーンの縦横サイズを取得
            let screenWidth:CGFloat = view.frame.size.width
            let screenHeight:CGFloat = view.frame.size.height
            // 画像の横サイズを取得
            let imgWidth:CGFloat = image1.size.width
            // 画像サイズをスクリーン幅に合わせる
            let scale:CGFloat = screenWidth / imgWidth
            //プレビュー画面横サイズ
            //Height:ScreenWidthFill = 480:640
            let pvWidthSize = imgWidth * scale
            let pvHeightSize = pvWidthSize * (480 / 640)
            let rect:CGRect =
                CGRect(x:0, y:0, width:pvWidthSize, height:pvHeightSize)
            // ImageView frame をCGRectで作った矩形に合わせる
            imageView?.frame = rect;
            // 画像の中心を画面の中心に設定
            imageView?.center = CGPoint(x:screenWidth/2, y:screenHeight/2)
            // UIImageViewのインスタンスをビューに追加
            self.view.addSubview(imageView!)
    }
    
    //撮影
    @objc func photoshot(_ sender: AnyObject) {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .off
        output.capturePhoto(with: settings, delegate: self)
    }
    
    //撮影結果・再撮影・保存ボタンの表示
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        CameraView.isHidden = true
        if error == nil {
            let outputImageView = UIImageView()
            let screenWidth = view.frame.width
            let screenHeight:CGFloat = view.frame.size.height
            let pvHeightSize = screenWidth * (480 / 640)
            
            outputImageView.frame = CGRect(x: 0, y: 90, width: screenWidth, height: pvHeightSize)
            outputImageView.center = CGPoint(x:screenWidth/2, y:screenHeight/2)
            
            let imageData = photo.fileDataRepresentation()
            let photo = UIImage(data: imageData!)
            
  
            outputImageView.image = photo
            
            tempImage = photo
            
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
extension CGRect {
    /// 反転させたサイズを返す
    var switched: CGRect {
        return CGRect(x: minY, y: minX, width: height, height: width)
    }
}

extension UIImage.Orientation {
    /// 画像が横向きであるか
    var isLandscape: Bool {
        switch self {
        case .up, .down, .upMirrored, .downMirrored:
            return false
        case .left, .right, .leftMirrored, .rightMirrored:
            return true
        }
    }
}

extension UIImage {
    func cropping(to rect: CGRect) -> UIImage? {
        let croppingRect: CGRect = imageOrientation.isLandscape ? rect.switched : rect
        guard let cgImage: CGImage = self.cgImage?.cropping(to: croppingRect) else { return nil }
        let cropped: UIImage = UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)
        return cropped
    }
    
    // resize image
    func reSizeImage(reSize:CGSize)->UIImage {
        //UIGraphicsBeginImageContext(reSize);
        UIGraphicsBeginImageContextWithOptions(reSize,false,UIScreen.main.scale);
        self.draw(in: CGRect(x: 0, y: 0, width: reSize.width, height: reSize.height));
        let reSizeImage:UIImage! = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return reSizeImage;
    }

    // scale the image at rates
    func scaleImage(scaleSize:CGFloat)->UIImage {
        let reSize = CGSize(width: self.size.width * scaleSize, height: self.size.height * scaleSize)
        return reSizeImage(reSize: reSize)
    }
}

extension UIImageView {
    func transformByImage(rect : CGRect) -> CGRect? {
        guard let image = self.image else { return nil }
        let imageSize = image.size
        let imageOrientation = image.imageOrientation
        let selfSize = self.frame.size

        let scaleWidth = imageSize.width / selfSize.width
        let scaleHeight = imageSize.height / selfSize.height

        var transform: CGAffineTransform

        switch imageOrientation {
        case .left:
            transform = CGAffineTransform(rotationAngle: .pi / 2).translatedBy(x: 0, y: -image.size.height)
        case .right:
            transform = CGAffineTransform(rotationAngle: -.pi / 2).translatedBy(x: -image.size.width, y: 0)
        case .down:
            transform = CGAffineTransform(rotationAngle: -.pi).translatedBy(x: -image.size.width, y: -image.size.height)
        default:
            transform = .identity
        }

        transform = transform.scaledBy(x: scaleWidth, y: scaleHeight)

        return rect.applying(transform)
    }
}
