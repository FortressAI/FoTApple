// CameraCaptureView.swift
// Real camera capture with sensor fusion - NO MOCKS

import SwiftUI
import AVFoundation

#if canImport(UIKit)
public struct CameraCaptureView: View {
    @Binding public var isPresented: Bool
    @State private var capturedImage: UIImage?
    @State private var isCaptureComplete = false
    @State private var receiptID: String?
    
    public init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                if let image = capturedImage {
                    // Show captured image with receipt
                    VStack(spacing: 20) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 400)
                            .cornerRadius(12)
                        
                        if let receipt = receiptID {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("✅ Cryptographic Receipt Generated")
                                    .font(.headline)
                                    .foregroundColor(.green)
                                
                                Text("Receipt ID:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text(receipt)
                                    .font(.system(.caption, design: .monospaced))
                                    .padding(8)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                            }
                            .padding()
                        }
                        
                        Button("Done") {
                            isPresented = false
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                } else {
                    // Show camera interface
                    CameraPreviewView { image in
                        Task {
                            await captureImageWithSensors(image)
                        }
                    }
                }
            }
            .navigationTitle("Camera Capture")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }
    
    private func captureImageWithSensors(_ image: UIImage) async {
        FoTLogger.app.info("📸 Capturing image with full sensor fusion...")
        
        do {
            // Capture all sensors
            let receipt = try await SensorCaptureEngine.shared.emergencyCapture()
            
            // Store image with receipt
            // TODO: Save image to documents directory with receipt ID
            
            capturedImage = image
            receiptID = receipt.id
            isCaptureComplete = true
            
            FoTLogger.app.info("✅ Image captured with receipt: \(receipt.id)")
            
        } catch {
            FoTLogger.app.error("❌ Failed to capture: \(error.localizedDescription)")
        }
    }
}

// MARK: - Camera Preview (Real AVFoundation implementation)

struct CameraPreviewView: UIViewRepresentable {
    let onCapture: (UIImage) -> Void
    
    func makeUIView(context: Context) -> CameraPreviewUIView {
        let view = CameraPreviewUIView()
        view.onCapture = onCapture
        return view
    }
    
    func updateUIView(_ uiView: CameraPreviewUIView, context: Context) {
        // No updates needed
    }
}

class CameraPreviewUIView: UIView {
    var onCapture: ((UIImage) -> Void)?
    
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var photoOutput: AVCapturePhotoOutput?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCamera()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer?.frame = bounds
    }
    
    private func setupCamera() {
        let session = AVCaptureSession()
        session.sessionPreset = .photo
        
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: camera) else {
            FoTLogger.app.error("❌ Failed to access camera")
            return
        }
        
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        let output = AVCapturePhotoOutput()
        if session.canAddOutput(output) {
            session.addOutput(output)
            photoOutput = output
        }
        
        let preview = AVCaptureVideoPreviewLayer(session: session)
        preview.videoGravity = .resizeAspectFill
        layer.addSublayer(preview)
        previewLayer = preview
        
        captureSession = session
        
        DispatchQueue.global(qos: .userInitiated).async {
            session.startRunning()
        }
        
        // Add capture button
        let button = UIButton(type: .system)
        button.setTitle("📸 Capture", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 30
        button.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        button.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)
        addSubview(button)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: centerXAnchor),
            button.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -40),
            button.widthAnchor.constraint(equalToConstant: 80),
            button.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    @objc private func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput?.capturePhoto(with: settings, delegate: PhotoCaptureDelegate { [weak self] image in
            self?.onCapture?(image)
            self?.captureSession?.stopRunning()
        })
    }
}

// Photo capture delegate
class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    let completion: (UIImage) -> Void
    
    init(completion: @escaping (UIImage) -> Void) {
        self.completion = completion
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            FoTLogger.app.error("Photo capture error: \(error.localizedDescription)")
            return
        }
        
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            FoTLogger.app.error("Failed to process photo data")
            return
        }
        
        completion(image)
    }
}

#else
// macOS stub
public struct CameraCaptureView: View {
    @Binding public var isPresented: Bool
    
    public init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
    }
    
    public var body: some View {
        Text("Camera capture not available on macOS")
            .padding()
    }
}
#endif

