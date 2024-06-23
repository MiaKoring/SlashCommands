import Foundation

///to create and use commands with this library
///they must conform to this protocol
public protocol Command: Identifiable {
    
    var id: UUID { get }
    
    var userAccessible: Bool { get }
    
    ///commandname, used /commandname
    var command: String { get }
    
    var description: String { get }
    
    ///command parameters, used /commandname parameter: value
    var parameters: [CommandParameter] { get }
    
    ///the least permission a user needs see and execute that command
    var minPermissions: Permission { get }
    
    ///the app that owns the command, only used to differentiate commands with the same name
    var commandOwner: String { get }
    
    ///gets called when executing
    var completion: ([String: Any])-> Void { get }
}
