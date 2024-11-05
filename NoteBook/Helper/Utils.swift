//
//  Utils.swift
//  NoteApp
//
//  Created by Corentin Robert on 16/10/2024.
//

import Foundation
import SwiftUICore
extension String {

     func localize(comment: String = "") -> String {
         let defaultLanguage = "en"
         let value = NSLocalizedString(self, comment: comment)
         if value != self || NSLocale.preferredLanguages.first == defaultLanguage {
             return value // String localization was found
         }

                 // Load resource for default language to be used as
         // the fallback language
         guard let path = Bundle.main.path(forResource: defaultLanguage, ofType: "lproj"), let bundle = Bundle(path: path) else {
             return value
         }

         return NSLocalizedString(self, bundle: bundle, comment: "")
    }
}

extension Note {
    func getColor() -> Color {
        Color(
            red: Double(self.colorR),
            green: Double(self.colorG),
            blue: Double(self.colorB),
            opacity: Double(self.colorA)
        )
    }
}

extension Color {
    // Fonction pour obtenir les composants de la couleur
    func rgba() -> (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        let components = self.cgColor?.components ?? [0, 0, 0, 0]
        return (red: components[0], green: components[1], blue: components[2], alpha: components[3])
    }
    
    // Fonction pour comparer deux couleurs
    func isEqual(to color: Color) -> Bool {
        let selfRGBA = self.rgba()
        let otherRGBA = color.rgba()
        
        // Comparer chaque composant
        return selfRGBA.red == otherRGBA.red &&
               selfRGBA.green == otherRGBA.green &&
               selfRGBA.blue == otherRGBA.blue &&
               selfRGBA.alpha == otherRGBA.alpha
    }
}
