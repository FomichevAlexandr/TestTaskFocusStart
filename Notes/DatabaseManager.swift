//
//  DataBaseManager.swift
//  Notes
//
//  Created by Александр Фомичев on 11.03.2021.
//

import Foundation

import SQLite3

class DatabaseManager
{
    
    private let DBFileName: String
    private var database:OpaquePointer?
    private let filePath: String
    
    init()
    {
        DBFileName = "notesDB.sqlite"
        filePath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true)[0].appendingFormat("/" + DBFileName)
        if !isDatabaseFileExist(){
            createDatabaseFile()
            database = openDatabase()
            createTable()
            insertFirstNote()
        }else{
            database = openDatabase()
        }

    }
    
    private func isDatabaseFileExist() -> Bool{
        return FileManager.default.fileExists(atPath: filePath)
    }
    
    private func createDatabaseFile(){
         try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent(DBFileName)
    }
    
    private func openDatabase() -> OpaquePointer?
    {
        var db: OpaquePointer?
        if sqlite3_open(filePath, &db) != SQLITE_OK
        {
            print("error opening database")
            return nil
        }
        else
        {
            print("Successfully opened connection to database at \(filePath)")
            return db
        }
    }
    
    private func createTable() {
        let createTableString = "CREATE TABLE IF NOT EXISTS notes(Id INTEGER PRIMARY KEY,text TEXT,date TEXT);"
        var createTableStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(database, createTableString, -1, &createTableStatement, nil) == SQLITE_OK
        {
            if sqlite3_step(createTableStatement) == SQLITE_DONE
            {
                print("notes table created.")
            } else {
                print("notes table could not be created.")
            }
        } else {
            print("CREATE TABLE statement could not be prepared.")
        }
        sqlite3_finalize(createTableStatement)
    }
    
    private func insertFirstNote(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        self.insert(note: Note(text: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s", creationOrChangeDate: dateFormatter.string(from: Date())))
    }

    func insert(note: Note)
    {
        let insertStatementString = "INSERT INTO notes (text, date) VALUES (?, ?);"
        var insertStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(database, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(insertStatement, 1, (note.text as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 2, (note.creationOrChangeDate as NSString).utf8String, -1, nil)
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("Successfully inserted row.")
            } else {
                print("Could not insert row.")
            }
        } else {
            print("INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)
    }

    // MARK: function is used to retrieve id note from database
    func selectLastNote() -> Note?{
        let queryStatementString = "SELECT * FROM notes ORDER BY id DESC LIMIT 1;"
        var queryStatement: OpaquePointer? = nil
        var note: Note?
        if sqlite3_prepare_v2(database, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = sqlite3_column_int(queryStatement, 0)
                let text = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
                let date = String(describing: String(cString: sqlite3_column_text(queryStatement, 2)))
                note = Note(id: Int(id), text: text, creationOrChangeDate: date)
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        sqlite3_finalize(queryStatement)
        return note
    }
    
    func selectNotes() -> [Note]{
        let queryStatementString = "SELECT * FROM notes;"
        var queryStatement: OpaquePointer? = nil
        var notes: [Note] = []
        if sqlite3_prepare_v2(database, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = sqlite3_column_int(queryStatement, 0)
                let text = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
                let date = String(describing: String(cString: sqlite3_column_text(queryStatement, 2)))
                notes.append(Note(id: Int(id), text: text, creationOrChangeDate: date))
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        sqlite3_finalize(queryStatement)
        return notes
    }

    func deleteNote(by id:Int) {
        let deleteStatementStirng = "DELETE FROM notes WHERE Id = ?;"
        var deleteStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(database, deleteStatementStirng, -1, &deleteStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(deleteStatement, 1, Int32(id))
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                print("Successfully deleted row.")
            } else {
                print("Could not delete row.")
            }
        } else {
            print("DELETE statement could not be prepared")
        }
        sqlite3_finalize(deleteStatement)
    }
    
    func updateNote(by id:Int, note: Note){
        let updateStatementStirng = "UPDATE notes SET text = ?, date = ? WHERE id = ?;"
        var updateStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(database, updateStatementStirng, -1, &updateStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(updateStatement, 1, (note.text as NSString).utf8String, -1, nil)
            sqlite3_bind_text(updateStatement, 2, (note.creationOrChangeDate as NSString).utf8String, -1, nil)
            print(id)
            sqlite3_bind_int(updateStatement, 3, Int32(id))
            
            if sqlite3_step(updateStatement) == SQLITE_DONE {
                print("Successfully updated row.")
            } else {
                print("Could not update row.")
            }
        } else {
            print("UPDATE statement could not be prepared")
        }
        sqlite3_finalize(updateStatement)
        
    }

}
