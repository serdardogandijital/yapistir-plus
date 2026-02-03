import SwiftUI
import Carbon
import AppKit
import Combine

// MARK: - Data Model
struct MetinItem: Codable, Identifiable {
    var id = UUID()
    var kisayol: Int
    var metin: String
}

// MARK: - Data Manager
class MetinManager: ObservableObject {
    @Published var metinler: [MetinItem] = []

    private var configURL: URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appFolder = appSupport.appendingPathComponent("YapistirPlus")
        try? FileManager.default.createDirectory(at: appFolder, withIntermediateDirectories: true)
        return appFolder.appendingPathComponent("metinler.json")
    }

    init() {
        yukle()
        if metinler.isEmpty {
            metinler = [
                MetinItem(kisayol: 1, metin: "Selamlar, teklifimizi değerlendirdiniz mi?"),
                MetinItem(kisayol: 2, metin: "Merhaba, siparişiniz kargoya verilmiştir."),
                MetinItem(kisayol: 3, metin: "Teşekkürler, iyi günler dileriz."),
                MetinItem(kisayol: 4, metin: "Detaylı bilgi için bizimle iletişime geçebilirsiniz."),
                MetinItem(kisayol: 5, metin: "Fiyat teklifimiz ektedir.")
            ]
            kaydet()
        }
    }

    func yukle() {
        guard let data = try? Data(contentsOf: configURL),
              let loaded = try? JSONDecoder().decode([MetinItem].self, from: data) else { return }
        metinler = loaded.sorted { $0.kisayol < $1.kisayol }
    }

    func kaydet() {
        metinler.sort { $0.kisayol < $1.kisayol }
        guard let data = try? JSONEncoder().encode(metinler) else { return }
        try? data.write(to: configURL)
    }

    func ekle() {
        let yeniKisayol = (metinler.map { $0.kisayol }.max() ?? 0) + 1
        metinler.append(MetinItem(kisayol: yeniKisayol, metin: "Yeni metin..."))
        kaydet()
    }

    func sil(_ item: MetinItem) {
        metinler.removeAll { $0.id == item.id }
        kaydet()
    }

    func yapistir(_ kisayol: Int) {
        guard let item = metinler.first(where: { $0.kisayol == kisayol }) else { return }

        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(item.metin, forType: .string)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            let src = CGEventSource(stateID: .hidSystemState)
            let keyDown = CGEvent(keyboardEventSource: src, virtualKey: 0x09, keyDown: true)
            let keyUp = CGEvent(keyboardEventSource: src, virtualKey: 0x09, keyDown: false)
            keyDown?.flags = .maskCommand
            keyUp?.flags = .maskCommand
            keyDown?.post(tap: .cghidEventTap)
            keyUp?.post(tap: .cghidEventTap)
        }
    }
}

// MARK: - Hotkey Manager
class HotkeyManager {
    static let shared = HotkeyManager()
    private var hotKeyRefs: [EventHotKeyRef?] = []
    var onHotkey: ((Int) -> Void)?

    private init() {
        setupEventHandler()
    }

    private func setupEventHandler() {
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        InstallEventHandler(GetApplicationEventTarget(), { (_, event, _) -> OSStatus in
            var hotKeyID = EventHotKeyID()
            GetEventParameter(event, EventParamName(kEventParamDirectObject), EventParamType(typeEventHotKeyID), nil, MemoryLayout<EventHotKeyID>.size, nil, &hotKeyID)
            HotkeyManager.shared.onHotkey?(Int(hotKeyID.id))
            return noErr
        }, 1, &eventType, nil, nil)
    }

    func registerHotkeys(count: Int) {
        for ref in hotKeyRefs {
            if let r = ref { UnregisterEventHotKey(r) }
        }
        hotKeyRefs.removeAll()

        let keyCodes: [UInt32] = [18, 19, 20, 21, 23, 22, 26, 28, 25]

        for i in 0..<min(count, 9) {
            var hotKeyRef: EventHotKeyRef?
            let hotKeyID = EventHotKeyID(signature: OSType(0x59505053), id: UInt32(i + 1))
            let status = RegisterEventHotKey(keyCodes[i], UInt32(optionKey), hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef)
            if status == noErr {
                hotKeyRefs.append(hotKeyRef)
            }
        }
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @ObservedObject var manager: MetinManager
    @State private var showingAbout = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Yapıştır+")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)

                Spacer()

                Button(action: { showingAbout = true }) {
                    Image(systemName: "info.circle")
                        .font(.title3)
                }
                .buttonStyle(.plain)
                .foregroundColor(.secondary)

                Button(action: { manager.ekle() }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
                .buttonStyle(.plain)
                .foregroundColor(.blue)
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))

