//
//  NoteViewController.swift
//  Notes
//
//  Created by Александр Фомичев on 08.03.2021.
//

import UIKit

class NoteViewController: UIViewController {

    @IBOutlet weak var noteTextView: UITextView!

    public var passNote: ((Note) -> Void)?
    private var note: Note?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(onDoneButtonClick))
        noteTextView.text = note?.text
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(specifyContentInset), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(specifyContentInset), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        }
    
    @objc private func onDoneButtonClick(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        passNote?(Note(text: noteTextView.text, creationOrChangeDate: dateFormatter.string(from: Date())))
    }
    
    public func setNote(note: Note) -> Void{
        self.note = note
    }
    
    // MARK: This function is responsible for specifying contentInset
    @objc private func specifyContentInset(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardViewEndFrame = view.convert(keyboardValue.cgRectValue, from: view.window)

        if notification.name == UIResponder.keyboardWillHideNotification {
            noteTextView.contentInset = .zero
        } else {
            noteTextView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        noteTextView.scrollIndicatorInsets = noteTextView.contentInset

    }


}
