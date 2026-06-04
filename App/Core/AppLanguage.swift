import Foundation

enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case russian = "ru"

    var id: String { rawValue }

    var shortTitle: String {
        switch self {
        case .english: "EN"
        case .russian: "RU"
        }
    }

    var title: String {
        switch self {
        case .english: "English"
        case .russian: "\u{0420}\u{0443}\u{0441}\u{0441}\u{043A}\u{0438}\u{0439}"
        }
    }

    var toggled: AppLanguage {
        switch self {
        case .english: .russian
        case .russian: .english
        }
    }

    static func from(_ rawValue: String) -> AppLanguage {
        AppLanguage(rawValue: rawValue) ?? .russian
    }
}

enum L10n {
    static func oilPer100KM(_ language: AppLanguage) -> String {
        switch language {
        case .english: "oil consumption (100/KM):"
        case .russian: "\u{0420}\u{0430}\u{0441}\u{0445}\u{043E}\u{0434} \u{0442}\u{043E}\u{043F}\u{043B}\u{0438}\u{0432}\u{0430} (100 \u{043A}\u{043C}):"
        }
    }

    static func oilPerHour(_ language: AppLanguage) -> String {
        switch language {
        case .english: "oil consumption (1/H):"
        case .russian: "\u{0420}\u{0430}\u{0441}\u{0445}\u{043E}\u{0434} \u{0442}\u{043E}\u{043F}\u{043B}\u{0438}\u{0432}\u{0430} (1 \u{0447}\u{0430}\u{0441}):"
        }
    }

    static func throttle(_ language: AppLanguage) -> String {
        switch language {
        case .english: "throttle valve:"
        case .russian: "\u{0414}\u{0440}\u{043E}\u{0441}\u{0441}\u{0435}\u{043B}\u{044C}:"
        }
    }

    static func inletTemperature(_ language: AppLanguage) -> String {
        switch language {
        case .english: "inlet temperature:"
        case .russian: "\u{0422}\u{0435}\u{043C}\u{043F}\u{0435}\u{0440}\u{0430}\u{0442}\u{0443}\u{0440}\u{0430} \u{0432}\u{043F}\u{0443}\u{0441}\u{043A}\u{0430}:"
        }
    }

    static func engineTemperature(_ language: AppLanguage) -> String {
        switch language {
        case .english: "engine temperature:"
        case .russian: "\u{0422}\u{0435}\u{043C}\u{043F}\u{0435}\u{0440}\u{0430}\u{0442}\u{0443}\u{0440}\u{0430} \u{0434}\u{0432}\u{0438}\u{0433}\u{0430}\u{0442}\u{0435}\u{043B}\u{044F}:"
        }
    }

    static func runningState(_ language: AppLanguage) -> String {
        switch language {
        case .english: "running state"
        case .russian: "\u{0421}\u{043E}\u{0441}\u{0442}\u{043E}\u{044F}\u{043D}\u{0438}\u{0435} \u{0441}\u{0438}\u{0441}\u{0442}\u{0435}\u{043C}\u{044B}"
        }
    }

    static func disconnect(_ language: AppLanguage) -> String {
        switch language {
        case .english: "Disconnect"
        case .russian: "\u{041E}\u{0442}\u{043A}\u{043B}."
        }
    }

    static func connected(_ language: AppLanguage) -> String {
        switch language {
        case .english: "Connected"
        case .russian: "\u{041F}\u{043E}\u{0434}\u{043A}\u{043B}\u{044E}\u{0447}\u{0435}\u{043D}\u{043E}"
        }
    }

    static func notConnected(_ language: AppLanguage) -> String {
        switch language {
        case .english: "Not connected"
        case .russian: "\u{041D}\u{0435} \u{043F}\u{043E}\u{0434}\u{043A}\u{043B}\u{044E}\u{0447}\u{0435}\u{043D}\u{043E}"
        }
    }

