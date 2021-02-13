//
//  MapViewController.swift
//  CriticalMaps
//
//  Created by Leonard Thomas on 1/18/19.
//

import MapKit
import UIKit

class MapViewController: UIViewController {
    private let themeController: ThemeController
    private let friendsVerificationController: FriendsVerificationController
    private var tileRenderer: MKTileOverlayRenderer?
    private let nextRideManager: NextRideManager

    private let mapInfoViewController = MapInfoViewController.fromNib()

    init(
        themeController: ThemeController,
        friendsVerificationController: FriendsVerificationController,
        nextRideManager: NextRideManager
    ) {
        self.themeController = themeController
        self.friendsVerificationController = friendsVerificationController
        self.nextRideManager = nextRideManager

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Properties

    private lazy var annotationControllers: [AnnotationController] = {
        if #available(iOS 11.0, *) {
            return [
                BikeAnnotationController(mapView: self.mapView),
                CMMarkerAnnotationController(mapView: self.mapView)
            ]
        } else {
            return [
                BikeAnnotationController(mapView: self.mapView),
                CMAnnotationController(mapView: self.mapView)
            ]
        }
    }()

    private let nightThemeOverlay = DarkModeMapOverlay()
    public lazy var followMeButton: UserTrackingButton = {
        let button = UserTrackingButton(mapView: mapView)
        return button
    }()

    public var bottomContentOffset: CGFloat = 0 {
        didSet {
            mapView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: bottomContentOffset, right: 0)
        }
    }

    private var mapView = MKMapView(frame: .zero)

    private let gpsDisabledOverlayView: BlurryFullscreenOverlayView = {
        let view = BlurryFullscreenOverlayView.fromNib()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = L10n.mapTitle
        configureNotifications()
        configureTileRenderer()
        configureMapView()
        condfigureGPSDisabledOverlayView()
        registerAnnotationViews()
        setupMapInfoViewController()

        setNeedsStatusBarAppearanceUpdate()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if #available(iOS 13.0, *) {
            view.window?.windowScene?.screenshotService?.delegate = self
        }
    }

    private func registerAnnotationViews() {
        annotationControllers
            .map(\.annotationViewType)
            .forEach(mapView.register)
    }

    private func setupMapInfoViewController() {
        add(mapInfoViewController)
        mapInfoViewController.view.addLayoutsSameSizeAndOrigin(in: view)
        mapInfoViewController.tapHandler = { [unowned self] in
            self.nextRideManager.nextRide.flatMap { self.focusOnCoordinate($0.coordinate) }
        }
    }

    private func configureTileRenderer() {
        guard themeController.currentTheme == .dark else {
            if #available(iOS 13.0, *) {
                overrideUserInterfaceStyle = .light
            }
            return
        }

        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .dark
        } else {
            addTileRenderer()
        }
    }

    private func condfigureGPSDisabledOverlayView() {
        let gpsDisabledOverlayView = self.gpsDisabledOverlayView
        gpsDisabledOverlayView.set(title: L10n.mapLayerInfoTitle, message: L10n.mapLayerInfo)
        gpsDisabledOverlayView.addButtonTarget(self, action: #selector(didTapGPSDisabledOverlayButton))
        view.addSubview(gpsDisabledOverlayView)
        gpsDisabledOverlayView.addLayoutsSameSizeAndOrigin(in: view)
        updateGPSDisabledOverlayVisibility()
    }

    private func configureNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveInitialLocation(notification:)), name: .initialGpsDataReceived, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateGPSDisabledOverlayVisibility), name: .observationModeChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(themeDidChange), name: .themeDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveFocusNotification(notification:)), name: .focusLocation, object: nil)
    }

    private func configureMapView() {
        view.addSubview(mapView)
        mapView.addLayoutsSameSizeAndOrigin(in: view)
        mapView.showsPointsOfInterest = false
        mapView.delegate = self
        mapView.showsUserLocation = true
    }

    @objc func didTapGPSDisabledOverlayButton() {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
    }

    @objc func updateGPSDisabledOverlayVisibility() {
        gpsDisabledOverlayView.isHidden = LocationManager.accessPermission != .denied
    }

    // MARK: Notifications

    override var preferredStatusBarStyle: UIStatusBarStyle {
        themeController.currentTheme.style.statusBarStyle
    }

    @objc private func themeDidChange() {
        let theme = themeController.currentTheme
        guard theme == .dark else {
            if #available(iOS 13.0, *) {
                overrideUserInterfaceStyle = .light
            } else {
                removeTileRenderer()
            }
            return
        }
        configureTileRenderer()
    }

    private func removeTileRenderer() {
        tileRenderer = nil
        mapView.removeOverlay(nightThemeOverlay)
    }

    private func addTileRenderer() {
        tileRenderer = MKTileOverlayRenderer(tileOverlay: nightThemeOverlay)
        mapView.addOverlay(nightThemeOverlay, level: .aboveRoads)
    }

    private func getNextRide(_ coordinate: CLLocationCoordinate2D) {
        nextRideManager.getNextRide(around: coordinate) { result in
            switch result {
            case let .success(ride):
                onMain { [unowned self] in
                    self.annotationControllers.first(where: canBeCastedTo(CriticalMassAnnotation.self))
                        .flatMap {
                            if #available(iOS 11.0, *) {
                                guard let controller = $0 as? CMMarkerAnnotationController else {
                                    Logger.log(.debug, log: .map, "Controller expected to CMMarkerAnnotationController")
                                    return
                                }
                                controller.update([CriticalMassAnnotation(ride: ride)])
                            } else {
                                guard let controller = $0 as? CMAnnotationController else {
                                    Logger.log(.debug, log: .map, "Controller expected to CMAnnotationController")
                                    return
                                }
                                controller.update([CriticalMassAnnotation(ride: ride)])
                            }
                        }
                    self.mapInfoViewController.configureAndPresentMapInfoView(
                        title: ride.titleAndTime,
                        style: .info
                    )
                }
            case let .failure(error):
                PrintErrorHandler().handleError(error)
            }
        }
    }

    @objc func didReceiveInitialLocation(notification: Notification) {
        guard let location = notification.object as? Location else { return }
        let coordinate = CLLocationCoordinate2D(location)
        focusOnCoordinate(coordinate)
        getNextRide(coordinate)
    }

    @objc func didReceiveFocusNotification(notification: Notification) {
        guard let location = notification.object as? Location else { return }
        focusOnCoordinate(CLLocationCoordinate2D(location))
    }

    private func focusOnCoordinate(
        _ coordinate: CLLocationCoordinate2D,
        zoomArea: Double = 1000,
        animated: Bool = true
    ) {
        let region = MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: zoomArea,
            longitudinalMeters: zoomArea
        )
        let adjustedRegion = mapView.regionThatFits(region)
        mapView.setRegion(adjustedRegion, animated: animated)
    }
}

