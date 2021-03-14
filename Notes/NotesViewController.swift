//
//  NotesViewController.swift
//  Notes
//
//  Created by Александр Фомичев on 08.03.2021.
//

import UIKit
//import SQLite3

class NotesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var notes: [Note] = []
    private var dbManager: DatabaseManager = DatabaseManager()
    @IBOutlet weak var noteTableView: UITableView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var addNewNoteButton: UIBarButtonItem!
    
    @IBAction func onAddNewNoteButtonClick(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let noteViewController = storyboard.instantiateViewController(identifier: "note")
            as! NoteViewController
        navigationController?.pushViewController(noteViewController, animated: true)
        noteViewController.passNote = { (note: Note) in
            self.navigationController?.popToRootViewController(animated: true)
            //MARK: insert note in db to get note id
            self.dbManager.insert(note: note)
            //MARK: add note with id to notes array
            if let note = self.dbManager.selectLastNote(){
                self.notes.append(note)
            }
            self.noteTableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Notes"
        navigationController?.navigationBar.prefersLargeTitles = true
        showLoading()
        loadNotesFromDatabase()
    }
    
    private func showLoading(){
        activityIndicator.hidesWhenStopped = true
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func loadNotesFromDatabase(){
        DispatchQueue.main.async {
            self.notes = self.dbManager.selectNotes()
            self.activityIndicator.stopAnimating()
            self.noteTableView.reloadData()
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath)
        let note = notes[indexPath.row]
        cell.textLabel?.text = note.text
        cell.detailTextLabel?.text = note.creationOrChangeDate
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let noteViewController = storyboard.instantiateViewController(identifier: "note")
            as! NoteViewController
        navigationController?.pushViewController(noteViewController, animated: true)
        noteViewController.setNote(note: notes[indexPath.row])
        noteViewController.passNote = { (note: Note) in
            self.navigationController?.popToRootViewController(animated: true)
            if let id = self.notes[indexPath.row].id{
                self.dbManager.updateNote(by: id, note: note)
                self.notes[indexPath.row] = Note(id: id, text: note.text, creationOrChangeDate: note.creationOrChangeDate)
                self.noteTableView.reloadData()
            }
        }
    }
    
    //MARK: swipe to delete note
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            if let id = notes[indexPath.row].id{
                dbManager.deleteNote(by: id)
                notes.remove(at: indexPath.row)
                noteTableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }

    
}
