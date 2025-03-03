

import UIKit
import SwiftUI

protocol TextEffectViewControllerDelegate: AnyObject {
    func didApplyText(image: UIImage)
}

class TextEffectViewController: UIViewController, UITextViewDelegate {

    var image: UIImage
    weak var delegate: TextEffectViewControllerDelegate?

    private let imageView = UIImageView()
    private let textView = UITextView()
    private let saveButton = UIButton(type: .system)
    private let settingsButton = UIButton(type: .system)
    private let activityIndicator = UIActivityIndicatorView(style: .large)

    private var lastTextPosition: CGPoint = .zero
    private var isKeyboardVisible = false

    init(image: UIImage) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardObservers()
    }

    private func setupUI() {
        view.backgroundColor = .black

        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)

        textView.text = "Your Text"
        textView.font = UIFont.boldSystemFont(ofSize: 40)
        textView.textColor = .white
        textView.backgroundColor = .clear
        textView.textAlignment = .center
        textView.isScrollEnabled = false
        textView.isUserInteractionEnabled = true
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.delegate = self
        view.addSubview(textView)

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        textView.addGestureRecognizer(panGesture)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)

        saveButton.setTitle("Apply Text", for: .normal)
        saveButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        saveButton.backgroundColor = UIColor.systemBlue
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 8
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.addTarget(self, action: #selector(applyTextToImage), for: .touchUpInside)
        view.addSubview(saveButton)

        settingsButton.setTitle("⚙️", for: .normal)
        settingsButton.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        settingsButton.addTarget(self, action: #selector(showTextSettings), for: .touchUpInside)
        view.addSubview(settingsButton)

        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            textView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            textView.widthAnchor.constraint(equalToConstant: 200),
            textView.heightAnchor.constraint(equalToConstant: 60),

            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveButton.widthAnchor.constraint(equalToConstant: 120),
            saveButton.heightAnchor.constraint(equalToConstant: 50),

            settingsButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            settingsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        lastTextPosition = textView.frame.origin
    }

    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification, object: nil
        )

        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification, object: nil
        )
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        isKeyboardVisible = true
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        isKeyboardVisible = false
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        if isKeyboardVisible { return }

        let translation = gesture.translation(in: view)

        switch gesture.state {
        case .began:
            lastTextPosition = textView.frame.origin
        case .changed:
            let newX = lastTextPosition.x + translation.x
            let newY = lastTextPosition.y + translation.y

            let minX = imageView.frame.minX
            let minY = imageView.frame.minY
            let maxX = imageView.frame.maxX - textView.frame.width
            let maxY = imageView.frame.maxY - textView.frame.height

            textView.frame.origin.x = min(max(minX, newX), maxX)
            textView.frame.origin.y = min(max(minY, newY), maxY)
        case .ended:
            lastTextPosition = textView.frame.origin
        default:
            break
        }
    }
    
    private func mergeTextWithImage(
        imageSize: CGSize,
        displayedImageFrame: CGRect,
        textViewText: String,
        textViewFrame: CGRect,
        textViewFont: UIFont,
        textViewColor: UIColor
    ) -> UIImage {
        let maxResolution: CGFloat = 2048
        let scale = min(maxResolution / imageSize.width, maxResolution / imageSize.height, 1.0)
        let newSize = CGSize(width: imageSize.width * scale, height: imageSize.height * scale)

        let renderer = UIGraphicsImageRenderer(size: newSize)

        return renderer.image { context in
            image.draw(in: CGRect(origin: .zero, size: newSize))

            let scaleFactorX = newSize.width / displayedImageFrame.width
            let scaleFactorY = newSize.height / displayedImageFrame.height

            let adjustedPositionX = (textViewFrame.midX - displayedImageFrame.minX) * scaleFactorX
            let adjustedPositionY = (textViewFrame.midY - displayedImageFrame.minY) * scaleFactorY

            let textFont = UIFont.boldSystemFont(ofSize: textViewFont.pointSize * scaleFactorX)

            let attributes: [NSAttributedString.Key: Any] = [
                .font: textFont,
                .foregroundColor: textViewColor
            ]

            let textSize = textViewText.size(withAttributes: attributes)
            let textRect = CGRect(
                x: adjustedPositionX - textSize.width / 2,
                y: adjustedPositionY - textSize.height / 2,
                width: textSize.width,
                height: textSize.height
            )

            textViewText.draw(in: textRect, withAttributes: attributes)
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
    
    @objc private func applyTextToImage() {
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
        }

        let imageSize = image.size
        let displayedImageFrame = calculateDisplayedImageFrame()

        DispatchQueue.main.async {
            let textViewText = self.textView.text ?? ""
            let textViewFrame = self.textView.frame
            let textViewFont = self.textView.font ?? UIFont.systemFont(ofSize: 40)
            let textViewColor = self.textView.textColor ?? .white

            DispatchQueue.global(qos: .userInitiated).async {
                let newImage = self.mergeTextWithImage(
                    imageSize: imageSize,
                    displayedImageFrame: displayedImageFrame,
                    textViewText: textViewText,
                    textViewFrame: textViewFrame,
                    textViewFont: textViewFont,
                    textViewColor: textViewColor
                )

                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.image = newImage
                    self.imageView.image = newImage
                    self.delegate?.didApplyText(image: newImage)
                    self.dismiss(animated: true) {
                        self.cleanupMemory()
                    }
                }
            }
        }
    }
    
    private func cleanupMemory() {
        imageView.image = nil
        textView.removeFromSuperview()
    }
    
    @objc private func showTextSettings() {
        let alert = UIAlertController(title: "Text Settings", message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Change Font", style: .default, handler: { _ in
            self.showFontSelection()
        }))

        alert.addAction(UIAlertAction(title: "Change Color", style: .default, handler: { _ in
            self.showColorPicker()
        }))

        alert.addAction(UIAlertAction(title: "Change Size", style: .default, handler: { _ in
            self.showSizeSlider()
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(alert, animated: true)
    }
    
    private func showFontSelection() {
        let fonts = ["Helvetica", "Times New Roman", "Courier", "Avenir", "Futura"]
        let alert = UIAlertController(title: "Select Font", message: nil, preferredStyle: .actionSheet)

        for fontName in fonts {
            alert.addAction(UIAlertAction(title: fontName, style: .default, handler: { _ in
                self.textView.font = UIFont(name: fontName, size: self.textView.font?.pointSize ?? 40)
            }))
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true)
    }

    private func showColorPicker() {
        let alert = UIAlertController(title: "Select Color", message: nil, preferredStyle: .actionSheet)

        let colors: [(String, UIColor)] = [
            ("Black", .black), ("Red", .red), ("Green", .green), ("Blue", .blue), ("Yellow", .yellow), ("White", .white)
        ]

        for (name, color) in colors {
            alert.addAction(UIAlertAction(title: name, style: .default, handler: { _ in
                self.textView.textColor = color
            }))
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true)
    }

    private func showSizeSlider() {
        let alert = UIAlertController(title: "Adjust Size", message: "\n\n\n", preferredStyle: .alert)

        let slider = UISlider(frame: CGRect(x: 10, y: 50, width: 250, height: 40))
        slider.minimumValue = 20
        slider.maximumValue = 100
        slider.value = Float(textView.font?.pointSize ?? 40)

        alert.view.addSubview(slider)

        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            self.textView.font = self.textView.font?.withSize(CGFloat(slider.value))
        }

        alert.addAction(okAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(alert, animated: true)
    }
}

struct TextEffect: UIViewControllerRepresentable {
    @Binding var image: UIImage
    @Binding var isVisible: Bool

    func makeUIViewController(context: Context) -> TextEffectViewController {
        let viewController = TextEffectViewController(image: image)
        viewController.delegate = context.coordinator
        return viewController
    }

    func updateUIViewController(_ uiViewController: TextEffectViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    class Coordinator: NSObject, TextEffectViewControllerDelegate {
        var parent: TextEffect

        init(_ parent: TextEffect) {
            self.parent = parent
        }

        func didApplyText(image: UIImage) {
            parent.image = image
            parent.isVisible = false
        }
    }
}
