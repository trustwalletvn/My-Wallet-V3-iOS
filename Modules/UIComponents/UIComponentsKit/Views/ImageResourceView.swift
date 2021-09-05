// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

public struct ImageResourceView: View {

    private enum ImageState {
        case image(UIImage)
        case loading
        case failure
    }

    private class Loader: ObservableObject {

        var state: ImageState

        init(_ imageResource: ImageResource) {
            guard let resource = imageResource.resource else {
                print("⚠️ Null Resource for \(imageResource)")
                state = .failure
                return
            }
            switch resource {
            case .image(let image):
                state = .image(image)
            case .url(let url):
                state = .loading
                // TODO: use an image loading and caching framework for this
                DispatchQueue.global(qos: .userInteractive).async {
                    do {
                        let imageData = try Data(contentsOf: url)
                        let image = UIImage(data: imageData)
                        DispatchQueue.main.async {
                            if let image = image {
                                self.state = .image(image)
                            } else {
                                self.state = .failure
                            }
                            self.objectWillChange.send()
                        }
                    } catch {
                        print("🚨 Error loading image from \(imageResource) => \(error)")
                        DispatchQueue.main.async {
                            self.state = .failure
                            self.objectWillChange.send()
                        }
                    }
                }
            }
        }
    }

    @StateObject private var loader: Loader

    public init(_ imageResource: ImageResource) {
        _loader = StateObject(wrappedValue: Loader(imageResource))
    }

    public var body: some View {
        guard case .image(let image) = loader.state else {
            return AnyView(ActivityIndicatorView())
        }
        let imageView = Image(uiImage: image)
            .resizable()
        return AnyView(imageView)
    }
}

struct ImageResourceView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            ImageResourceView(.local(name: "cancel_icon", bundle: .current))
                .aspectRatio(contentMode: .fit)
                .frame(width: 20)

            ImageResourceView(
                .remote(
                    url: "https://www.blockchain.com/static/img/home/products/wallet-buy@2x.png"
                )
            )
            .aspectRatio(contentMode: .fit)
        }
    }
}
