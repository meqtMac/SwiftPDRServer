import Fluent
import FluentMySQLDriver
import Vapor

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    var tls = TLSConfiguration.makeClientConfiguration()
    tls.certificateVerification = .none

    app.databases.use(.mysql(
        hostname: "127.0.0.1",
        port: 3306,
        username: "root",
        password: "PfD2BtG3mqk897Y",
        database: "vapor_database",
        tlsConfiguration: tls
    ), as: .mysql)

    app.migrations.add(CreatePDRDateBase())

    app.http.server.configuration.hostname = "0.0.0.0"
    app.http.server.configuration.port = 8080

    // register routes
    try routes(app)
}
