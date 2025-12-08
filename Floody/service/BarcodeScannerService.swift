import AVFoundation
import UIKit

final class BarcodeScannerService: NSObject, AVCaptureMetadataOutputObjectsDelegate {

    private let session = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var onCodeDetected: ((String) -> Void)?
    private var isProcessing = false

    func start(
        in view: UIView,
        onDetected: @escaping (String) -> Void
    ) {
        self.onCodeDetected = onDetected

        session.beginConfiguration()
        session.inputs.forEach { session.removeInput($0) }
        session.outputs.forEach { session.removeOutput($0) }
        session.commitConfiguration()

        guard
            let device = AVCaptureDevice.default(for: .video),
            let input = try? AVCaptureDeviceInput(device: device),
            session.canAddInput(input)
        else { return }

        // Autofocus
        try? device.lockForConfiguration()
        if device.isFocusModeSupported(.continuousAutoFocus) {
            device.focusMode = .continuousAutoFocus
        }
        if device.isExposureModeSupported(.continuousAutoExposure) {
            device.exposureMode = .continuousAutoExposure
        }
        device.unlockForConfiguration()

        session.addInput(input)

        let output = AVCaptureMetadataOutput()
        guard session.canAddOutput(output) else { return }

        session.addOutput(output)
        output.setMetadataObjectsDelegate(self, queue: .main)
        output.metadataObjectTypes = [.ean13, .ean8, .upce, .qr]

        previewLayer?.removeFromSuperlayer()

        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer?.videoGravity = .resizeAspectFill
        previewLayer?.frame = view.bounds

        if let layer = previewLayer {
            view.layer.addSublayer(layer)
        }

        DispatchQueue.global(qos: .userInitiated).async {
            self.session.startRunning()
        }
    }


    func stop() {
        session.stopRunning()
    }

    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {

        guard !isProcessing else { return }

        guard
            let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
            let code = object.stringValue
        else { return }

        isProcessing = true
        onCodeDetected?(code)

        // Cooldown de 1 segundo para permitir nuevo escaneo
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isProcessing = false
        }
    }
}
