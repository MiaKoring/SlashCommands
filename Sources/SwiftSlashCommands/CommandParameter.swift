import Foundation

///a parameter of a command
///used /commandname parametername: value
public struct CommandParameter {
    ///to sort parameters
    var id: Int
    
    ///parametername
    ///used /commandname parametername: value
    var name: String
    
    ///the expected datatype
    var datatype: CommandParameterDatatype
    
    ///is the parameter required to execute the command
    var required: Bool
}
