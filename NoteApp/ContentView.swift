//
//  ContentView.swift
//  NoteApp
//
//  Created by Corentin Robert on 15/10/2024.
//

import SwiftUI

struct ContentView: View {
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: #keyPath(Note.updateAt), ascending: false)]) var notes: FetchedResults<Note>
    
    @Environment(\.managedObjectContext) var moc
    
    @State private var showingAlert = false
    @State private var noteToDelete: Note?
    
    var body: some View {
        NavigationStack{
            if(notes.isEmpty){
                Spacer()
                VStack{
                    Image(systemName: "note")
                    Text("no_note_yet".localize())
                }
            }
            else{
                List{
                    ForEach(notes){ note in
                        NavigationLink(destination: NoteDetailView(note: note)){
                            Text(note.title!)
                        }
                    }
                    .onDelete(perform: showDeleteAlert)
                }
                .alert(
                    "delete_note".localize(),
                    isPresented: $showingAlert,
                    presenting: noteToDelete)
                { note in
                    Button("delete".localize(), role: .destructive) {
                        delete(note)
                    }
                    Button("cancel".localize(), role: .cancel) {}
                }
                message: { note in
                    Text("sure_delete_note".localize() + " \"\(note.title ?? "this_note".localize())\"?")
                }
            }
            Spacer()
            NavigationLink("add_new_note".localize()){
                AddNewNote()
            }
            .navigationTitle("note_app".localize())
            .toolbar {
                EditButton()
            }
        }
    }
    
    private func showDeleteAlert(at offsets: IndexSet) {
            if let index = offsets.first {
                noteToDelete = notes[index]
                showingAlert = true
            }
        }
    
    func delete(_ note: Note){
        moc.delete(note)
        try? moc.save()
    }
    
}

#Preview {
    ContentView()
}
