// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import HDWalletKit
import XCTest

class WordListTests: XCTestCase {

    func testWordListCount() throws {
        XCTAssertEqual(WordList.default.words.count, 2048)
        XCTAssertEqual(WordList.default.words.unique.count, 2048)
    }
}
