import SwiftUI
import Photos

struct FilterSelectionView: View {
    @Binding var filter: SessionFilter
    @Environment(\.dismiss) private var dismiss

    @State private var albums: [PHAssetCollection] = []
    @State private var trips: [Trip] = []
    @State private var allAssets: [PHAsset] = []
    @State private var isLoading = true

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Loading…")
                } else {
                    List {
                        Section("Quick Filter") {
                            Button("All photos (no filter)") {
                                filter = SessionFilter()
                                dismiss()
                            }
                        }

                        if !trips.isEmpty {
                            Section("Trips") {
                                ForEach(trips) { trip in
                                    Button {
                                        filter.trip = trip
                                        filter.album = nil
                                        dismiss()
                                    } label: {
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text(trip.name).fontWeight(.medium)
                                                Text("\(trip.assetCount) photos").font(.caption).foregroundStyle(.secondary)
                                            }
                                            Spacer()
                                            if filter.trip?.id == trip.id {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        if !albums.isEmpty {
                            Section("Albums") {
                                ForEach(albums, id: \.localIdentifier) { album in
                                    Button {
                                        filter.album = album
                                        filter.trip = nil
                                        dismiss()
                                    } label: {
                                        HStack {
                                            Text(album.localizedTitle ?? "Album")
                                            Spacer()
                                            if filter.album?.localIdentifier == album.localizedTitle {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Filter Photos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .task {
                await loadData()
            }
        }
    }

    private func loadData() async {
        let service = PhotoLibraryService()
        let fetched = await service.fetchRecentMedia(limit: 500)
        allAssets = fetched
        trips = TripDetector.detectTrips(from: fetched)

        let albumOptions = PHFetchOptions()
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil)
        let userAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
        var all: [PHAssetCollection] = []
        smartAlbums.enumerateObjects { col, _, _ in all.append(col) }
        userAlbums.enumerateObjects { col, _, _ in all.append(col) }
        albums = all.filter { $0.estimatedAssetCount > 0 }

        isLoading = false
    }
}
