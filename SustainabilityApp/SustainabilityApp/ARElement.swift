//
//  ARElement.swift
//  SustainabilityApp
//
//  Created by Shashwath Dinesh on 4/13/25.
//

import SwiftUI
import UIKit
import Combine
import AVFoundation
import Vision
import RealityKit
import ARKit

struct ARElement: UIViewRepresentable {
    var detectedObject: String
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)
        let textAnchor = AnchorEntity()
        
        if detectedObject == "battery" {
            textAnchor.addChild(textGen(textString: "Take used batteries to designated recycling stations or drop-off points. Never toss them in the trash—they contain toxic materials!"))
        } else if detectedObject == "biological" {
            textAnchor.addChild(textGen(textString: "Compost food scraps and yard waste if possible. Biological waste should not go in regular recycling bins."))
        } else if detectedObject == "brown-glass" {
            textAnchor.addChild(textGen(textString: "Rinse and recycle brown glass bottles in glass-only bins. Avoid mixing with non-glass items or ceramics."))
        } else if detectedObject == "cardboard" {
            textAnchor.addChild(textGen(textString: "Flatten boxes, remove tape or labels, and place in your curbside recycling. Keep it dry and clean!"))
        } else if detectedObject == "clothes" {
            textAnchor.addChild(textGen(textString: "Donate wearable clothes to thrift stores. For worn-out items, check for textile recycling programs nearby."))
        } else if detectedObject == "green-glass" {
            textAnchor.addChild(textGen(textString: "Rinse and recycle green bottles and jars in designated glass bins. Don’t include broken ceramics or light bulbs."))
        } else if detectedObject == "metal" {
            textAnchor.addChild(textGen(textString: "Clean cans and foil, then place them in your metal recycling bin. Larger scrap metal may need a special drop-off."))
        } else if detectedObject == "paper" {
            textAnchor.addChild(textGen(textString: "Recycle clean paper like newspapers and magazines. Avoid anything greasy, like pizza boxes—those belong in compost."))
        } else if detectedObject == "plastic" {
            textAnchor.addChild(textGen(textString: "Check the recycling symbol and number. Rinse containers and avoid plastic bags unless your city accepts them."))
        } else if detectedObject == "shoes" {
            textAnchor.addChild(textGen(textString: "Donate gently used shoes or find a shoe recycling program. Some brands even offer return-to-recycle options."))
        } else if detectedObject == "trash" {
            textAnchor.addChild(textGen(textString: "Landfill items go in the trash. If unsure about an item, check your city’s disposal guide to avoid contamination."))
        } else if detectedObject == "white-glass" {
            textAnchor.addChild(textGen(textString: "Rinse and recycle clear glass in glass bins. Remove lids and labels when possible for better processing."))
        }
        arView.scene.addAnchor(textAnchor)
        
        return arView
        
    }

    
    func textGen(textString: String) -> Entity {
        let parentEntity = Entity()
        @State var raycast: ARTrackedRaycast? = nil

        let textMaterial = SimpleMaterial(color: .pastelGreen, roughness: 0.2, isMetallic: false)
        let depth: Float = 0.001
        let font = UIFont.systemFont(ofSize: 0.01)
        let containerFrame = CGRect(x: -0.05, y: -0.05, width: 0.1, height: 0.1)
        let alignment: CTTextAlignment = .center
        let lineBreakMode: CTLineBreakMode = .byWordWrapping

        let textMesh = MeshResource.generateText(
            textString,
            extrusionDepth: depth,
            font: font,
            containerFrame: containerFrame,
            alignment: alignment,
            lineBreakMode: lineBreakMode
        )

        let textEntity = ModelEntity(mesh: textMesh, materials: [textMaterial])
        textEntity.position = [0, -0.005, 0.005]
        
        let bgWidth: Float = 0.12
        let bgHeight: Float = 0.12
        let bgMesh = MeshResource.generatePlane(width: bgWidth, height: bgHeight)

        let bgMaterial = SimpleMaterial(
            color: UIColor.black.withAlphaComponent(0.9),
            isMetallic: false
        )

        let bgEntity = ModelEntity(mesh: bgMesh, materials: [bgMaterial])
        bgEntity.position = [0, 0, 0]
        
        parentEntity.addChild(textEntity)
        parentEntity.addChild(bgEntity)
        

        return parentEntity
    }
    
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
}


extension UIColor {
    static let pastelGreen = UIColor(red: 144/255, green: 238/255, blue: 144/255, alpha: 1.0)
}



#Preview {
    ARElement(detectedObject: "battery")
}

