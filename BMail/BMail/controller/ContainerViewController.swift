//
//  ContainerViewController.swift
//  BMail
//
//  Created by hyperorchid on 2020/4/25.
//  Copyright © 2020 NBS. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {

        enum SlideOutState {
                case bothCollapsed
                case leftPanelExpanded
        }
    
        var centerNavigationController: UINavigationController!
        var centerViewController: CenterViewController!
        var panGesture:UIPanGestureRecognizer!
        var currentState: SlideOutState = .bothCollapsed {
                didSet {
                        let shouldShowShadow = currentState != .bothCollapsed
                        showShadowForCenterViewController(shouldShowShadow)
                }
        }
        var leftViewController: MenuViewController?
        let centerPanelExpandedOffset: CGFloat = 90
         
        override func viewDidLoad() {
                super.viewDidLoad()
           
                centerViewController = UIStoryboard.centerViewController(name: "InboxViewController")
                centerViewController.setDelegate(delegate: self)//.delegate = self
           
                centerNavigationController = UINavigationController(rootViewController: centerViewController as! UIViewController)
                view.addSubview(centerNavigationController.view)
                addChild(centerNavigationController)
           
                centerNavigationController.didMove(toParent: self)
           
                panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
                panGesture.delegate = self
                centerNavigationController.view.addGestureRecognizer(panGesture)
         }
}

// MARK: CenterViewController delegate

extension ContainerViewController: CenterViewControllerDelegate {
        func toggleLeftPanel() {
                let notAlreadyExpanded = (currentState != .leftPanelExpanded)

                if notAlreadyExpanded {
                        addLeftPanelViewController()
                }

                animateLeftPanel(shouldExpand: notAlreadyExpanded)
        }
  
        func addLeftPanelViewController() {
                guard leftViewController == nil else { return }

                if let vc = UIStoryboard.leftViewController() {
                        addChildSidePanelController(vc)
                        leftViewController = vc
                }
        }
  
        func animateLeftPanel(shouldExpand: Bool) {
                if shouldExpand {
                        currentState = .leftPanelExpanded
                        animateCenterPanelXPosition(
                                targetPosition: centerNavigationController.view.frame.width - centerPanelExpandedOffset)
                } else {
                        animateCenterPanelXPosition(targetPosition: 0) { _ in
                                self.currentState = .bothCollapsed
                                self.leftViewController?.view.removeFromSuperview()
                                self.leftViewController = nil
                        }
                }
        }
  
        func collapseSidePanels() {
                switch currentState {
                case .leftPanelExpanded:
                        toggleLeftPanel()
                default:
                        break
                }
        }
  
        func animateCenterPanelXPosition(targetPosition: CGFloat, completion: ((Bool) -> Void)? = nil) {
                UIView.animate(withDuration: 0.5,
                   delay: 0,
                   usingSpringWithDamping: 0.8,
                   initialSpringVelocity: 0,
                   options: .curveEaseInOut, animations: {
                     self.centerNavigationController.view.frame.origin.x = targetPosition
                }, completion: completion)
        }
  
        func addChildSidePanelController(_ sidePanelController: MenuViewController) {
                sidePanelController.delegate = self
                view.insertSubview(sidePanelController.view, at: 0)
    
                addChild(sidePanelController)
                sidePanelController.didMove(toParent: self)
        }
  
        func showShadowForCenterViewController(_ shouldShowShadow: Bool) {
                if shouldShowShadow {
                        centerNavigationController.view.layer.shadowOpacity = 0.8
                } else {
                        centerNavigationController.view.layer.shadowOpacity = 0.0
                }
        }
}

// MARK: Gesture recognizer
extension ContainerViewController: UIGestureRecognizerDelegate {
        
        @objc func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                 shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
                if currentState == .leftPanelExpanded{
                        return true
                }else{
                        return false
                }
        }
        
        @objc func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
               return true
        }
        
        @objc func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
                let gestureIsDraggingFromLeftToRight = (recognizer.velocity(in: view).x > 0)
          
                switch recognizer.state {
                case .began:
                        if currentState == .bothCollapsed {
                                if gestureIsDraggingFromLeftToRight {
                                        addLeftPanelViewController()
                                }
        
                                showShadowForCenterViewController(true)
                        }
      
                case .changed:
                        if let rview = recognizer.view {
                                rview.center.x = rview.center.x + recognizer.translation(in: view).x
                                if rview.center.x < view.bounds.size.width / 2{
                                        rview.center.x = view.bounds.size.width / 2
                                }
                                recognizer.setTranslation(CGPoint.zero, in: view)
                        }
      
                case .ended:
                        if let _ = leftViewController,
                                let rview = recognizer.view {
                                let hasMovedGreaterThanHalfway = rview.center.x > view.bounds.size.width
                                animateLeftPanel(shouldExpand: hasMovedGreaterThanHalfway)
                        }
                default:
                        break
                }
        }
}


extension ContainerViewController: SidePanelViewControllerDelegate {
        func actionByViewType(viewType: MailActionType) {
                self.collapseSidePanels()
                
                if viewType.rawValue < MailActionType.Help.rawValue{
                        centerNavigationController.setViewControllers([centerViewController as! UIViewController], animated: true)
                        centerViewController.changeContext(viewType: viewType)
                }else{
                        guard let vc = UIStoryboard.centerViewController(name: viewType.ViewControllerID()) else {
                                return
                        }
                        vc.setDelegate(delegate: self)
                        centerNavigationController.setViewControllers([vc as! UIViewController], animated: true)
                }
        }
}
