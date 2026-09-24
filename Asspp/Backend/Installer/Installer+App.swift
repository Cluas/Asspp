//
//  Installer+App.swift
//  Asspp
//
//  Created by 秋星桥 on 2024/7/11.
//

import Foundation
import Vapor

extension Installer {
    private static let env: Environment = {
        var env = try! Environment.detect()
        try! LoggingSystem.bootstrap(from: &env)
        return env
    }()

    static func setupApp(port: Int, secured: Bool) async throws -> Application {
        let app = try await Application.make()

        app.threadPool = .init(numberOfThreads: 1)

        if secured { app.http.server.configuration.tlsConfiguration = try Self.setupTLS() }
        app.http.server.configuration.hostname = Self.sni
        app.http.server.configuration.tcpNoDelay = true

        // Only the TLS server needs to be reachable by name; the plain-HTTP
        // payload and CA servers are fetched from this device via 127.0.0.1.
        app.http.server.configuration.address = .hostname(secured ? "0.0.0.0" : "127.0.0.1", port: port)
        app.http.server.configuration.port = port

        app.routes.defaultMaxBodySize = "128mb"
        app.routes.caseInsensitive = false

        return app
    }
}
