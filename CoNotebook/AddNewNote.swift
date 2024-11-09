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
    @State private var color : Color = .white
    @State private var components: Color.Resolved?
    @State private var isLike: Bool = false
    
    @Environment(\.self) var environment
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var moc
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Text("add_title_note_here".localize())
                    .fontWeight(.bold)
                TextField("enter_note_here".localize(), text: $title)
            }
            .padding(.horizontal, 10)
            
            VStack(alignment: .leading) {
                Text("add_content_note_here".localize())
                    .fontWeight(.bold)
                TextField("enter_note_content_here".localize(), text: $content)
            }
            .padding(.horizontal, 10)
            
            ColorPicker("select_note_color".localize(), selection: $color,supportsOpacity: false)
                .padding(.horizontal, 10)
                .fontWeight(.bold)
                .onChange(of: color, initial: true) { components = color.resolve(in: environment) }
            Toggle("favorite_note".localize(), isOn: $isLike)
                .padding(.horizontal, 10)
                .fontWeight(.bold)
            Spacer()
            Button("add_note".localize()) {
                let note = Note(context: moc)
                note.id = UUID()
                note.title = title
                note.content = content
                note.createdAt = Date()
                note.updateAt = Date()
                note.colorR = components?.red ?? 0
                note.colorG = components?.green ?? 0
                note.colorB = components?.blue ?? 0
                note.colorA = components?.opacity ?? 1
                note.isLike = isLike
                do {
                    try moc.save()
                    dismiss()
                } catch {
                    print("Error saving note: \(error.localizedDescription)")
                }
            }
            .padding(10)
            .background((title.isEmpty || content.isEmpty) ? .gray : Color.blue)
            .foregroundStyle(.white)
            .cornerRadius(5)
            .navigationTitle("new_note".localize())
            .disabled(title.isEmpty || content.isEmpty)
        }
    }
}

#Preview {
    AddNewNote()
}
