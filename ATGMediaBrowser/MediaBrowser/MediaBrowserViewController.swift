//
//  MediaBrowserViewController.swift
//  Nisnass
//
//  Created by Suraj Thomas K on 7/10/18.
//  Copyright © 2018 Al Tayer Group LLC. All rights reserved.
//
//  Save to the extent permitted by law, you may not use, copy, modify,
//  distribute or create derivative works of this material or any part
//  of it without the prior written consent of Al Tayer Group LLC.
//  Any reproduction of this material must contain this notice.
//

public class MediaBrowserViewController: UIViewController {

    public var gestureDirection: GestureDirection = .horizontal
    public var gapBetweenMediaViews: CGFloat = Constants.gapBetweenContents {
        didSet {
            MediaContentView.interItemSpacing = gapBetweenMediaViews
            contentViews.forEach({ $0.updateTransform() })
        }
    }

    private enum Constants {

        static let gapBetweenContents: CGFloat = 50.0
    }

    public enum GestureDirection {

        case horizontal
        case vertical
    }

    private var contentViews: [MediaContentView] = []

    private var previousTranslation: CGPoint = .zero

    lazy private var panGestureRecognizer: UIPanGestureRecognizer = { [unowned self] in

        let gesture = UIPanGestureRecognizer()
        gesture.minimumNumberOfTouches = 1
        gesture.maximumNumberOfTouches = 1
        gesture.addTarget(self, action: #selector(panGestureEvent(_:)))
        return gesture
    }()

    // MARK: - Initializers
    public init() {

        super.init(nibName: nil, bundle: nil)
        initialize()
    }

    public required init?(coder aDecoder: NSCoder) {

        super.init(coder: aDecoder)
        initialize()
    }

    private func initialize() {

        view.backgroundColor = .red
    }

    override public func viewDidLoad() {

        super.viewDidLoad()

        populateContentViews()

        view.addGestureRecognizer(temporaryCloseGestureRecognizer)
        view.addGestureRecognizer(panGestureRecognizer)
    }

    override public func viewDidAppear(_ animated: Bool) {

        super.viewDidAppear(animated)

        contentViews.forEach({ $0.updateTransform() })
    }

    private func populateContentViews() {

        MediaContentView.interItemSpacing = gapBetweenMediaViews

        contentViews.forEach({ $0.removeFromSuperview() })
        contentViews.removeAll()

        for i in 0..<3 {
            let mediaView = MediaContentView(index: i)
            view.addSubview(mediaView)
            mediaView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                mediaView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                mediaView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                mediaView.topAnchor.constraint(equalTo: view.topAnchor),
                mediaView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])

            contentViews.append(mediaView)
        }
    }

    // TODO: - Remove: Temporary Shit
    lazy private var temporaryCloseGestureRecognizer: UITapGestureRecognizer = { [unowned self] in

        let gesture = UITapGestureRecognizer()
        gesture.numberOfTapsRequired = 3
        gesture.addTarget(self, action: #selector(temporaryCloseMethod))
        return gesture
    }()

    @objc private func temporaryCloseMethod() {

        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Pan Gesture Recognizer

extension MediaBrowserViewController {

    @objc private func panGestureEvent(_ recognizer: UIPanGestureRecognizer) {

        let translation = recognizer.translation(in: view)

        switch recognizer.state {
        case .began:
            previousTranslation = translation // TODO: Revisit and decide if fallthrough is needed.
        case .changed:
            moveViews(by: CGPoint(x: translation.x - previousTranslation.x, y: translation.y - previousTranslation.y))
        case .ended, .failed, .cancelled:
            let velocity = recognizer.velocity(in: view)
            print("Terminal velocity : ", velocity)

            // TODO:
            if velocity.x < 0.0 {

            } else {

            }
        default:
            break
        }

        previousTranslation = translation
    }
}

// MARK: - Updating View Positions

extension MediaBrowserViewController {

    private func moveViews(by translation: CGPoint) {

        print("Translation registered : ", translation)

        let viewSizeIncludingGap = CGSize(
            width: view.frame.size.width + gapBetweenMediaViews,
            height: view.frame.size.height + gapBetweenMediaViews
        )

        let normalizedTranslation = CGPoint(
            x: (translation.x)/viewSizeIncludingGap.width,
            y: (translation.y)/viewSizeIncludingGap.height
        )
        contentViews.forEach({
            $0.position += (gestureDirection == .horizontal ? normalizedTranslation.x : normalizedTranslation.y)
        })

        var viewsCopy = contentViews
        let leftView = viewsCopy.removeFirst()
        let middleView = viewsCopy.removeFirst()
        let rightView = viewsCopy.removeFirst()

        let viewSize = (gestureDirection == .horizontal) ? viewSizeIncludingGap.width : viewSizeIncludingGap.height

        let normalizedGap = gapBetweenMediaViews/viewSize
        let normalizedCenter = (middleView.frame.size.width / viewSize) * 0.5

        let viewCount = contentViews.count

        if middleView.position < -(normalizedGap + normalizedCenter) {

            // Left item is taken and placed on right most side
            leftView.position += CGFloat(viewCount)
            leftView.index += viewCount

            contentViews.removeFirst()
            contentViews.append(leftView)

        } else if middleView.position > (1 + normalizedGap - normalizedCenter) {

            // Right item is taken and placed on left most side
            rightView.position -= CGFloat(viewCount)
            rightView.index -= viewCount

            contentViews.removeLast()
            contentViews.insert(rightView, at: 0)
        }
    }
}