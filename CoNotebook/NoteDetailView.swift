//
//  NoteDetailView.swift
//  NoteApp
//
//  Created by Corentin Robert on 15/10/2024.
//

import SwiftUI
import CoreData

struct NoteDetailView: View {
    
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) var dismiss
    @Environment(\.self) var environment
    
    @State private var color : Color = .white
    @State private var components: Color.Resolved?
    
    var note : Note
    @State var isAlertPresented = false
    @State var isModificationMode = false
    @State private var editTitle: String = ""
    @State private var editText: String = ""
    @State private var isLike: Bool = false
    
    init (note: Note) {
        self.editTitle = note.title ?? ""
        self.editText = note.content ?? ""
        self.note = note
    }
    
    var body: some View {
        VStack {
            if(isModificationMode){
                HStack{
                    TextField("enter_title".localize(), text: $editTitle)
                        .font(.title)
                    ColorPicker("",selection: $color,supportsOpacity: false)
                        .onChange(of: color, initial: true) { components = color.resolve(in: environment) }
                        .labelsHidden()
                    Spacer()
                    Button("", systemImage: isLike ? "heart.fill" : "heart",action: {
                        withAnimation {
                            isLike.toggle()
                        }
                        do {
                            note.isLike = isLike
                            try moc.save()
                        } catch {
                            print("Error saving note: \(error.localizedDescription)")
                        }
                    })
                    .foregroundStyle(.red)
                }
                .padding(.horizontal , 10)
                TextEditor(text: $editText)
                    .padding(.leading , 10)
                    .textEditorStyle(.plain)
            }
            else{
                HStack{
                    Text(note.title!)
                        .font(.title)
                    Circle()
                        .stroke(Color.black, lineWidth: 1)
                        .fill(note.getColor())
                        .frame(width: 30, height: 30)
                    Spacer()
                    Button("", systemImage: isLike ? "heart.fill" : "heart",action: {
                        withAnimation{
                            isLike.toggle()
                        }
                        do {
                            note.isLike = isLike
                            try moc.save()
                        } catch {
                            print("Error saving note: \(error.localizedDescription)")
                        }
                    })
                    .foregroundStyle(.red)
                }
                .frame(maxWidth: .infinity,alignment: .leading)
                .padding(.horizontal , 10)
                ScrollView{
                    Text(note.content!)
                        .frame(maxWidth: .infinity,alignment: .leading)
                        .padding(.leading , 15)
                        .padding(.top , 2)
                }
                
            }
            
            Spacer()
            if(isModificationMode){
                Button("validate".localize()){
                    note.title = editTitle
                    note.content = editText
                    note.colorR = components?.red ?? 0
                    note.colorG = components?.green ?? 0
                    note.colorB = components?.blue ?? 0
                    note.colorA = components?.opacity ?? 1
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
        .onAppear {
            color = note.getColor()
            self.isLike = note.isLike
        }
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

#Preview {
    let dataController = DataController()
    let context = dataController.container.viewContext
    
    let exampleNote = Note(context: context)
    exampleNote.title = "Exemple de note"
    exampleNote.content = "Ceci est le contenu de la note pour la prévisualisation."
    exampleNote.updateAt = Date()
    
    return NoteDetailView(note: exampleNote)
        .environment(\.managedObjectContext, context)
}
