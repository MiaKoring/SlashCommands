import XCTest
@testable import SwiftSlashCommands

final class SwiftSlashCommandsTests: XCTestCase {
    func testGetCommandsWithLowPermissions()throws {
        let collection = CommandCollection()
        collection.commands.append(LowPermission(completion: LowPermission.complete))
        collection.commands.append(HighPermission(completion: HighPermission.complete))
        collection.commands.append(NoParam(completion: NoParam.complete))
        
        let commands = try collection.commands(for: "/", highestPermission: .none)
        print("\n\n Commands: \(commands)")
        XCTAssertTrue(commands.first?.command == "low" && commands.count == 1)
        
        let superLow = try collection.commands(for: "/", highestPermission: .muted)
        XCTAssertTrue(superLow.isEmpty)
    }
    
    func testExecuteCommandWithLowPermission()throws {
        let collection = CommandCollection()
        collection.commands.append(LowPermission(completion: LowPermission.complete))
        collection.commands.append(HighPermission(completion: HighPermission.complete))
        collection.commands.append(NoParam(completion: NoParam.complete))
        
        try collection.execute(collection.commands.first!, with: "/low param1: false param2: 1 param3: 1.1 param4: Lol", highestPermission: .none)
        
        do {
            try collection.execute(collection.commands.first!, with: "/low param1: false param2: 1 param3: 1.1 param4: Lol", highestPermission: .muted)
            XCTAssertTrue(false)
        } catch let error {
            let cmdError = error as? CommandError
            XCTAssertTrue(cmdError == CommandError.insufficientPermissions)
        }
    }
    
    func testGetCommandsWithHighPermissions()throws {
        let collection = CommandCollection()
        collection.commands.append(LowPermission(completion: LowPermission.complete))
        collection.commands.append(HighPermission(completion: HighPermission.complete))
        collection.commands.append(NoParam(completion: NoParam.complete))
        
        let commands = try collection.commands(for: "/", highestPermission: .admin)
        print("\n\n Commands: \(commands)")
        XCTAssertTrue(commands.contains(where: {$0.command == "low"}) && commands.contains(where: {$0.command == "high"}) && commands.contains(where: {$0.command == "noParam"}) && commands.count == 3)
        
        let superLow = try collection.commands(for: "/", highestPermission: .kick)
        print("\n\n Commands: \(superLow)")
        XCTAssertTrue(superLow.contains(where: {$0.command == "low"}) && superLow.contains(where: {$0.command == "noParam"}) && superLow.count == 2)
    }
    
    func testExecuteCommandWithHighPermission()throws {
        let collection = CommandCollection()
        collection.commands.append(LowPermission(completion: LowPermission.complete))
        collection.commands.append(HighPermission(completion: HighPermission.complete))
        collection.commands.append(NoParam(completion: NoParam.complete))
        
        try collection.execute(collection.commands[1], with: "/high param1: false param2: 1 param3: 1.1 param4: Lol", highestPermission: .admin)
        
        do {
            try collection.execute(collection.commands[1], with: "/high param1: false param2: 1 param3: 1.1 param4: Lol", highestPermission: .muted)
            XCTAssertTrue(false)
        } catch let error {
            let cmdError = error as? CommandError
            XCTAssertTrue(cmdError == CommandError.insufficientPermissions)
        }
    }
    
    func testWrongCommandName()throws {
        let collection = CommandCollection()
        collection.commands.append(LowPermission(completion: LowPermission.complete))
        collection.commands.append(HighPermission(completion: HighPermission.complete))
        collection.commands.append(NoParam(completion: NoParam.complete))
        
        do{
            try collection.execute(collection.commands.first!, with: "/high param1: false param2: 1 param3: 1.1 param4: Lol", highestPermission: .admin)
            XCTAssertTrue(false)
        }
        catch let error {
            let cmdError = error as? CommandError
            XCTAssertTrue(cmdError == CommandError.invalidCommandnameForSelectedCommand)
        }
    }
    
    func testNoParams()throws {
        let collection = CommandCollection()
        collection.commands.append(LowPermission(completion: LowPermission.complete))
        collection.commands.append(HighPermission(completion: HighPermission.complete))
        collection.commands.append(NoParam(completion: NoParam.complete))
        
        try collection.execute(collection.commands.last!, with: "/noParam", highestPermission: .kick)
        try collection.execute(collection.commands.last!, with: "/noParam abc def: lol", highestPermission: .kick)
    }
    
    func testNotUsingOptionalParam()throws {
        let collection = CommandCollection()
        collection.commands.append(LowPermission(completion: LowPermission.complete))
        collection.commands.append(HighPermission(completion: HighPermission.complete))
        collection.commands.append(NoParam(completion: NoParam.complete))
        
        try collection.execute(collection.commands.first!, with: "/low param1: false param3: 1.1 param4: Lol", highestPermission: .none)
    }
    
