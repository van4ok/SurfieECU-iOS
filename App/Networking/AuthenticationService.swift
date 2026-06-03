import Foundation
import Security

final class AuthenticationService {
    private let keychain = KeychainStore(service: "com.surfie.ecu")

    func loadToken() -> String? {
        keychain.read(key: "authToken")
    }

    func saveToken(_ token: String) {
        keychain.save(token, key: "authToken")
    }

    func clearToken() {
        keychain.delete(key: "authToken")
    }
}