    static func ecuDataReceived(_ language: AppLanguage) -> String {
        switch language {
        case .english: "Surfie ECU data received"
        case .russian: "\u{041F}\u{043E}\u{043B}\u{0443}\u{0447}\u{0435}\u{043D}\u{044B} \u{0434}\u{0430}\u{043D}\u{043D}\u{044B}\u{0435} Surfie ECU"
        }
    }

    static func nonECUPackets(_ language: AppLanguage) -> String {
        switch language {
        case .english: "Connected, but packets do not look like Surfie ECU"
        case .russian: "\u{041F}\u{043E}\u{0434}\u{043A}\u{043B}\u{044E}\u{0447}\u{0435}\u{043D}\u{043E}, \u{043D}\u{043E} \u{043F}\u{0430}\u{043A}\u{0435}\u{0442}\u{044B} \u{043D}\u{0435} \u{043F}\u{043E}\u{0445}\u{043E}\u{0436}\u{0438} \u{043D}\u{0430} Surfie ECU"
        }
    }

    static func waitingForECU(_ language: AppLanguage) -> String {
        switch language {
        case .english: "Connected. Waiting for ECU data"
        case .russian: "\u{041F}\u{043E}\u{0434}\u{043A}\u{043B}\u{044E}\u{0447}\u{0435}\u{043D}\u{043E}. \u{041E}\u{0436}\u{0438}\u{0434}\u{0430}\u{043D}\u{0438}\u{0435} \u{0434}\u{0430}\u{043D}\u{043D}\u{044B}\u{0445} ECU"
        }
    }

    static func notifyNotFound(_ language: AppLanguage) -> String {
        switch language {
        case .english: "Connected. Notify characteristic was not found yet"
        case .russian: "\u{041F}\u{043E}\u{0434}\u{043A}\u{043B}\u{044E}\u{0447}\u{0435}\u{043D}\u{043E}. Notify-\u{0445}\u{0430}\u{0440}\u{0430}\u{043A}\u{0442}\u{0435}\u{0440}\u{0438}\u{0441}\u{0442}\u{0438}\u{043A}\u{0430} \u{043F}\u{043E}\u{043A}\u{0430} \u{043D}\u{0435} \u{043D}\u{0430}\u{0439}\u{0434}\u{0435}\u{043D}\u{0430}"
        }
    }

    static func notSurfieDevice(_ language: AppLanguage) -> String {
        switch language {
        case .english: "Does not look like Surfie ECU"
        case .russian: "\u{041D}\u{0435} \u{043F}\u{043E}\u{0445}\u{043E}\u{0436}\u{0435} \u{043D}\u{0430} Surfie ECU"
        }
    }

