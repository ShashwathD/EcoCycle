//
//  DisposalView.swift
//  SustainabilityApp
//
//  Created by Shashwath Dinesh on 4/12/25.
//

import SwiftUI
import UIKit
import Combine
import AVFoundation
import Vision

class CameraViewModel: ObservableObject {
    @Published var detectedObject: String = ""
    @Published var confidence: Float = 0.0
    @Published var boundingBox: CGRect = .zero
    @Published var detectedObjectPosition: SIMD3<Float>? = nil
    @Published var showUpCycleView = false
}

struct DisposalView: View {
    
    @StateObject private var viewModel = CameraViewModel()
    
    var body: some View {
        ZStack {
            CameraView(viewModel: viewModel)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Text(viewModel.detectedObject)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .multilineTextAlignment(.center)
                
                Text(String(format: "Confidence: %.2f", viewModel.confidence))
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .multilineTextAlignment(.center)
            }
            
            Rectangle()
                .stroke(Color.red, lineWidth: 3)
                .frame(width: viewModel.boundingBox.width, height: viewModel.boundingBox.height)
                .position(x: viewModel.boundingBox.midX, y: viewModel.boundingBox.midY)
            
            if viewModel.showUpCycleView {
                ARElement(detectedObject: viewModel.detectedObject)
                    .edgesIgnoringSafeArea(.all)
                    .transition(.opacity) // Optional: make ARView fade in
            }
        }
        .onAppear {
            viewModel.showUpCycleView = false
        }
    }
}

struct CameraView: UIViewControllerRepresentable {
    @ObservedObject var viewModel: CameraViewModel

    func makeUIViewController(context: Context) -> UIViewController {
        return CameraViewController(viewModel: viewModel)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

class CameraViewController: UIViewController {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var viewModel: CameraViewModel
    
    init(viewModel: CameraViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder:NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        captureSession = AVCaptureSession()
        captureSession.beginConfiguration()
        
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let videoInput = try? AVCaptureDeviceInput(device: videoDevice)
        else { return }
        
        captureSession.addInput(videoInput)
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "cameraQueue"))
        captureSession.addOutput(videoOutput)
        
        captureSession.commitConfiguration()
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.layer.bounds
        view.layer.addSublayer(previewLayer)
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }

    }
}

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func detectObject(sampleBuffer: CMSampleBuffer) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let config = MLModelConfiguration()
        guard let model = try? VNCoreMLModel(for: WasteClassifier(configuration: config).model) else { return }

        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else { return }

            if let firstResult = results.first, firstResult.confidence > 0.6 {
                DispatchQueue.main.async {
                    self.viewModel.detectedObject = firstResult.identifier
                    self.viewModel.confidence = firstResult.confidence
                    print("Detected object: \(firstResult.identifier) with confidence: \(firstResult.confidence)")
                    self.viewModel.boundingBox = CGRect(x: 120, y: 100, width: 200, height: 200)
                    self.viewModel.showUpCycleView = true
                }
            } else {
                DispatchQueue.main.async {
                    self.viewModel.detectedObject = "No object detected with sufficient confidence"
                    self.viewModel.confidence = .zero
                    self.viewModel.boundingBox = .zero
                    self.viewModel.showUpCycleView = false
                }
            }
        }

        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        try? handler.perform([request])
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        detectObject(sampleBuffer: sampleBuffer)
    }
}


#Preview {
    DisposalView()
}
