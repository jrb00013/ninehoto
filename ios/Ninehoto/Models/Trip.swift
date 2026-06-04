import Foundation
import CoreLocation
import Photos

struct Trip: Identifiable, Equatable {
    let id: String
    let name: String
    let dateRange: ClosedRange<Date>
    let centerCoordinate: CLLocationCoordinate2D?
    let assetCount: Int

    static func == (lhs: Trip, rhs: Trip) -> Bool {
        lhs.id == rhs.id
    }
}

struct SessionFilter {
    var album: PHAssetCollection?
    var trip: Trip?
    var dateRange: ClosedRange<Date>?
    var locationRadius: (center: CLLocation, radius: Double)?

    var isActive: Bool {
        album != nil || trip != nil || dateRange != nil || locationRadius != nil
    }

    var label: String {
        if let trip = trip { return trip.name }
        if let album = album { return album.localizedTitle ?? "Album" }
        return "All photos"
    }
}
