// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Nuke
import RxCocoa
import RxSwift

public struct ImageViewContent: Equatable {

    // MARK: - Types

    public enum RenderingMode: Equatable {
        case template(Color)
        case normal

        var templateColor: Color? {
            switch self {
            case .template(let color):
                return color
            case .normal:
                return nil
            }
        }
    }

    // MARK: - Static Properties

    public static let empty = ImageViewContent()

    // MARK: - Properties

    var templateColor: UIColor? {
        renderingMode.templateColor
    }

    let accessibility: Accessibility
    let imageResource: ImageResource?
    let renderingMode: RenderingMode

    public init(
        imageResource: ImageResource? = nil,
        accessibility: Accessibility = .none,
        renderingMode: RenderingMode = .normal
    ) {
        self.imageResource = imageResource
        self.accessibility = accessibility
        self.renderingMode = renderingMode
    }
}

extension UIImageView {
    public func set(_ content: ImageViewContent?) {
        Nuke.cancelRequest(for: self)
        tintColor = content?.templateColor
        accessibility = content?.accessibility ?? .none

        guard let content = content else {
            image = nil
            return
        }

        switch content.imageResource?.resource {
        case .image(let image):
            switch content.renderingMode {
            case .normal:
                self.image = image
            case .template:
                self.image = image.withRenderingMode(.alwaysTemplate)
            }
        case .url(let url):
            image = nil
            Nuke.loadImage(with: url, into: self)
        case nil:
            image = nil
        }
    }
}

extension Reactive where Base: UIImageView {
    public var content: Binder<ImageViewContent> {
        Binder(base) { imageView, content in
            imageView.set(content)
        }
    }
}
