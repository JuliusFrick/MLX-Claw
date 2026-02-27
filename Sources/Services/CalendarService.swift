import Foundation
import EventKit

struct CalendarEvent: Identifiable, Codable {
    let id: String
    let title: String
    let startDate: Date
    let endDate: Date
    let notes: String?
    let isAllDay: Bool

    init(id: String, title: String, startDate: Date, endDate: Date, notes: String?, isAllDay: Bool = false) {
        self.id = id
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.notes = notes
        self.isAllDay = isAllDay
    }

    init(from ekEvent: EKEvent) {
        self.id = ekEvent.eventIdentifier ?? UUID().uuidString
        self.title = ekEvent.title ?? "Untitled"
        self.startDate = ekEvent.startDate
        self.endDate = ekEvent.endDate
        self.notes = ekEvent.notes
        self.isAllDay = ekEvent.isAllDay
    }
}

enum CalendarError: LocalizedError {
    case accessDenied
    case accessRestricted
    case eventNotFound
    case saveFailed(String)
    case deleteFailed(String)
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .accessDenied:
            return "Calendar access was denied by the user"
        case .accessRestricted:
            return "Calendar access is restricted on this device"
        case .eventNotFound:
            return "The requested event could not be found"
        case .saveFailed(let reason):
            return "Failed to save event: \(reason)"
        case .deleteFailed(let reason):
            return "Failed to delete event: \(reason)"
        case .unknown(let reason):
            return "Unknown error: \(reason)"
        }
    }
}

final class CalendarService {
    private let eventStore = EKEventStore()
    private var hasFullAccess = false

    func requestAccess() async throws -> Bool {
        if #available(iOS 17.0, *) {
            let granted = try await eventStore.requestFullAccessToEvents()
            hasFullAccess = granted
            return granted
        } else {
            let granted = try await eventStore.requestAccess(to: .event)
            hasFullAccess = granted
            return granted
        }
    }

    func checkAuthorizationStatus() -> EKAuthorizationStatus {
        if #available(iOS 17.0, *) {
            return EKEventStore.authorizationStatus(for: .event)
        } else {
            return EKEventStore.authorizationStatus(for: .event)
        }
    }

    func createEvent(title: String, startDate: Date, endDate: Date, notes: String?) throws -> String {
        guard hasFullAccess || checkAuthorizationStatus() == .authorized else {
            throw CalendarError.accessDenied
        }

        let event = EKEvent(eventStore: eventStore)
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.notes = notes
        event.calendar = eventStore.defaultCalendarForNewEvents

        do {
            try eventStore.save(event, span: .thisEvent)
            guard let eventId = event.eventIdentifier else {
                throw CalendarError.saveFailed("No event ID returned")
            }
            return eventId
        } catch {
            throw CalendarError.saveFailed(error.localizedDescription)
        }
    }

    func listEvents(from startDate: Date, to endDate: Date) throws -> [CalendarEvent] {
        guard hasFullAccess || checkAuthorizationStatus() == .authorized else {
            throw CalendarError.accessDenied
        }

        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
        let ekEvents = eventStore.events(matching: predicate)

        return ekEvents.map { CalendarEvent(from: $0) }
    }

    func deleteEvent(id: String) throws -> Bool {
        guard hasFullAccess || checkAuthorizationStatus() == .authorized else {
            throw CalendarError.accessDenied
        }

        guard let event = eventStore.event(withIdentifier: id) else {
            throw CalendarError.eventNotFound
        }

        do {
            try eventStore.remove(event, span: .thisEvent)
            return true
        } catch {
            throw CalendarError.deleteFailed(error.localizedDescription)
        }
    }
}
