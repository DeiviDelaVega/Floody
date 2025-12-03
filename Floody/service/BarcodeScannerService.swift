import AVFoundation
import UIKit

final class BarcodeScannerService: NSObject, AVCaptureMetadataOutputObjectsDelegate {

    private let session = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var onCodeDetected: ((String) -> Void)?

    func start(
        in view: UIView,
        onDetected: @escaping (String) -> Void
    ) {

        self.onCodeDetected = onDetected

        guard
            let device = AVCaptureDevice.default(for: .video),
            let input = try? AVCaptureDeviceInput(device: device),
            session.canAddInput(input)
        else { return }

        session.addInput(input)

        let output = AVCaptureMetadataOutput()
        guard session.canAddOutput(output) else { return }

        session.addOutput(output)
        output.setMetadataObjectsDelegate(self, queue: .main)
        output.metadataObjectTypes = [.ean13, .ean8, .upce, .qr]

        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer?.videoGravity = .resizeAspectFill
        previewLayer?.frame = view.bounds

        if let layer = previewLayer {
            view.layer.addSublayer(layer)
        }

        session.startRunning()
    }

    func stop() {
        session.stopRunning()
    }

    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {

        guard
            let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
            let code = object.stringValue
        else { return }

        stop()
        onCodeDetected?(code)
    }
}
