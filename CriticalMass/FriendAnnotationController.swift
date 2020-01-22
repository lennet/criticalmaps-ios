//
//  FriendAnnotationController.swift
//  CriticalMaps
//
//  Created by Leonard Thomas on 22.01.20.
//  Copyright © 2020 Pokus Labs. All rights reserved.
//

import MapKit

class FriendAnnotation: IdentifiableAnnnotation {}

class FriendAnnotationController: AnnotationController<FriendAnnotation, FriendAnnotationView> {
    private var friendsVerificationController: FriendsVerificationController

    init(friendsVerificationController: FriendsVerificationController, mapView: MKMapView) {
        self.friendsVerificationController = friendsVerificationController
        super.init(mapView: mapView)
    }

    required init(mapView _: MKMapView) {
        fatalError("init(mapView:) has not been implemented")
    }

    public override func setup() {
        NotificationCenter.default.addObserver(self, selector: #selector(positionsDidChange(notification:)), name: Notification.positionOthersChanged, object: nil)
    }

    @objc private func positionsDidChange(notification: Notification) {
        guard let response = notification.object as? ApiResponse else { return }
        display(locations: response.locations)
    }

    private func display(locations: [String: Location]) {
        guard Feature.friends.isActive else {
            return
        }
        guard LocationManager.accessPermission == .authorized else {
            Logger.log(.info, log: .map, "Bike annotations cannot be displayed because no GPS Access permission granted", parameter: LocationManager.accessPermission.rawValue)
            return
        }
        let filtredLocations = locations.filter { friendsVerificationController.isFriend(id: $0.key) }
        updateAnnotations(locations: filtredLocations)
    }
}