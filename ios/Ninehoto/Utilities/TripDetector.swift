import Foundation
import CoreLocation
import Photos

struct TripDetector {
    static func detectTrips(from assets: [PHAsset]) -> [Trip] {
        let sorted = assets
            .filter { $0.creationDate != nil }
            .sorted { ($0.creationDate ?? .distantPast) < ($1.creationDate ?? .distantPast) }

        guard !sorted.isEmpty else { return [] }

        var trips: [Trip] = []
        var current: [PHAsset] = [sorted[0]]

        for i in 1..<sorted.count {
            let prev = sorted[i - 1]
            let curr = sorted[i]

            let dateGap = (curr.creationDate!.timeIntervalSince(prev.creationDate!)) / 3600
            let locationGap = locationDistance(prev, curr) / 1000

            if dateGap < 48 && locationGap < 50 {
                current.append(curr)
            } else {
                if let trip = makeTrip(from: current) { trips.append(trip) }
                current = [curr]
            }
        }

        if let trip = makeTrip(from: current) { trips.append(trip) }
        return trips
    }

    private static func makeTrip(from assets: [PHAsset]) -> Trip? {
        guard !assets.isEmpty, let start = assets.first?.creationDate, let end = assets.last?.creationDate else {
            return nil
        }

        let coords = assets.compactMap(\.location).filter { $0.coordinate.latitude != 0 || $0.coordinate.longitude != 0 }
        let center = coordinateCenter(of: coords)
        let name = tripName(for: center, startDate: start)

        return Trip(
            id: "trip_\(start.timeIntervalSince1970)",
            name: name,
            dateRange: start...end,
            centerCoordinate: center,
            assetCount: assets.count
        )
    }

    private static func locationDistance(_ a: PHAsset, _ b: PHAsset) -> Double {
        guard let locA = a.location, let locB = b.location else { return 0 }
        return locA.distance(from: locB)
    }

    private static func coordinateCenter(of coordinates: [CLLocation]) -> CLLocationCoordinate2D? {
        guard !coordinates.isEmpty else { return nil }
        let lat = coordinates.map(\.coordinate.latitude).reduce(0, +) / Double(coordinates.count)
        let lon = coordinates.map(\.coordinate.longitude).reduce(0, +) / Double(coordinates.count)
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }

    private static func tripName(for coordinate: CLLocationCoordinate2D?, startDate: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        let dateStr = formatter.string(from: startDate)
        return "Trip · \(dateStr)"
    }
}
