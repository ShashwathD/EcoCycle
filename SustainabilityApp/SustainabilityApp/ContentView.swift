//
//  ContentView.swift
//  SustainabilityApp
//
//  Created by Shashwath Dinesh on 4/12/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.green.opacity(0.48), Color("AppGreen")]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 40) {
                    Text("🌿 EcoCycle")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top, 40)

                    Spacer()

                    NavigationLink(destination: DisposalView()) {
                        FeatureButtonView(
                            iconName: "trash.circle.fill",
                            title: "Scan for Disposal",
                            subtitle: "Identify and sort waste properly"
                        )
                    }

                    NavigationLink(destination: UpcycleView()) {
                        FeatureButtonView(
                            iconName: "leaf.arrow.circlepath",
                            title: "Upcycling Ideas",
                            subtitle: "Find creative ways to reuse items"
                        )
                    }

                    Spacer()
                    
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

struct FeatureButtonView: View {
    var iconName: String
    var title: String
    var subtitle: String

    var body: some View {
        HStack {
            Image(systemName: iconName)
                .font(.system(size: 40))
                .foregroundColor(.white)
                .padding()

            VStack(alignment: .leading) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }

            Spacer()
        }
        .padding()
        .background(Color.green.opacity(0.85))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 5, y: 5)
    }
}


#Preview {
    ContentView()
}
