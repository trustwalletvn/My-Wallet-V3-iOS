// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public struct NoticeViewModel: Equatable {

    public enum Alignement {
        case top
        case center
    }

    /// The image content
    public let imageViewContent: ImageViewContent

    /// The image size
    public let imageViewSize: CGSize

    /// The label content
    public let labelContents: [LabelContent]

    /// The vertical alignment of the element
    public let verticalAlignment: Alignement

    public init(
        imageViewContent: ImageViewContent,
        imageViewSize: CGSize = .init(edge: 20),
        labelContents: [LabelContent],
        verticalAlignment: Alignement
    ) {
        self.imageViewContent = imageViewContent
        self.imageViewSize = imageViewSize
        self.labelContents = labelContents
        self.verticalAlignment = verticalAlignment
    }

    public init(
        imageViewContent: ImageViewContent,
        imageViewSize: CGSize = .init(edge: 20),
        labelContents: LabelContent...,
        verticalAlignment: Alignement
    ) {
        self.imageViewContent = imageViewContent
        self.imageViewSize = imageViewSize
        self.labelContents = labelContents
        self.verticalAlignment = verticalAlignment
    }
}
