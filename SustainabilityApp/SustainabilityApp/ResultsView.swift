//
//  ResultsView.swift
//  SustainabilityApp
//
//  Created by Shashwath Dinesh on 4/13/25.
//

import SwiftUI

struct ResultsView: View {
    let predictions: [String]
    let suggestions: [String]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Loop through the predictions and suggestions and display them
                ForEach(Array(zip(predictions, suggestions)), id: \.0) { item, suggestion in
                    VStack(alignment: .leading) {
                        Text("🧠 \(item)")
                            .font(.headline)
                            .bold()
                        Text("💡 \(suggestion)")
                            .font(.body)
                            .padding(.leading, 8)
                            .padding(.bottom, 16)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Gemini's Response")
    }
}



//#Preview {
//    ResultsView()
//}
