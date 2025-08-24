//
//  CocoPopupViewController.swift
//  Coco
//
//  Created by Jackie Leonardy on 12/07/25.
//

import Foundation
import UIKit

final class CocoPopupViewController: UIViewController {
    init(child: UIViewController) {
        self.child = child
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .custom
        transitioningDelegate = transitionDelegate
    }

    @MainActor @objc required dynamic init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissViewController))
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissViewController() {
        dismiss(animated: true)
    }

    private func setup() {
        view.backgroundColor = .clear

        container.backgroundColor = .systemBackground
        container.layer.cornerRadius = 16
        container.layer.cornerCurve = .continuous
        container.clipsToBounds = true
        container.translatesAutoresizingMaskIntoConstraints = false

        addChild(child)
        container.addSubview(child.view)
        child.view.translatesAutoresizingMaskIntoConstraints = false
        child.didMove(toParent: self)

        NSLayoutConstraint.activate([
            child.view.topAnchor.constraint(equalTo: container.topAnchor),
            child.view.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            child.view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            child.view.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])

        view.addSubview(container)

        NSLayoutConstraint.activate([
            container.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            container.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            container.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24)
        ])
    }
    
    private let child: UIViewController
    private let transitionDelegate: PopupTransitioningDelegate = PopupTransitioningDelegate()
    fileprivate let container = UIView()
}

extension CocoPopupViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return !container.frame.contains(touch.location(in: view))
    }
}

private class PopupPresentationController: UIPresentationController {
    private let dimmingView = UIView()

    override func presentationTransitionWillBegin() {
        guard let containerView else { return }

        dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        dimmingView.frame = containerView.bounds
        dimmingView.alpha = 0
        containerView.insertSubview(dimmingView, at: 0)

        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 1
        })
    }

    override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 0
        })
    }

    override var shouldRemovePresentersView: Bool { false }
}

private class PopupAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private let isPresenting: Bool

    init(isPresenting: Bool) {
        self.isPresenting = isPresenting
        super.init()
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let targetView = transitionContext.view(forKey: isPresenting ? .to : .from) else {
            transitionContext.completeTransition(false)
            return
        }

        let containerView = transitionContext.containerView

        guard let popupViewController = transitionContext.viewController(forKey: isPresenting ? .to : .from) as? CocoPopupViewController else {
            transitionContext.completeTransition(false)
            return
        }
        
        let popupContainer = popupViewController.container

        if isPresenting {
            containerView.addSubview(targetView)
            targetView.frame = containerView.bounds
            
            popupContainer.alpha = 0
            popupContainer.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)

            UIView.animate(
                withDuration: transitionDuration(using: transitionContext),
                delay: 0,
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 0.5,
                options: .curveEaseOut,
                animations: {
                    popupContainer.alpha = 1
                    popupContainer.transform = .identity
                },
                completion: { finished in
                    transitionContext.completeTransition(finished)
                }
            )
        } else {
            UIView.animate(
                withDuration: transitionDuration(using: transitionContext),
                delay: 0,
                options: .curveEaseOut,
                animations: {
                    popupContainer.alpha = 0
                    popupContainer.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                },
                completion: { finished in
                    targetView.removeFromSuperview()
                    transitionContext.completeTransition(finished)
                }
            )
        }
    }
}

private class PopupTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        PopupPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PopupAnimator(isPresenting: true)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PopupAnimator(isPresenting: false)
    }
}