    static func faults(_ language: AppLanguage) -> [String] {
        switch language {
        case .english:
            [
                "trigger signal",
                "oxygen sensor",
                "low battery signal",
                "fuel injection output",
                "oil pump output",
                "ignition output",
                "throttle valve",
                "oil pump plug",
                "production fault 1",
                "production fault 2",
                "production fault 3",
                "production fault 4",
                "production fault 5",
                "production fault 6",
                "production fault 7",
                "production fault 8"
            ]
        case .russian:
            [
                "\u{0421}\u{0438}\u{0433}\u{043D}\u{0430}\u{043B} \u{0437}\u{0430}\u{043F}\u{0443}\u{0441}\u{043A}\u{0430}",
                "\u{041A}\u{0438}\u{0441}\u{043B}\u{043E}\u{0440}\u{043E}\u{0434}\u{043D}\u{044B}\u{0439} \u{0434}\u{0430}\u{0442}\u{0447}\u{0438}\u{043A}",
                "\u{0421}\u{0438}\u{0433}\u{043D}\u{0430}\u{043B} \u{043D}\u{0438}\u{0437}\u{043A}\u{043E}\u{0433}\u{043E} \u{0437}\u{0430}\u{0440}\u{044F}\u{0434}\u{0430}",
                "\u{0412}\u{044B}\u{0445}\u{043E}\u{0434} \u{0444}\u{043E}\u{0440}\u{0441}\u{0443}\u{043D}\u{043A}\u{0438}",
                "\u{0412}\u{044B}\u{0445}\u{043E}\u{0434} \u{0431}\u{0435}\u{043D}\u{0437}\u{043E}\u{043D}\u{0430}\u{0441}\u{043E}\u{0441}\u{0430}",
                "\u{0412}\u{044B}\u{0445}\u{043E}\u{0434} \u{0437}\u{0430}\u{0436}\u{0438}\u{0433}\u{0430}\u{043D}\u{0438}\u{044F}",
                "\u{0414}\u{0440}\u{043E}\u{0441}\u{0441}\u{0435}\u{043B}\u{044C}\u{043D}\u{0430}\u{044F} \u{0437}\u{0430}\u{0441}\u{043B}\u{043E}\u{043D}\u{043A}\u{0430}",
                "\u{0420}\u{0430}\u{0437}\u{044A}\u{0435}\u{043C} \u{0431}\u{0435}\u{043D}\u{0437}\u{043E}\u{043D}\u{0430}\u{0441}\u{043E}\u{0441}\u{0430}",
                "\u{041F}\u{0440}\u{043E}\u{0438}\u{0437}\u{0432}\u{043E}\u{0434}\u{0441}\u{0442}\u{0432}\u{0435}\u{043D}\u{043D}\u{0430}\u{044F} \u{043E}\u{0448}\u{0438}\u{0431}\u{043A}\u{0430} 1",
                "\u{041F}\u{0440}\u{043E}\u{0438}\u{0437}\u{0432}\u{043E}\u{0434}\u{0441}\u{0442}\u{0432}\u{0435}\u{043D}\u{043D}\u{0430}\u{044F} \u{043E}\u{0448}\u{0438}\u{0431}\u{043A}\u{0430} 2",
                "\u{041F}\u{0440}\u{043E}\u{0438}\u{0437}\u{0432}\u{043E}\u{0434}\u{0441}\u{0442}\u{0432}\u{0435}\u{043D}\u{043D}\u{0430}\u{044F} \u{043E}\u{0448}\u{0438}\u{0431}\u{043A}\u{0430} 3",
                "\u{041F}\u{0440}\u{043E}\u{0438}\u{0437}\u{0432}\u{043E}\u{0434}\u{0441}\u{0442}\u{0432}\u{0435}\u{043D}\u{043D}\u{0430}\u{044F} \u{043E}\u{0448}\u{0438}\u{0431}\u{043A}\u{0430} 4",
                "\u{041F}\u{0440}\u{043E}\u{0438}\u{0437}\u{0432}\u{043E}\u{0434}\u{0441}\u{0442}\u{0432}\u{0435}\u{043D}\u{043D}\u{0430}\u{044F} \u{043E}\u{0448}\u{0438}\u{0431}\u{043A}\u{0430} 5",
                "\u{041F}\u{0440}\u{043E}\u{0438}\u{0437}\u{0432}\u{043E}\u{0434}\u{0441}\u{0442}\u{0432}\u{0435}\u{043D}\u{043D}\u{0430}\u{044F} \u{043E}\u{0448}\u{0438}\u{0431}\u{043A}\u{0430} 6",
                "\u{041F}\u{0440}\u{043E}\u{0438}\u{0437}\u{0432}\u{043E}\u{0434}\u{0441}\u{0442}\u{0432}\u{0435}\u{043D}\u{043D}\u{0430}\u{044F} \u{043E}\u{0448}\u{0438}\u{0431}\u{043A}\u{0430} 7",
                "\u{041F}\u{0440}\u{043E}\u{0438}\u{0437}\u{0432}\u{043E}\u{0434}\u{0441}\u{0442}\u{0432}\u{0435}\u{043D}\u{043D}\u{0430}\u{044F} \u{043E}\u{0448}\u{0438}\u{0431}\u{043A}\u{0430} 8"
            ]
        }
    }
}
