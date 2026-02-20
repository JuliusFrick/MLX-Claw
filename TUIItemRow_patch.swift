// MARK: - TUI Item Row (patched — Popup statt inline expand für Kalender-Events)

struct TUIItemRow: View {
    let item: BriefingItem
    @State private var isHovered = false
    @State private var isExpanded = false
    @State private var showMeetingPopup = false          // ← NEU
    @StateObject private var notesService = MeetingNotesService.shared
    @State private var meetingNotes: String?

    // Kalender-Event erkennen
    private var isMeetingEvent: Bool {
        item.timestamp != nil || item.metadata["meetingLink"] != nil
    }

    var body: some View {
        VStack(spacing: 0) {
            Button {
                if isMeetingEvent {
                    showMeetingPopup = true              // ← NEU: Popup öffnen
                } else if hasDetails {
                    withAnimation(.tuiSnappy) {
                        isExpanded.toggle()
                    }
                } else if let url = item.deepLink {
                    NSWorkspace.shared.open(url)
                }
            } label: {
                HStack(spacing: Spacing.sm) {
                    Text(priorityChar)
                        .font(.tuiMonoTiny)
                        .foregroundStyle(priorityColor)
                        .frame(width: 12)

                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: Spacing.xs) {
                            Text(item.title)
                                .font(.tuiMonoSmall)
                                .foregroundStyle(.primary)
                                .lineLimit(1)

                            if let duration = item.metadata["duration"] {
                                Text("[\(duration)]")
                                    .font(.tuiMonoTiny)
                                    .foregroundStyle(.quaternary)
                            }
                        }

                        if let subtitle = item.subtitle {
                            Text(subtitle)
                                .font(.tuiMonoTiny)
                                .foregroundStyle(.tertiary)
                                .lineLimit(1)
                        }
                    }

                    Spacer()

                    if item.metadata["meetingLink"] != nil {
                        Text("📹")
                            .font(.tuiMonoTiny)
                    }

                    if meetingNotes?.isEmpty == false || item.metadata["meetingNotes"]?.isEmpty == false {
                        Text("📝")
                            .font(.tuiMonoTiny)
                    }

                    // Pfeil-Indikator
                    if isMeetingEvent {
                        Text("→")                        // ← Kalender-Events zeigen immer den Pfeil
                            .font(.tuiMonoTiny)
                            .foregroundStyle(.quaternary)
                            .opacity(isHovered ? 1 : 0.4)
                    } else if hasDetails {
                        Text(isExpanded ? "▼" : "▶")
                            .font(.tuiMonoTiny)
                            .foregroundStyle(.quaternary)
                    } else if item.deepLink != nil {
                        Text("→")
                            .font(.tuiMonoTiny)
                            .foregroundStyle(.quaternary)
                            .opacity(isHovered ? 1 : 0)
                    }
                }
                .padding(.horizontal, Spacing.md)
                .padding(.leading, Spacing.lg)
                .padding(.vertical, Spacing.xs)
                .background(isHovered ? Color.tuiHover : Color.clear)
            }
            .buttonStyle(.plain)
            .onHover { isHovered = $0 }
            .animation(.tuiFast, value: isHovered)
            .onAppear { loadMeetingNotes() }
            .onReceive(NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)) { _ in
                loadMeetingNotes()
            }
            // ← NEU: Popup-Sheet
            .sheet(isPresented: $showMeetingPopup) {
                MeetingDetailPopup(meeting: item, isPresented: $showMeetingPopup)
            }

            // Inline-Details nur für Nicht-Meeting-Items
            if isExpanded && !isMeetingEvent {
                expandedDetails
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .top)),
                        removal: .opacity
                    ))
            }
        }
    }

    // ... rest (hasDetails, loadMeetingNotes, expandedDetails, priorityChar, priorityColor) bleibt identisch
}
