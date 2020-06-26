//
//  ViewController.swift
//  taskapp
//
//  Created by 坂本充生 on 2020/06/23.
//  Copyright © 2020 michio. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    //realmインスタンスを取得
    let realm = try! Realm()
    
    //DB内のタスクが格納されるリスト
    //日付の近い順でソート：昇順
    //以降内容をアップデートするとリスト内は自動的に更新される
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date",ascending: true)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        //searchBarの設定
        
        searchBar.placeholder = "カテゴリを入力してください"
        print("内容確認：\n\(taskArray)")
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        //tableViewの空白部の罫線削除
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    //segueで画面遷移
    override func prepare(for segue: UIStoryboardSegue,sender: Any?){
        let inputViewController:InputViewController = segue.destination as! InputViewController
        
        if segue.identifier == "cellSegue"{
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        }else{
            let task = Task()
            let allTasks = realm.objects(Task.self)
            if allTasks.count != 0{
                task.id = allTasks.max(ofProperty: "id")! + 1
            }
            inputViewController.task = task
        }
    }
    
    //テキストが変更されるごとに呼び出し
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //キャンセルボタン表示
        searchBar.showsCancelButton = true
        //検索
        if searchText != "" {
            let searchWord = "category CONTAINS '\(searchText)'"
            print(searchWord)
            taskArray = realm.objects(Task.self).filter(searchWord)
            tableView.reloadData()
        }else{  //ワードがない場合は全て表示
            taskArray = realm.objects(Task.self)
            tableView.reloadData()
        }
    }
    //searchBarのキャンセルボタン処理
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.showsCancelButton = false
        taskArray = realm.objects(Task.self)
        tableView.reloadData()
    }
    
    //データの個数を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count
    }
    //セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.title
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let dateString: String = formatter.string(from: task.date)
        cell.detailTextLabel?.text = dateString
        
        
        return cell
    }
    //セルが選択された時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue", sender: nil)
    }
    //セルが削除可能感ことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    //delete ぼたんが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            //
            print("Delete実行")
            //削除するタスクを取得する
            let task = self.taskArray[indexPath.row]
            
            //ローカル通知キャンセル
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            
            
            try! realm.write {
//                self.realm.delete(self.taskArray[indexPath.row])
//                tableView.deleteRows(at: [indexPath], with: .fade  )
                self.realm.delete(task)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            //未通知のローカル通知一覧をログ出力
            center.getPendingNotificationRequests{(requests: [UNNotificationRequest]) in
                for request in requests{
                    print("/-----------------")
                    print(request)
                    print("-----------------/")
                }
            }
        }
        
    }
    
}

