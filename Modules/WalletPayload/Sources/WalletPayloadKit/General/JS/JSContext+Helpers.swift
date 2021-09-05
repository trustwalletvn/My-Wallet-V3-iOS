// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import JavaScriptCore

extension JSContext {
    @objc func setJsFn0(named functionName: NSCopying & NSObjectProtocol, valueFunctionBlock: @escaping () -> Void) {
        let theBlock: @convention(block) () -> Void = {
            valueFunctionBlock()
        }
        setObject(theBlock, forKeyedSubscript: functionName)
    }

    @objc func setJsFn1(named functionName: NSCopying & NSObjectProtocol, valueFunctionBlock: @escaping (JSValue) -> Void) {
        let theBlock: @convention(block) (JSValue) -> Void = { jsValue in
            valueFunctionBlock(jsValue)
        }
        setObject(theBlock, forKeyedSubscript: functionName)
    }

    @objc func setJsFn2(named functionName: NSCopying & NSObjectProtocol, valueFunctionBlock: @escaping (JSValue, JSValue) -> Void) {
        let theBlock: @convention(block) (JSValue, JSValue) -> Void = { jsValue1, jsValue2 in
            valueFunctionBlock(jsValue1, jsValue2)
        }
        setObject(theBlock, forKeyedSubscript: functionName)
    }
}

extension JSContext {

    @objc func setJsFn2Pure(named functionName: NSCopying & NSObjectProtocol, valueFunctionBlock: @escaping (JSValue, JSValue) -> Any) {
        let theBlock: @convention(block) (JSValue, JSValue) -> Any = { jsValue1, jsValue2 in
            valueFunctionBlock(jsValue1, jsValue2)
        }
        setObject(theBlock, forKeyedSubscript: functionName)
    }
}