extension MapViewController: MKMapViewDelegate {
    // MARK: MKMapViewDelegate

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKUserLocation == false else {
            return nil
        }

        guard let matchingController = annotationControllers.first(where: { type(of: annotation) == $0.annotationType }) else {
            return nil
        }

        // TODO: Remove workaround when target > iOS10 since it does not seem to work with the MKMapView+Register extension
        if annotation is CriticalMassAnnotation {
            if #available(iOS 11.0, *) {
                return mapView.dequeueReusableAnnotationView(
                    withIdentifier: CMMarkerAnnotationView.reuseIdentifier,
                    for: annotation
                )
            } else {
                return mapView.dequeueReusableAnnotationView(withIdentifier: CMAnnotationView.reuseIdentifier) as? CMAnnotationView
                    ?? CMAnnotationView(
                        annotation: annotation,
                        reuseIdentifier: CMAnnotationView.reuseIdentifier
                    )
            }
        }

        return mapView.dequeueReusableAnnotationView(ofType: matchingController.annotationViewType, with: annotation)
    }

    func mapView(_: MKMapView, didChange mode: MKUserTrackingMode, animated _: Bool) {
        followMeButton.currentMode = UserTrackingButton.Mode(mode)
    }

    func mapView(_: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let renderer = tileRenderer else {
            return MKOverlayRenderer(overlay: overlay)
        }
        return renderer
    }
}

extension MapViewController: UIScreenshotServiceDelegate {
    @available(iOS 13.0, *)
    func screenshotService(_: UIScreenshotService, generatePDFRepresentationWithCompletion completionHandler: @escaping (Data?, Int, CGRect) -> Void) {
        let data = UIGraphicsPDFRenderer(bounds: view.bounds).pdfData { context in
            context.beginPage()

            self.mapView.drawHierarchy(in: self.view.bounds, afterScreenUpdates: true)
        }

        completionHandler(data, 0, view.bounds)
    }
}
