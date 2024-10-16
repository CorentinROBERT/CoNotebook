//
//  AddNewNote.swift
//  NoteApp
//
//  Created by Corentin Robert on 15/10/2024.
//

import SwiftUI
import CoreData

struct AddNewNote: View {
    
    @State var title : String = ""
    @State var content : String = ""
    @State var createdAt : Date = Date()
    @State var updatedAt : Date = Date()
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var moc
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Text("add_title_note_here".localize())
                TextField("enter_note_here".localize(), text: $title)
            }.padding()
            VStack(alignment: .leading) {
                Text("add_content_note_here".localize())
                TextField("enter_note_content_here".localize(), text: $content)
            }.padding()
            Spacer()
            Button("add_note".localize()) {
                let note = Note(context: moc)
                note.id = UUID()
                note.title = title
                note.content = content
                note.createdAt = Date()
                note.updateAt = Date()
                note.isRead = false
                do {
                    try moc.save()
                    dismiss()
                } catch {
                    print("Error saving note: \(error.localizedDescription)")
                }
            }
            .padding(10)
            .background(Color.blue)
            .foregroundStyle(.white)
            .cornerRadius(5)
            .navigationTitle("new_note".localize())
        }
    }
}

#Preview {
    AddNewNote()
}