    func testNotUsingRequiredParam()throws {
        let collection = CommandCollection()
        collection.commands.append(LowPermission(completion: LowPermission.complete))
        collection.commands.append(HighPermission(completion: HighPermission.complete))
        collection.commands.append(NoParam(completion: NoParam.complete))
        
        do{
            try collection.execute(collection.commands.first!, with: "/low param1: false param3: 1.1", highestPermission: .none)
        } catch let error {
            let cmdError = error as? CommandError
            XCTAssertTrue(cmdError == CommandError.missingParameter)
        }
    }
    
    func testWrongDatatype()throws {
        let collection = CommandCollection()
        collection.commands.append(LowPermission(completion: LowPermission.complete))
        collection.commands.append(HighPermission(completion: HighPermission.complete))
        collection.commands.append(NoParam(completion: NoParam.complete))
        
        do{
            try collection.execute(collection.commands.first!, with: "/low param1: abc param3: 1.1 param4: Lol", highestPermission: .none)
        } catch let error {
            let cmdError = error as? CommandError
            XCTAssertTrue(cmdError == CommandError.paramInvalidType("param1"))
        }
    }
    
    func testIgnoringSlash()throws {
        let collection = CommandCollection()
        collection.commands.append(LowPermission(completion: LowPermission.complete))
        collection.commands.append(HighPermission(completion: HighPermission.complete))
        collection.commands.append(NoParam(completion: NoParam.complete))
        
        do{
            try collection.execute(collection.commands.first!, with: "low param1: abc param3: 1.1 param4: Lol", highestPermission: .none)
        } catch let error {
            let cmdError = error as? CommandError
            XCTAssertTrue(cmdError == CommandError.missingSlash)
        }
    }
}

class LowPermission: Command{
    init(completion: @escaping ([String : Any]) -> Void) {
        self.completion = completion
    }
    
    var command: String = "low"
    
    var parameters: [CommandParameter] = [
        CommandParameter(id: 0, name: "param1", datatype: .bool, required: true),
        CommandParameter(id: 1, name: "param2", datatype: .int, required: false),
        CommandParameter(id: 2, name: "param3", datatype: .double, required: true),
        CommandParameter(id: 3, name: "param4", datatype: .string, required: true)
    ]
    
    var minPermissions: Permission = .none
    
    var commandOwner: String = "SwiftSlashCommands"
    
    var completion: ([String : Any]) -> Void
    
    public static func complete(_ params: [String: Any])-> Void{
        print("\n\n\n")
        print("-------------------------------------------")
        if let bool = params["param1"]! as? Bool, bool {
            print("Low: boolIsTrue")
        }
        else{
            print("Low: boolIsFalse")
        }
        if let int = params["param2"] as? Int {
            print("Low: Int(\(int))")
        }
        else{
            print("Low: noInt")
        }
        if let double = params["param3"]! as? Double {
            print("Low: Double(\(double))")
        }
        if let string = params["param4"]! as? String {
            print("Low: String(\"\(string)\")")
        }
        print("-------------------------------------------")
        print("\n\n\n")
    }
}

class HighPermission: Command {
    init(completion: @escaping ([String : Any]) -> Void) {
        self.completion = completion
    }
    
    var command: String = "high"
    
    var parameters: [CommandParameter] = [
        CommandParameter(id: 0, name: "param1", datatype: .bool, required: true),
        CommandParameter(id: 1, name: "param2", datatype: .int, required: false),
        CommandParameter(id: 2, name: "param3", datatype: .double, required: true),
        CommandParameter(id: 3, name: "param4", datatype: .string, required: true)
    ]
    
    var minPermissions: Permission = .ban
    
    var commandOwner: String = "SwiftSlashCommands"
    
    var completion: ([String : Any]) -> Void
    
    public static func complete(_ params: [String: Any])-> Void{
        print("\n\n\n")
        print("-------------------------------------------")
        if let bool = params["param1"]! as? Bool, bool {
            print("High: boolIsTrue")
        }
        if let int = params["param2"] as? Int {
            print("High: Int(\(int))")
        }
        else{
            print("High: noInt")
        }
        if let double = params["param3"]! as? Double {
            print("High: Double(\(double))")
        }
        if let string = params["param4"]! as? String {
            print("High: String(\"\(string)\")")
        }
        print("-------------------------------------------")
        print("\n\n\n")
    }
}

class NoParam: Command {
    init(completion: @escaping ([String : Any]) -> Void) {
        self.completion = completion
    }
    
    var command: String = "noParam"
    
    var parameters: [SwiftSlashCommands.CommandParameter] = []
    
    var minPermissions: SwiftSlashCommands.Permission = .kick
    
    var commandOwner: String = "SwiftSlashCommands"
    
    var completion: ([String : Any]) -> Void
    
    public static func complete(_ : [String:Any])-> Void {
        print("\n\n\n")
        print("-------------------------------------------")
        print("noParam executed")
        print("-------------------------------------------")
        print("\n\n\n")
    }
}
