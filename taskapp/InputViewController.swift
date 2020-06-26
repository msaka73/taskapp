//
//  InputViewController.swift
//  taskapp
//
//  Created by 坂本充生 on 2020/06/23.
//  Copyright © 2020 michio. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications
class InputViewController: UIViewController {
    
    let realm = try! Realm()
    var task :Task!
//    var saveFlg = false
    
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextField: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        categoryTextField.text = task.category
        titleTextField.text = task.title
        contentsTextField.text = task.contents
        datePicker.date = task.date
        
        //navigationBarの標準戻るボタンの非表示(dataが変更された場合、save確認するため
        navigationItem.hidesBackButton = true
        //navigationBarに戻るボタン設置
        let backButtonItem:UIBarButtonItem =  UIBarButtonItem(customView:self.createBackButton())
        navigationItem.leftBarButtonItem = backButtonItem
        //navigationBarにsaveボタン設置(※今回は設置しない:戻ると同じ処理のため)
//        let saveButtonItem:UIBarButtonItem = UIBarButtonItem(customView: self.createSaveButton())
//        navigationItem.rightBarButtonItem = saveButtonItem
        
        // Do any additional setup after loading the view.
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//            try! realm.write {
//                self.task.category = self.categoryTextField.text!
//                self.task.title = self.titleTextField.text!
//                self.task.contents = self.contentsTextField.text
//                self.task.date = self.datePicker.date
//                self.realm.add(self.task,update: .modified)
//            }
//            setNotification(task:task)
    }
    //navigationControllerの戻るボタン作成
    func createBackButton() -> UIButton {
        let backButton :UIButton = UIButton(type: .system)
        backButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        backButton.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left;     //左寄せ
        backButton.setTitleColor(UIColor.black, for: .normal)
        let iconImage = UIImage(named: "back")
        // オリジナル画像のサイズからアスペクト比を計算
        let aspectScale = iconImage!.size.width / iconImage!.size.height
        // widthからアスペクト比を元にリサイズ後のサイズを取得
        let resizedSize = CGSize(width: 40  * Double(aspectScale), height: 40)
        // リサイズ後のUIImageを生成
        UIGraphicsBeginImageContext(resizedSize)
        iconImage!.draw(in: CGRect(x: 0, y: 0, width: resizedSize.width, height: resizedSize.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        backButton.setImage(resizedImage, for: .normal)
        backButton.addTarget(self, action: #selector(self.onBack(_:)), for: .touchUpInside)
        return backButton
    }
    //戻るボタンを押した時の処理
    @objc func onBack(_ sender: UIButton) {
        print("戻るボタン押されたよ〜")
        var changeFlg = false
        //カテゴリに変化ないか
        if categoryTextField.text != task.category{
            changeFlg = true
        }
        //タイトルに変化ないか
        if titleTextField.text != task.title{
            changeFlg = true
        }
        //内容に変化ないか
        if contentsTextField.text != task.contents{
            changeFlg = true
        }
        //日付に変化ないか
        if datePicker.date != task.date{
            changeFlg = true
        }
        
        //save確認
        if changeFlg == false{
            //戻る
            self.navigationController?.popToRootViewController(animated: true)
            return
        }else{
            //確認メッセージ
            let alert: UIAlertController = UIAlertController(title: "保存しますか?", message:"変更されています", preferredStyle:  UIAlertController.Style.alert)
            //save時
            let saveAction: UIAlertAction = UIAlertAction(title: "保存", style: UIAlertAction.Style.default, handler: {
                //クロージャ実装
                (action : UIAlertAction!) -> Void in
                //database保存
                try! self.realm.write {
                    self.task.category = self.categoryTextField.text!
                    self.task.title = self.titleTextField.text!
                    self.task.contents = self.contentsTextField.text
                    self.task.date = self.datePicker.date
                    self.realm.add(self.task,update: .modified)
                }
                self.setNotification(task:self.task)
                // アラートを生成する。
                let alert: UIAlertController = UIAlertController(title: "保存 完了", message: "", preferredStyle:  UIAlertController.Style.alert)
                let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
                    (actio: UIAlertAction!) -> Void in
                    //戻る
                    self.navigationController?.popToRootViewController(animated: true)
                })

                alert.addAction(defaultAction)
                // アラートを表示する。
                self.present(alert, animated: true, completion: nil)
                
            })
            // キャンセルボタン
            let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:{
                
                // ボタンが押された時の処理を書く（クロージャ実装）
                (action: UIAlertAction!) -> Void in
                //戻る
                self.navigationController?.popToRootViewController(animated: true)
            })
            //action追加
            alert.addAction(cancelAction)
            alert.addAction(saveAction)
            //Alertを表示
            present(alert, animated: true, completion: nil)
        }
        
    }
    
    //navigationControllerのsaveボタン作成
    func createSaveButton() -> UIButton {
        let saveButton :UIButton = UIButton(type: .system)
        saveButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        saveButton.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.right  //右寄せ
        saveButton.setTitleColor(UIColor.black, for: .normal)
        let iconImage = UIImage(named: "save")
        // オリジナル画像のサイズからアスペクト比を計算
        let aspectScale = iconImage!.size.width / iconImage!.size.height
        // widthからアスペクト比を元にリサイズ後のサイズを取得
        let resizedSize = CGSize(width: 40  * Double(aspectScale), height: 40)
        // リサイズ後のUIImageを生成
        UIGraphicsBeginImageContext(resizedSize)
        iconImage!.draw(in: CGRect(x: 0, y: 0, width: resizedSize.width, height: resizedSize.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        saveButton.setImage(resizedImage , for: .normal )
        saveButton.addTarget(self, action: #selector(self.onSave(_:)), for: .touchDragInside)
        return saveButton
    }
    //SAVEボタンを押した時の処理
    @objc func onSave(_ sender: UIButton){
    
    }
    func setNotification(task: Task){
        let content = UNMutableNotificationContent()
        
        if task.title == ""{
            content.title = "(タイトルなし)"
        }else{
            content.title = task.title
        }
        if task.contents == ""{
            content.body = "(内容なし)"
        }else{
            content.body = task.contents
        }
        content.sound = UNNotificationSound.default
        
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month ,.day, .hour,.minute], from: task.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: String(task.id), content: content, trigger: trigger)
        
        let center = UNUserNotificationCenter.current()
        center.add(request){(error) in
            print(error ?? "ローカル通知登録 OK")
        }
        
        center.getPendingNotificationRequests{(requests: [UNNotificationRequest]) in
            for request in requests{
                print("/--------------------")
                print(request)
                print("--------------------/")
            }
        }
    }
    @objc func dismissKeyboard(){
        
        view.endEditing(true)
    }
    
}
