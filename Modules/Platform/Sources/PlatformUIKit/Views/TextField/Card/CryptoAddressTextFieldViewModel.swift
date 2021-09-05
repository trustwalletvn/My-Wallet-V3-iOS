// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift
import ToolKit

public final class CryptoAddressTextFieldViewModel: TextFieldViewModel {

    // MARK: - Properties

    private let disposeBag = DisposeBag()

    // MARK: - Setup

    public init(
        validator: TextValidating,
        messageRecorder: MessageRecording
    ) {
        super.init(
            with: .cryptoAddress,
            validator: validator,
            messageRecorder: messageRecorder
        )
        let content = ImageViewContent(
            imageResource: .local(name: "Icon-qr", bundle: .platformUIKit)
        )
        let viewModel = BadgeImageViewModel(cornerRadius: .roundedLow)
        viewModel.sizingTypeRelay.accept(.constant(CGSize(width: 32, height: 20)))
        viewModel.marginOffsetRelay.accept(0)
        viewModel.imageContentRelay.accept(content)
        viewModel.backgroundColorRelay.accept(.white)

        Observable.just(.badgeImageView(viewModel))
            .bindAndCatch(to: accessoryContentTypeRelay)
            .disposed(by: disposeBag)
    }
}
