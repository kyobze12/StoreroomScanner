import ARKit
import RealityKit
import SwiftData
import SwiftUI
import UIKit

@main
struct StoreroomScannerApp: App {
    var body: some Scene {
        WindowGroup { RootTabsView() }
            .modelContainer(for: StoreItem.self)
    }
}

struct RootTabsView: View {
    var body: some View {
        TabView {
            CameraScanView().tabItem { Label("Camera", systemImage: "camera.viewfinder") }
            InventoryView().tabItem { Label("Search", systemImage: "magnifyingglass") }
            SplatPreviewView().tabItem { Label("Splat", systemImage: "sparkles") }
        }
        .tint(.mint)
    }
}

@Model
final class StoreItem {
    var name: String
    var category: String
    var quantity: Int
    var level: Int
    var bay: String
    var shelf: Int
    var bin: String
    var notes: String

    init(name: String, category: String = "Other", quantity: Int = 1, level: Int = 1, bay: String = "A", shelf: Int = 1, bin: String = "", notes: String = "") {
        self.name = name
        self.category = category
        self.quantity = quantity
        self.level = level
        self.bay = bay
        self.shelf = shelf
        self.bin = bin
        self.notes = notes
    }

    var location: String {
        "Level \(level) · Bay \(bay) · Shelf \(shelf)" + (bin.isEmpty ? "" : " · \(bin)")
    }
}

struct CameraScanView: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            ARCameraSurface().ignoresSafeArea()
            VStack(spacing: 8) {
                Text("LEVEL 1").font(.caption.bold()).tracking(2)
                Text("AR camera is running").font(.headline)
                Text("This prototype checks the native ARKit build path.")
                    .font(.caption).foregroundStyle(.secondary)
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial)
        }
        .preferredColorScheme(.dark)
    }
}

private struct ARCameraSurface: UIViewRepresentable {
    func makeUIView(context: Context) -> ARView {
        let view = ARView(frame: .zero)
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            config.sceneReconstruction = .mesh
        }
        view.session.run(config)
        return view
    }

    func updateUIView(_ view: ARView, context: Context) {}

    static func dismantleUIView(_ view: ARView, coordinator: ()) {
        view.session.pause()
    }
}

struct InventoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [StoreItem]
    @State private var search = ""
    @State private var newName = ""

    private var filtered: [StoreItem] {
        search.isEmpty ? items : items.filter {
            "\($0.name) \($0.category) \($0.location) \($0.notes)"
                .localizedCaseInsensitiveContains(search)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                if filtered.isEmpty {
                    ContentUnavailableView("No items", systemImage: "shippingbox", description: Text("Use Add to enter your first item."))
                }
                ForEach(filtered) { item in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(item.name).font(.headline)
                            Spacer()
                            Text("×\(item.quantity)")
                        }
                        Text("\(item.category) · \(item.location)")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                }
                .onDelete { offsets in
                    for index in offsets { modelContext.delete(filtered[index]) }
                }
            }
            .searchable(text: $search, prompt: "Search items or locations")
            .navigationTitle("Storeroom")
            .safeAreaInset(edge: .bottom) {
                HStack {
                    TextField("Quick add item name", text: $newName)
                    Button("Add", action: addItem)
                        .disabled(newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding()
                .background(.bar)
            }
        }
    }

    private func addItem() {
        let value = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty else { return }
        modelContext.insert(StoreItem(name: value))
        newName = ""
    }
}

struct SplatPreviewView: View {
    @Query private var items: [StoreItem]

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    Color(red: 0.035, green: 0.055, blue: 0.08).ignoresSafeArea()
                    ForEach(1...4, id: \.self) { level in
                        Text("LEVEL \(level)")
                            .font(.caption2.bold())
                            .foregroundStyle(.white.opacity(0.35))
                            .position(x: 48, y: CGFloat(5 - level) * geometry.size.height / 5 + 24)
                    }
                    ForEach(items.indices, id: \.self) { index in
                        let item = items[index]
                        VStack(spacing: 3) {
                            ZStack {
                                Circle().fill(.mint.opacity(0.15)).frame(width: 80, height: 80).blur(radius: 10)
                                ForEach(0..<20, id: \.self) { dot in
                                    let angle = Double(dot) * 2.4 + Double(index)
                                    Circle().fill(.mint.opacity(0.65))
                                        .frame(width: 3, height: 3)
                                        .offset(x: cos(angle) * CGFloat(6 + dot % 19), y: sin(angle) * CGFloat(6 + dot % 19))
                                }
                                Circle().fill(.white).frame(width: 4, height: 4).shadow(color: .mint, radius: 7)
                            }
                            Text(item.name).font(.caption2).lineLimit(1)
                        }
                        .position(x: geometry.size.width * (0.22 + CGFloat(index % 5) * 0.14),
                                  y: geometry.size.height * (CGFloat(5 - item.level) / 4 + CGFloat(index % 3) * 0.04))
                    }
                    if items.isEmpty { Text("Add items to see their clouds").foregroundStyle(.secondary) }
                }
            }
            .navigationTitle("Splat view")
            .preferredColorScheme(.dark)
        }
    }
}

