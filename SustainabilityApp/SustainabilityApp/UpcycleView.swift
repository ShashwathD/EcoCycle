//
//  UpcycleView.swift
//  SustainabilityApp
//
//  Created by Shashwath Dinesh on 4/13/25.
//

import SwiftUI
import Vision
import CoreML
import Foundation

struct UpcycleView: View {
    @State private var image: UIImage?
    @State private var showCamera = false
    @State private var predictions: [String] = []
    @State private var suggestion: String = ""
    @State private var isLoading = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 250)
                        .cornerRadius(12)
                }

                if isLoading {
                    ProgressView("Analyzing image...")
                } else if !suggestion.isEmpty {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("🧠 Detected Items:")
                                .font(.headline)
                            ForEach(predictions, id: \.self) { item in
                                Text("• \(item)")
                            }

                            Divider().padding(.vertical, 8)

                            Text("💡 Upcycling Suggestions:")
                                .font(.headline)
                            Text(suggestion)
                                .padding(.top, 4)
                        }
                        .padding()
                    }
                } else {
                    Button("Take Photo") {
                        showCamera = true
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .sheet(isPresented: $showCamera) {
                Camera2View { selectedImage in
                    self.image = selectedImage
                    analyzeImage(selectedImage)
                }
            }
            .padding()
            .navigationTitle("Upcycle Finder")
        }
    }

    func analyzeImage(_ uiImage: UIImage) {
        isLoading = true
        predictions = []
        suggestion = ""

        guard let cgImage = uiImage.cgImage else { return }

        let config = MLModelConfiguration()
        guard let model = try? VNCoreMLModel(for: UpcycleModel(configuration: config).model) else { return }

        let request = VNCoreMLRequest(model: model) { request, _ in
            let results = request.results as? [VNClassificationObservation] ?? []
            let allResults = results.filter { $0.confidence > 0.3 }
            let identifiers = allResults.map { $0.identifier }
            predictions = identifiers
            fetchUpcyclingIdeas(for: identifiers)
        }

        let handler = VNImageRequestHandler(cgImage: cgImage)
        try? handler.perform([request])
    }

    func fetchUpcyclingIdeas(for items: [String]) {
        let objectList = items.joined(separator: ", ")
        let prompt = """
        You are an expert in sustainable living. I've scanned an image that contains the following objects: \(objectList).

        Please provide creative and practical upcycling ideas for these items, explained in a clear and friendly way.
        """

        Task {
            if let response = await callGeminiAPI(prompt: prompt) {
                suggestion = response
            } else {
                suggestion = "Sorry, I couldn't generate suggestions for those items."
            }
            isLoading = false
        }
    }

    func callGeminiAPI(prompt: String) async -> String? {
        let endpoint = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=API-KEY"

        let requestPayload: [String: Any] = [
            "contents": [
                ["parts": [["text": prompt]]]
            ]
        ]

        guard let url = URL(string: endpoint),
              let data = try? JSONSerialization.data(withJSONObject: requestPayload) else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = data

        do {
            let (responseData, _) = try await URLSession.shared.data(for: request)

            print("RAW RESPONSE: \(String(data: responseData, encoding: .utf8) ?? "No data")")

            if let json = try JSONSerialization.jsonObject(with: responseData) as? [String: Any],
               let candidates = json["candidates"] as? [[String: Any]],
               let content = candidates.first?["content"] as? [String: Any],
               let parts = content["parts"] as? [[String: Any]],
               let text = parts.first?["text"] as? String {
                return text
            }
        } catch {
            print("Gemini API error: \(error.localizedDescription)")
        }

        return nil
    }
}
