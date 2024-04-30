import Foundation

///contains commands and handles execution
public final class CommandCollection {
    ///collection of commands
    var commands: [Command]
    
    public init(commands: [Command] = []) {
        self.commands = commands
    }
    
    ///returns all commands that start with the input
    public func commands(for string: String, highestPermission: Permission)throws -> [Command]{
        //if input doesn't start with "/", its not a valid command
        if string.first != "/" { return [] }
        
        //if input contains a newline, its not a valid command
        if string.contains("\n") { return [] }
        
        let cmdInput = commandName(for: string)
        
        //filter out commands by name and permission
        return commands.filter({
            $0.command.starts(with: cmdInput) && $0.minPermissions.rawValue <= highestPermission.rawValue
        })
    }
    
    public func execute(_ command: Command, with string: String, highestPermission: Permission)throws {
        if string.first != "/" { throw CommandError.missingSlash }
        if command.minPermissions.rawValue > highestPermission.rawValue { throw CommandError.insufficientPermissions }
        
        let commandName = commandName(for: string)
        
        if commandName != command.command { throw CommandError.invalidCommandnameForSelectedCommand }
        
        let required = requiredParams(of: command.parameters)
        
        //early execute if no parameters have to be parsed
        if command.parameters.isEmpty || ( required.isEmpty && !string.contains(":") ) {
            command.completion([:])
            return
        }
        
        //generate regex to extract parameters from command
        let regex = genCommandRegex(for: command)
        
        let matchRanges = try matchRanges(for: string, with: regex)
        let matches = matches(from: string, for: matchRanges)
        
        //throw .missingParameter if params are missing
        try checkRequiredExist(required, in: matches)
        
        let paramDictionary = try paramDictionary(for: matches, with: command.parameters)
        command.completion(paramDictionary)
    }
    
    private func commandName(for string: String)-> String{
        //remove slash
        var cmdInput = string.dropFirst()
        
        //get only command-name
        if cmdInput.contains(" "){
            let spaceIndex = cmdInput.firstIndex(of: " ")!
            cmdInput = cmdInput[cmdInput.startIndex ... cmdInput.index(before: spaceIndex)]
        }
        return String(cmdInput)
    }
    
    ///generate the regex to parse the parameters
    private func genCommandRegex(for command: Command)-> String {
        var closure = ""
        for i in 0 ..< command.parameters.count {
            closure += " \(command.parameters[i].name): "
            if i < command.parameters.count - 1 {
                closure += "|"
            }
        }
        return "(\(closure)).*?(?=\(closure)|$)"
    }
    
    private func matchRanges(for input: String, with regex: String)throws -> [Regex<AnyRegexOutput>.Match] {
        do{
            return try input.matches(of: Regex(regex))
        }
        catch{
            throw CommandError.regexFailed
        }
    }
    
    private func matches(from string: String, for range: [Regex<AnyRegexOutput>.Match])-> [String] {
        return range.map({matchRange in
            return string[matchRange.range].trimmingCharacters(in: .whitespacesAndNewlines)
        })
    }
    
    private func requiredParams(of params: [CommandParameter])-> [CommandParameter] {
        return params.compactMap{param in
            if param.required { return param }
            return nil
        }
    }
    
    private func checkRequiredExist(_ required: [CommandParameter], in matches: [String])throws {
        for require in required {
            if !matches.contains(where: {$0.starts(with: require.name)}){
                throw CommandError.missingParameter
            }
        }
    }
    
    ///tries to convert a value to the required type, returns on success
    private func paramValue(with type: CommandParameterDatatype, for valueString: String, named name: String)throws -> Any {
        switch type {
        case .int:
            guard let value = Int(valueString) else{
                throw CommandError.paramInvalidType(name)
            }
            return value
        case .string:
            return valueString
        case .double:
            guard let value = Double(valueString.replacingOccurrences(of: ",", with: ".")) else{
                throw CommandError.paramInvalidType(name)
            }
            return value
        case .bool:
            guard let value = Bool(valueString) else{
                throw CommandError.paramInvalidType(name)
            }
            return value
        }
    }
    
    private func paramDictionary(for matches: [String], with parameters: [CommandParameter])throws -> [String: Any] {
        var paramDictionary: [String: Any] = [:]
        
        for match in matches{
            let nameEndIndex = match.index(before: match.firstIndex(of: ":")!)
            
            //name of the parameter
            let name = String(match[match.startIndex...nameEndIndex])
            let type = parameters.first(where: {$0.name == name})!.datatype
            
            let valueStartIndex = match.index(match.firstIndex(of: ":")!, offsetBy: 2)
            let valueString = String(match[valueStartIndex ..< match.endIndex])
            
            let value = try paramValue(with: type, for: valueString, named: name)
            
            paramDictionary[name] = value
        }
        return paramDictionary
    }
}
