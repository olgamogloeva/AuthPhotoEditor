

import SwiftUI
import UIKit
import PencilKit

struct DrawingView: UIViewControllerRepresentable {
    @Binding var image: UIImage
    @Binding var isVisible: Bool

    func makeUIViewController(context: Context) -> DrawingViewController {
        let viewController = DrawingViewController(image: image) { editedImage in
            self.image = editedImage
            self.isVisible = false
        }
        return viewController
    }

    func updateUIViewController(_ uiViewController: DrawingViewController, context: Context) {}
}


class DrawingViewController: UIViewController {
    
    var image: UIImage
    var onSave: ((UIImage) -> Void)?
    
    private var canvasView = PKCanvasView()
    private let toolPicker = PKToolPicker()
    private let imageView = UIImageView()
    private let saveButton = UIButton(type: .system)
    
    init(image: UIImage, onSave: @escaping (UIImage) -> Void) {
        self.image = image
        self.onSave = onSave
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupToolPicker()
    }

    private func setupUI() {
        view.backgroundColor = .black

        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)

        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        canvasView.drawingPolicy = .anyInput
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(canvasView)

        saveButton.setTitle("Save", for: .normal)
        saveButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        saveButton.backgroundColor = UIColor.systemBlue
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 8
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.addTarget(self, action: #selector(closeAndSave), for: .touchUpInside)
        view.addSubview(saveButton)

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            canvasView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            canvasView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
            canvasView.topAnchor.constraint(equalTo: imageView.topAnchor),
            canvasView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),

            saveButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveButton.widthAnchor.constraint(equalToConstant: 100),
            saveButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func setupToolPicker() {
        guard let window = view.window ?? UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else {
            return
        }

        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)

        DispatchQueue.main.async {
            self.canvasView.becomeFirstResponder()
        }
    }

    @objc private func closeAndSave() {
        let newImage = mergeDrawingWithImage()
        onSave?(newImage)
        dismiss(animated: true, completion: nil)
    }

    private func mergeDrawingWithImage() -> UIImage {
        let imageSize = image.size
        let displayedImageFrame = calculateDisplayedImageFrame()

        let renderer = UIGraphicsImageRenderer(size: imageSize)
        return renderer.image { context in
            image.draw(in: CGRect(origin: .zero, size: imageSize))

            let scaleX = imageSize.width / displayedImageFrame.width
            let scaleY = imageSize.height / displayedImageFrame.height

            context.cgContext.saveGState()
            context.cgContext.translateBy(x: -displayedImageFrame.origin.x * scaleX, y: -displayedImageFrame.origin.y * scaleY)
            context.cgContext.scaleBy(x: scaleX, y: scaleY)

            let drawingImage = canvasView.drawing.image(from: canvasView.bounds, scale: 1)
            drawingImage.draw(in: CGRect(origin: .zero, size: canvasView.bounds.size))

            context.cgContext.restoreGState()
        }
    }

    private func calculateDisplayedImageFrame() -> CGRect {
        guard let actualImage = imageView.image else { return .zero }

        let imageViewSize = imageView.bounds.size
        let imageSize = actualImage.size

        let scaleX = imageViewSize.width / imageSize.width
        let scaleY = imageViewSize.height / imageSize.height
        let scale = min(scaleX, scaleY)

        let displayedWidth = imageSize.width * scale
        let displayedHeight = imageSize.height * scale

        let originX = (imageViewSize.width - displayedWidth) / 2
        let originY = (imageViewSize.height - displayedHeight) / 2

        return CGRect(x: originX, y: originY, width: displayedWidth, height: displayedHeight)
    }
}
