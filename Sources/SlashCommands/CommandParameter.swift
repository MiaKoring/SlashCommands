import Foundation

///a parameter of a command
///used /commandname parametername: value
public struct CommandParameter {
    ///to sort parameters
    public var id: Int
    
    ///parametername
    ///used /commandname parametername: value
    public var name: String
    
    ///the expected datatype
    public var datatype: CommandParameterDatatype
    
    ///is the parameter required to execute the command
    public var required: Bool
    
    public init(id: Int, name: String, datatype: CommandParameterDatatype, required: Bool) {
        self.id = id
        self.name = name
        self.datatype = datatype
        self.required = required
    }
}
