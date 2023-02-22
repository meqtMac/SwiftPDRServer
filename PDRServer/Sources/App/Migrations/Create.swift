import Fluent

struct CreatePDRDateBase: AsyncMigration {
    
    func prepare(on database: Database) async throws {
        // prepare positions schema
        try await database.schema("positions")
            .id()
            .field("x", .double, .required)
            .field("y", .double, .required)
            .field("z", .double, .required)
            .field("stay", .bool, .required)
            .field("timestamp", .int, .required)
            .field("sampleTime", .datetime, .required)
            .field("sampleBatch", .int, .required)
            .create()

        // prepare runnings schema
        try await database.schema("runnings")
            .id()
            .field("accx", .double, .required)
            .field("accy", .double, .required)
            .field("accz", .double, .required)
            .field("gyroscopex", .double, .required)
            .field("gyroscopey", .double, .required)
            .field("gyroscopez", .double, .required)
            .field("stay", .bool, .required)
            .field("timestamp", .int, .required)
            .field("sampleTime", .datetime, .required)
            .field("sampleBatch", .int, .required)
            .create()
        
        try await Position.load(on: database)
        try await Running.load(on: database)
    }

    func revert(on database: Database) async throws {
        try await database.schema("runnings").delete()
        try await database.schema("positions").delete()
    }
}
