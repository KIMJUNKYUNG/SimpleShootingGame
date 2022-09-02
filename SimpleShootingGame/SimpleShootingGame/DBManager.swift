//
//  DBManager.swift
//  HelloGame
//
//  Created by 김준경 on 2022/04/27.
//

import Foundation
import SQLite3

var db:OpaquePointer?
let TABLE_NAME : String = "HelloGameTable"

func createTable(){
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("DSDatabase.sqlite")
        
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("table not exsist")
        }
        
        let CREATE_QUERY_TEXT : String = "CREATE TABLE IF NOT EXISTS \(TABLE_NAME) (id INTEGER PRIMARY KEY AUTOINCREMENT, data TEXT)"

        print(CREATE_QUERY_TEXT)
        if sqlite3_exec(db, CREATE_QUERY_TEXT, nil, nil, nil) != SQLITE_OK {
            let errMsg = String(cString:sqlite3_errmsg(db))
            print("db table create error : \(errMsg)")
        }else{
            print("CREATE TABLE GOOD!")
        }
    }

func insert(_ data : String ){
        var stmt : OpaquePointer?
        
        let INSERT_QUERY_TEXT : String = "INSERT INTO \(TABLE_NAME) (data) Values (?)"

        if sqlite3_prepare(db, INSERT_QUERY_TEXT, -1, &stmt, nil) != SQLITE_OK {
            let errMsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert:v1 \(errMsg)")
            return
        }
        
        let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

        if sqlite3_bind_text(stmt, 1, data, -1, SQLITE_TRANSIENT) != SQLITE_OK{
            let errMsg = String(cString : sqlite3_errmsg(db)!)
            print("failture binding name: \(errMsg)")
            return
        }
        
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errMsg = String(cString : sqlite3_errmsg(db)!)
            print("insert fail :: \(errMsg)")
            return
        }else{
            
            print("INSERT GOOD!")
        }
    }

func selectValue(_ index : Int32) -> String?{
        
    let SELECT_QUERY = "SELECT * FROM \(TABLE_NAME) WHERE Id = ?;"
    var stmt:OpaquePointer?
    
    
    if sqlite3_prepare(db, SELECT_QUERY, -1, &stmt, nil) != SQLITE_OK{
        let errMsg = String(cString: sqlite3_errmsg(db)!)
        print("error preparing insert: v1\(errMsg)")
        return nil
    }
    
    guard sqlite3_bind_int(stmt, 1, index) == SQLITE_OK else {
      return nil
    }
        
    guard sqlite3_step(stmt) == SQLITE_ROW else{
            return nil
    }
    
    let id = sqlite3_column_int(stmt, 0)
    let data = String(cString: sqlite3_column_text(stmt, 1))
    
    sqlite3_finalize(stmt)
    
    return data
    }

func updateTable(_ index : String, _ data : String){
    let UPDATE_QUERY = "UPDATE \(TABLE_NAME) SET data= \(data) WHERE id = \(index);"
    var stmt:OpaquePointer?
    
    if sqlite3_prepare(db, UPDATE_QUERY, -1, &stmt, nil) != SQLITE_OK{
        let errMsg = String(cString: sqlite3_errmsg(db)!)
        print("error preparing update: v1\(errMsg)")
        return
    }
    
    if sqlite3_step(stmt) != SQLITE_DONE {
        let errMsg = String(cString : sqlite3_errmsg(db)!)
        print("update fail :: \(errMsg)")
        return
    }
    
    sqlite3_finalize(stmt)
    print("update success")
           
}
