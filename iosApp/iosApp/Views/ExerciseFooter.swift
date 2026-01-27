//
//  ExerciseFooter.swift
//  iosApp
//
//  Created by Michael Jaufmann on 27.01.26.
//


import SwiftUI

struct ExerciseFooter: View {
    let petrolColor = Color(red: 0.2, green: 0.45, blue: 0.55)
    var action: () -> Void // Die Funktion, die beim Klicken ausgeführt wird

    var body: some View {
        HStack {
            Spacer() // Schiebt den Button nach rechts [cite: 88, 118]
            
            Button(action: action) {
                HStack(spacing: 4) {
                    Text("Überspringen")
                    Image(systemName: "chevron.right")
                }
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(petrolColor) // Nutzt deine Petrol-Farbe [cite: 88]
            }
        }
        .padding(.horizontal, 25)
        .padding(.bottom, 40) // Abstand zum unteren Bildschirmrand 
    }
}