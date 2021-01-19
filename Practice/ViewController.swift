//
//  ViewController.swift
//  Practice
//
//  Created by 吉松拓哉 on 2021/01/12.
//

import UIKit
//import RxSwift

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var TestTextField: UITextField!
    @IBOutlet weak var TestLabel: UILabel!
    var testText:String = "default"
    // UserDefaults のインスタンス
    let userDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // textFiel の情報を受け取るための delegate を設定
        TestTextField.delegate = self
         
        // デフォルト値
        userDefaults.register(defaults: ["DataStore": "default"])
         
        TestLabel.text = readData()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) ->Bool{
     
        testText = textField.text!
     
        TestLabel.text = testText
     
        // キーボードを閉じる
        textField.resignFirstResponder()
     
        saveData(str: testText)
     
        return true
    }
     
    func saveData(str: String){
     
        // Keyを指定して保存
        userDefaults.set(str, forKey: "DataStore")
    }
     
    func readData() -> String {
        // Keyを指定して読み込み
        let str: String = userDefaults.object(forKey: "DataStore") as! String
     
        return str
    }
     
     
    @IBAction func buttonTapped(_ sender: Any) {
        // Key の値を削除
        userDefaults.removeObject(forKey: "DataStore")
         
        // Keyを指定して読み込み
        let str: String = userDefaults.object(forKey: "DataStore") as! String
         
        TestLabel.text = str
    }
    
    @IBAction func nextButton(_ sender: Any) {
        performSegue(withIdentifier: "nextScreen", sender: nil)
    }
    
    //segueが動作することをViewControllerに通知するメソッド
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        // segueのIDを確認して特定のsegueのときのみ動作させる
        if segue.identifier == "nextScreen" {
            let next = segue.destination as? SelectViewController
            next?.outputValue = self.TestTextField.text
        }
    }
}

