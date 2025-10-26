import Foundation

// MARK: - RandomUserResponse
public struct RandomUserResponse: Codable {
    public let results: [User]
    public let info: Info
}

// MARK: - Info
public struct Info: Codable {
    public let seed: String
    public let results: Int
    public let page: Int
    public let version: String
}

// MARK: - User
public struct User: Codable, Equatable {
    public let gender: String
    public let name: Name
    public let location: Location
    public let email: String
    public let login: Login
    public let dob: DateOfBirth
    public let registered: DateOfBirth
    public let phone: String
    public let cell: String
    public let id: ID
    public let picture: Picture
    public let nat: String
    
    // MARK: - Computed Properties
    public var fullName: String {
        return "\(name.title) \(name.first) \(name.last)"
    }
    
    public var fullAddress: String {
        return "\(location.street.number) \(location.street.name), \(location.city), \(location.state), \(location.country), \(location.postcode)"
    }
    
    public var age: Int {
        return dob.age
    }
    
    // Unique identifier for the user (using a combination of fields)
    public var uniqueID: String {
        return "\(email)_\(login.username)"
    }
    
    public static func == (lhs: User, rhs: User) -> Bool {
        return lhs.uniqueID == rhs.uniqueID
    }
}

// MARK: - DateOfBirth
public struct DateOfBirth: Codable {
    public let date: String
    public let age: Int
}

// MARK: - ID
public struct ID: Codable {
    public let name: String?
    public let value: String?
}

// MARK: - Location
public struct Location: Codable {
    public let street: Street
    public let city: String
    public let state: String
    public let country: String
    public let postcode: PostcodeType
    public let coordinates: Coordinates
    public let timezone: Timezone
    
    // Handle both String and Int postcodes
    public enum PostcodeType: Codable {
        case string(String)
        case int(Int)
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let stringValue = try? container.decode(String.self) {
                self = .string(stringValue)
            } else if let intValue = try? container.decode(Int.self) {
                self = .int(intValue)
            } else {
                throw DecodingError.typeMismatch(PostcodeType.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Postcode must be either String or Int"))
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .string(let stringValue):
                try container.encode(stringValue)
            case .int(let intValue):
                try container.encode(intValue)
            }
        }
        
        public var stringValue: String {
            switch self {
            case .string(let value):
                return value
            case .int(let value):
                return String(value)
            }
        }
    }
}

// MARK: - Coordinates
public struct Coordinates: Codable {
    public let latitude: String
    public let longitude: String
}

// MARK: - Street
public struct Street: Codable {
    public let number: Int
    public let name: String
}

// MARK: - Timezone
public struct Timezone: Codable {
    public let offset: String
    public let description: String
}

// MARK: - Login
public struct Login: Codable {
    public let uuid: String
    public let username: String
    public let password: String
    public let salt: String
    public let md5: String
    public let sha1: String
    public let sha256: String
}

// MARK: - Name
public struct Name: Codable {
    public let title: String
    public let first: String
    public let last: String
}

// MARK: - Picture
public struct Picture: Codable {
    public let large: String
    public let medium: String
    public let thumbnail: String
}
