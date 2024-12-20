//
//  AddNewNote.swift
//  NoteApp
//
//  Created by Corentin Robert on 15/10/2024.
//

import SwiftUI
import CoreData
import LocalAuthentication

struct AddNewNote: View {
    
    @State var title : String = ""
    @State var content : String = ""
    @State var createdAt : Date = Date()
    @State var updatedAt : Date = Date()
    @State private var color : Color = .white
    @State private var components: Color.Resolved?
    @State private var isLike: Bool = false
    @State private var isLocked : Bool = false
    
    @Environment(\.self) var environment
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var moc
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Text("add_title_note_here".localize())
                    .fontWeight(.bold)
                TextField("enter_note_here".localize(), text: $title)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding(.horizontal, 10)
            
            VStack(alignment: .leading) {
                Text("add_content_note_here".localize())
                    .fontWeight(.bold)
                TextEditor(text: $content)
                    .autocorrectionDisabled()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .overlay(RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.secondary).opacity(0.5))
            }
            .padding(.horizontal, 10)
            
            ColorPicker("select_note_color".localize(), selection: $color,supportsOpacity: false)
                .padding(.horizontal, 10)
                .fontWeight(.bold)
                .onChange(of: color, initial: true) { components = color.resolve(in: environment) }
            Toggle("favorite_note".localize(), isOn: $isLike)
                .padding(.horizontal, 10)
                .fontWeight(.bold)
            Toggle("locked_a_note".localize(),isOn: $isLocked)
                .padding(.horizontal, 10)
                .fontWeight(.bold)
                .onChange(of: isLocked) { newValue in
                            if newValue {
                                // Demander Face ID lors de l'activation du toggle
                                authenticateWithFaceID()
                            }
                        }
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
                note.isLocked = isLocked
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
    
    func authenticateWithFaceID() {
            let context = LAContext()
            var error: NSError?
            
            // Vérifie si Face ID est disponible
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                let reason = "use_face_id_to_unlock_note".localize()
                
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                    DispatchQueue.main.async {
                        if success {
                            // Si l'authentification réussit, le toggle reste activé
                            isLocked = true
                        } else {
                            // Si l'authentification échoue, le toggle se désactive
                            isLocked = false
                        }
                    }
                }
            } else {
                // Si Face ID n'est pas disponible, désactiver le toggle
                isLocked = false
            }
        }
}

#Preview {
    AddNewNote()
}
