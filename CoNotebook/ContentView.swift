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
    @State private var selectedSorting : String = (UserDefaults.standard.string(forKey: "sortPickerSelected") ?? "none")
    
    var groupedNotes: [String: [Note]] {
        switch selectedSorting {
        case "like":
            // Regrouper par "like"
            let likedNotes = notes.filter { $0.isLike }
            let unlikedNotes = notes.filter { !$0.isLike }
            return ["favorites".localize(): likedNotes, "not_favorites".localize(): unlikedNotes]
        case "date":
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            let sortedNotes = notes.sorted(by: { ($0.createdAt ?? Date()) > ($1.createdAt ?? Date()) })
            return Dictionary(grouping: sortedNotes, by: { dateFormatter.string(from: $0.createdAt ?? Date()) })

        default:
            // Aucun regroupement
            return ["all_notes".localize(): Array(notes)]
        }
    }
    
    var body: some View {
        NavigationStack{
            VStack(alignment: .leading){
                HStack{
                    Text("note_app".localize())
                        .font(.title)
                        .foregroundColor(.black)
                    Spacer()
                    Text("select_sorting_note".localize())
                    Picker("select_sorting_note".localize(),selection:$selectedSorting){
                        Text("none".localize()).tag("none")
                        Text("date".localize()).tag("date")
                        Text("like".localize()).tag("like")
                    }
                    .disabled(notes.isEmpty)
                    .onChange(of: selectedSorting) {
                        UserDefaults.standard.set(selectedSorting, forKey: "sortPickerSelected")
                    }
                    .pickerStyle(.automatic)
                    .foregroundColor(.black)
                }
                .padding(.horizontal, 10)
            }
            if notes.isEmpty {
                Spacer()
                VStack {
                    Image(systemName: "note")
                        .resizable()
                        .frame(width: 50, height: 50)
                    Text("no_note_yet".localize())
                }
            } else {
                List {
                    ForEach(groupedNotes.keys.sorted(by: selectedSorting == "like" ? { $0 < $1 } : { $0 > $1 }), id: \.self) { key in
                        Section(header: Text(key)) {
                            ForEach(groupedNotes[key] ?? []) { note in
                                NavigationLink(destination: NoteDetailView(note: note)) {
                                    VStack(alignment: .leading) {
                                        HStack {
                                            Text(note.title ?? "")
                                                .lineLimit(1)
                                            Spacer()
                                            Button("", systemImage: note.isLike ? "heart.fill" : "heart",action: {
                                            }).onTapGesture {
                                                withAnimation {
                                                    note.isLike.toggle()
                                                }
                                                do {
                                                    try moc.save()
                                                } catch {
                                                    note.isLike.toggle()
                                                    print("Error saving note: \(error.localizedDescription)")
                                                }
                                            }
                                            .foregroundStyle(.red)
                                        }
                                        HStack {
                                            Text(note.content ?? "")
                                                .font(.caption)
                                                .lineLimit(1)
                                                .foregroundStyle(.secondary)
                                            Spacer()
                                            Text(note.createdAt?.formatted(.dateTime) ?? "")
                                                .font(.caption)
                                        }
                                    }
                                }
                                .listRowBackground(backgroundColor(for: note))
                            }
                            .onDelete(perform: showDeleteAlert)
                        }
                    }
                }
                .alert(
                    "delete_note".localize(),
                    isPresented: $showingAlert,
                    presenting: noteToDelete
                ) { note in
                    Button("delete".localize(), role: .destructive) {
                        delete(note)
                    }
                    Button("cancel".localize(), role: .cancel) {}
                } message: { note in
                    Text("sure_delete_note".localize() + " \"\(note.title ?? "this_note".localize())\"?")
                }
            }
            Spacer()
            NavigationLink("add_new_note".localize()) {
                AddNewNote()
            }
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    EditButton()
                        .disabled(notes.isEmpty)
                }
            }
        }
    }
    
    private func backgroundColor(for note: Note) -> Color {
        note.getColor().opacity(0.5)
    }
    
    private func showDeleteAlert(at offsets: IndexSet) {
        if let index = offsets.first {
            noteToDelete = notes[index]
            showingAlert = true
        }
    }
    
    func delete(_ note: Note) {
        moc.delete(note)
        try? moc.save()
    }
}


#Preview {
    let dataController = DataController()
    let context = dataController.container.viewContext
    
    let exampleNote = Note(context: context)
    exampleNote.title = "Exemple de note"
    exampleNote.content = "Ceci est le contenu de la note pour la prévisualisation."
    exampleNote.updateAt = Date()
    
    return ContentView()
        .environment(\.managedObjectContext, context)
}
