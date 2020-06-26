//
//  Task.swift
//  taskapp
//
//  Created by 坂本充生 on 2020/06/23.
//  Copyright © 2020 michio. All rights reserved.
//

import RealmSwift

class Task: Object{
    //管理用ID，プライマリーキー
    @objc dynamic var id = 0
    //カテゴリ
    @objc dynamic var category = ""
    //タイトル
    @objc dynamic var title = ""
    //内容
    @objc dynamic var contents = ""
    //日時
    @objc dynamic var date = Date()
    //idをプライマリーキーとして設定
    override static func primaryKey() -> String?{
        return "id"
    }
}
