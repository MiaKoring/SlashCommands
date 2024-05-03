import Foundation

///Datatypes that can be used in commands
public enum CommandParameterDatatype: String, Equatable, Codable {
    case int
    case string
    case double
    case bool
}
