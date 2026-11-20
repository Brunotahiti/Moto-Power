import Foundation
import SwiftData
import MotoCore

/// Une moto du garage. Son compteur kilométrique part de la valeur saisie
/// et augmente avec chaque trajet enregistré à son nom.
@Model
final class Moto {
    var uid: String
    var name: String
    /// Marque et modèle, par exemple « Yamaha XMAX 300 » : sert aux classements.
    var model: String
    var startOdometerKm: Double
    var createdAt: Date

    init(name: String, model: String, startOdometerKm: Double) {
        self.uid = UUID().uuidString
        self.name = name
        self.model = model
        self.startOdometerKm = startOdometerKm
        self.createdAt = Date()
    }

    /// Kilométrage actuel : départ + trajets enregistrés avec cette moto.
    func odometerKm(trips: [TripRecord]) -> Double {
        let ridden: Double = trips.filter { $0.motoID == uid }.reduce(0) { $0 + $1.distanceMeters } / 1000
        return startOdometerKm + ridden
    }

    /// Nom affiché : le nom donné, sinon le modèle.
    var displayName: String {
        let trimmed: String = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty { return trimmed }
        return model.isEmpty ? L("Ma moto") : model
    }
}

/// Une opération d'entretien suivie pour une moto.
@Model
final class MaintenanceTask {
    var uid: String
    var motoID: String
    var kindRaw: String
    /// Nom libre pour une opération personnalisée.
    var title: String
    var intervalKm: Double?
    var intervalMonths: Int?
    var lastDoneKm: Double
    var lastDoneDate: Date

    init(motoID: String, kind: MaintenanceKind, title: String = "", lastDoneKm: Double, lastDoneDate: Date = Date()) {
        self.uid = UUID().uuidString
        self.motoID = motoID
        self.kindRaw = kind.rawValue
        self.title = title
        self.intervalKm = kind.defaultInterval.km
        self.intervalMonths = kind.defaultInterval.months
        self.lastDoneKm = lastDoneKm
        self.lastDoneDate = lastDoneDate
    }

    var kind: MaintenanceKind { MaintenanceKind(rawValue: kindRaw) ?? .custom }

    var displayTitle: String {
        kind == .custom && !title.isEmpty ? title : kind.title
    }

    func status(currentKm: Double, now: Date = Date()) -> MaintenanceStatus {
        MaintenanceStatus.compute(
            intervalKm: intervalKm, intervalMonths: intervalMonths, lastDoneKm: lastDoneKm,
            lastDoneDate: lastDoneDate, currentKm: currentKm, now: now)
    }
}

/// Un plein de carburant.
@Model
final class FuelEntry {
    var uid: String
    var motoID: String
    var date: Date
    var liters: Double
    var odometerKm: Double
    var price: Double?

    init(motoID: String, date: Date = Date(), liters: Double, odometerKm: Double, price: Double?) {
        self.uid = UUID().uuidString
        self.motoID = motoID
        self.date = date
        self.liters = liters
        self.odometerKm = odometerKm
        self.price = price
    }
}

extension MaintenanceKind {
    var title: String {
        switch self {
        case .oil: return L("Vidange")
        case .service: return L("Révision")
        case .rearTyre: return L("Pneu arrière")
        case .frontTyre: return L("Pneu avant")
        case .belt: return L("Kit chaîne")
        case .brakePads: return L("Plaquettes de frein")
        case .custom: return L("Autre entretien")
        }
    }

    var icon: String {
        switch self {
        case .oil: return "drop.fill"
        case .service: return "wrench.and.screwdriver.fill"
        case .rearTyre, .frontTyre: return "circle.circle"
        case .belt: return "link"
        case .brakePads: return "exclamationmark.octagon"
        case .custom: return "gearshape.fill"
        }
    }
}

/// Rappels d'entretien : une notification quand une opération arrive à échéance.
@MainActor
enum MaintenanceReminder {
    private static let notifiedKey = "maintenanceNotified"

    /// À appeler après un trajet : notifie une seule fois chaque échéance atteinte.
    static func check(moto: Moto, tasks: [MaintenanceTask], trips: [TripRecord]) {
        let km: Double = moto.odometerKm(trips: trips)
        var notified: Set<String> = Set(UserDefaults.standard.stringArray(forKey: notifiedKey) ?? [])
        for task in tasks where task.motoID == moto.uid {
            guard task.status(currentKm: km).state == .due else { continue }
            let key: String = task.uid + "-" + String(Int(task.lastDoneDate.timeIntervalSince1970))
            guard !notified.contains(key) else { continue }
            notified.insert(key)
            LocalNotifier.post(
                id: key, title: L("Entretien à prévoir"),
                body: L("\(task.displayTitle) : \(moto.displayName)"))
        }
        UserDefaults.standard.set(Array(notified), forKey: notifiedKey)
    }
}
