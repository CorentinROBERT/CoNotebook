//
//  NoteDetailView.swift
//  NoteApp
//
//  Created by Corentin Robert on 15/10/2024.
//

import SwiftUI

struct NoteDetailView: View {
    
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) var dismiss
    
    var note : Note
    @State var isAlertPresented = false
    @State var isModificationMode = false
    @State private var editTitle: String = ""
    @State private var editText: String = ""
    
    init (note: Note) {
        self.editTitle = note.title ?? ""
        self.editText = note.content ?? ""
        self.note = note
    }
    
    var body: some View {
        VStack {
            if(isModificationMode){
                TextField("enter_title".localize(), text: $editTitle)
                    .font(.title)
                    .padding(.leading , 10)
                TextEditor(text: $editText)
                    .padding(.leading , 10)
            }
            else{
                Text(note.content!)
                    .frame(maxWidth: .infinity,alignment: .leading)
                    .padding(.leading , 10)
            }
            
            Spacer()
            if(isModificationMode){
                Button("validate".localize()){
                    note.title = editTitle
                    note.content = editText
                    note.updateAt = Date()
                    do {
                        try moc.save()
                    } catch {
                        print("Error saving note: \(error.localizedDescription)")
                    }
                    modifyNote()
                }
                .disabled(editTitle.isEmpty || editText.isEmpty)
            }
            else{
                Button(action: {
                   isAlertPresented.toggle()
                }) {
                    Text("delete".localize())
                        .foregroundStyle(.red)
                }
                .alert(isPresented: $isAlertPresented) {
                    Alert(
                        title: Text("sure_delete_this_note".localize()),
                        message: Text("note_will_delete_permanently".localize()),
                        primaryButton: .destructive(Text("delete".localize())) {
                            self.moc.delete(self.note)
                            self.dismiss()
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
            
        }
        .navigationTitle(isModificationMode ? "" : note.title!)
        .toolbar {
            if(!isModificationMode){
                Button(action: modifyNote) {
                    Image(systemName: "square.and.pencil")
                }
            }
            else{
                Button("cancel".localize()){
                    modifyNote()
                }
            }
        }
    }
    
    func modifyNote() {
        self.isModificationMode.toggle()
    }
}