            Divider()

            // Liste
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach($manager.metinler) { $item in
                        MetinRowView(item: $item, onDelete: {
                            manager.sil(item)
                        }, onSave: {
                            manager.kaydet()
                        })
                    }
                }
                .padding()
            }

            Divider()

            // Footer
            HStack {
                Image(systemName: "keyboard")
                    .foregroundColor(.secondary)
                Text("Option (⌥) + numara ile yapıştır")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(8)
            .background(Color(NSColor.windowBackgroundColor))
        }
        .frame(width: 450, height: 420)
        .sheet(isPresented: $showingAbout) {
            AboutView()
        }
    }
}

// MARK: - About View
struct AboutView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(LinearGradient(
                        colors: [Color.blue, Color.purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 80, height: 80)

                Text("Y+")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            .padding(.top, 20)

            Text("Yapıştır+")
                .font(.system(size: 24, weight: .bold))

            Text("Versiyon 1.0")
                .font(.caption)
                .foregroundColor(.secondary)

            Divider()
                .padding(.horizontal, 40)

            VStack(spacing: 8) {
                Text("Geliştirici")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text("Serdar DOĞAN")
                    .font(.headline)

                Link("serdardogan.com.tr", destination: URL(string: "https://serdardogan.com.tr")!)
                    .font(.system(size: 14))

                Link("GitHub: github.com/serdardogan/yapistir-plus", destination: URL(string: "https://github.com/serdardogan/yapistir-plus")!)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text("Kısayollarla hızlı metin yapıştırma aracı")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button("Tamam") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .padding(.bottom, 20)
        }
        .frame(width: 300, height: 350)
    }
}

struct MetinRowView: View {
    @Binding var item: MetinItem
    var onDelete: () -> Void
    var onSave: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack {
                Text("⌥+\(item.kisayol)")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(LinearGradient(
                        colors: [Color.blue, Color.purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                    .cornerRadius(6)
            }
            .frame(width: 55)

            VStack(alignment: .leading, spacing: 4) {
                TextEditor(text: $item.metin)
                    .font(.system(.body))
                    .frame(minHeight: 50, maxHeight: 80)
                    .padding(4)
                    .background(Color(NSColor.textBackgroundColor))
                    .cornerRadius(6)
                    .onChange(of: item.metin) { _ in
                        onSave()
                    }
            }

            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
            .buttonStyle(.plain)
        }
        .padding(10)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}

// MARK: - Window Controller
class SettingsWindowController: NSObject {
    var window: NSWindow?
    let manager: MetinManager

    init(manager: MetinManager) {
        self.manager = manager
        super.init()
    }

    func showWindow() {
        if let window = window {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let contentView = SettingsView(manager: manager)

        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 450, height: 420),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )

        window?.title = "Yapıştır+"
        window?.contentViewController = NSHostingController(rootView: contentView)
        window?.center()
        window?.isReleasedWhenClosed = false
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func toggleWindow() {
        if let window = window, window.isVisible {
            window.orderOut(nil)
        } else {
            showWindow()
        }
    }
}

// MARK: - App Delegate
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var manager = MetinManager()
    var windowController: SettingsWindowController!
    private var cancellables = Set<AnyCancellable>()

    func applicationDidFinishLaunching(_ notification: Notification) {
        windowController = SettingsWindowController(manager: manager)

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "doc.on.clipboard.fill", accessibilityDescription: "Yapıştır+")
            button.action = #selector(statusBarButtonClicked)
            button.target = self
        }

        HotkeyManager.shared.onHotkey = { [weak self] num in
            self?.manager.yapistir(num)
        }
        HotkeyManager.shared.registerHotkeys(count: manager.metinler.count)

        manager.$metinler.sink { items in
            HotkeyManager.shared.registerHotkeys(count: items.count)
        }.store(in: &cancellables)

        NSApp.setActivationPolicy(.accessory)
    }

    @objc func statusBarButtonClicked() {
        windowController.toggleWindow()
    }
}

// MARK: - Main
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
