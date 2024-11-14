//
//  NoteDetailView.swift
//  NoteApp
//
//  Created by Corentin Robert on 15/10/2024.
//

import SwiftUI
import CoreData
import LocalAuthentication

struct NoteDetailView: View {
    
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) var dismiss
    @Environment(\.self) var environment
    
    @State private var color : Color = .white
    @State private var components: Color.Resolved?
    
    var note : Note
    @State var isAlertPresented = false
    
    @State private var editTitle: String = ""
    @State private var editText: String = ""
    @State private var isLike: Bool = false
    @State private var isLocked: Bool = false
    @State private var isScreenLocked: Bool = false
    @State private var showingAlert: Bool = false
    
    
    init (note: Note) {
        self.editTitle = note.title ?? ""
        self.editText = note.content ?? ""
        self.note = note
    }
    
    var body: some View {
        VStack {
            HStack{
                TextField("enter_title".localize(), text: $editTitle)
                    .font(.title)
                Button(action: {
                    withAnimation {
                        if(isLocked){
                            Task{
                                if(await authenticateWithFaceID()){
                                    isLocked.toggle()
                                    note.isLocked = isLocked
                                }
                                else{
                                    dismiss()
                                }
                            }
                        }
                        else {
                            isLocked.toggle()
                            note.isLocked = isLocked
                        }
                    }
                    do {
                        try moc.save()
                    } catch {
                        print("Error saving note: \(error.localizedDescription)")
                    }
                }){
                    Image(systemName: isLocked ? "lock.fill" : "lock.open.fill")
                        .font(.title)
                }
                .foregroundStyle(.gray)
                ColorPicker("",selection: $color,supportsOpacity: false)
                    .onChange(of: color, initial: true) { components = color.resolve(in: environment) }
                    .labelsHidden()
                Spacer()
                Button(action: {
                    withAnimation {
                        isLike.toggle()
                    }
                    do {
                        note.isLike = isLike
                        try moc.save()
                    } catch {
                        print("Error saving note: \(error.localizedDescription)")
                    }
                }){
                    Image(systemName: isLike ? "heart.fill" : "heart")
                        .font(.title)
                }
                .foregroundStyle(.red)
            }
            .padding(.horizontal , 10)
            TextEditor(text: $editText)
                .textEditorStyle(.plain)
                .autocorrectionDisabled()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .overlay(RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.secondary).opacity(0.5))
                .padding()
            Spacer()
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
            }
            .disabled(editTitle.isEmpty || editText.isEmpty)
        }
        .onAppear {
            color = note.getColor()
            self.isLocked = note.isLocked
            self.isLike = note.isLike
            self.isScreenLocked = note.isLocked
            if(note.isLocked){
                Task {
                    let authenticated = await authenticateWithFaceID()
                    if authenticated {
                        isScreenLocked = false
                    } else {
                        dismiss()
                    }
                }
            }
        }
        .toolbar {
            Button(action: displayDeleteAction) {
                Image(systemName: "trash")
                    .foregroundStyle(.red)
            }.disabled(isScreenLocked)
        }
        .alert(
            "delete_note".localize(),
            isPresented: $showingAlert,
            presenting: note
        ) { note in
            Button("delete".localize(), role: .destructive) {
                deleteNote()
                dismiss()
            }
            Button("cancel".localize(), role: .cancel) {}
        } message: { note in
            Text("sure_delete_note".localize() + " \"\(note.title ?? "this_note".localize())\"?")
        }
        .blur(radius: isScreenLocked ? 10 : 0)
    }
    
    func displayDeleteAction(){
        showingAlert.toggle()
    }
    
    func deleteNote() {
        moc.delete(note)
        try? moc.save()
    }
    
    func authenticateWithFaceID() async -> Bool {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return false
        }
        let reason = "use_face_id_to_unlock_note".localize()
        do {
            let success = try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)
            return success
        } catch {
            return false
        }
    }
}

#Preview {
    let dataController = DataController()
    let context = dataController.container.viewContext
    
    let exampleNote = Note(context: context)
    exampleNote.title = "Exemple de note"
    exampleNote.content = "Ceci est le contenu de la note pour la prévisualisation."
    exampleNote.isLocked = false
    exampleNote.updateAt = Date()
    
    return NoteDetailView(note: exampleNote)
        .environment(\.managedObjectContext, context)
}
