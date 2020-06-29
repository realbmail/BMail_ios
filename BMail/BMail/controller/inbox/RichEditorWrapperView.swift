//
//  RichEditorWrapperView.swift
//  BMail
//
//  Created by hyperorchid on 2020/5/6.
//  Copyright © 2020 NBS. All rights reserved.
//

import Foundation
import UIKit
class RichEditorWrapperView: RichEditorView {
    public var lastFocus: CGPoint?
    public var tap: UITapGestureRecognizer!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    public func configure() {
        tap = super.gestureRecognizers![0] as? UITapGestureRecognizer
        tap.addTarget(self, action: #selector(wasTapped))
        tap.delegate = self
        addGestureRecognizer(tap)
    }
    
    @objc private func wasTapped() {
        lastFocus = tap.location(in: super.webView)
    }
}
