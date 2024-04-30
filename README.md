<div align="center">
  
# SwiftSlashCommands

[![Tests](https://github.com/argmaxinc/whisperkit/actions/workflows/unit-tests.yml/badge.svg)](https://github.com/argmaxinc/whisperkit/actions/workflows/pre-release-tests.yml)
[![License](https://img.shields.io/github/license/argmaxinc/whisperkit?logo=github&logoColor=969da4&label=License&labelColor=353a41&color=32d058)](LICENSE.md)
[![Supported Platforms](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fargmaxinc%2FWhisperKit%2Fbadge%3Ftype%3Dplatforms&labelColor=353a41&color=32d058)]()
</div>

## This Package helps with the integration of slash commands in Swift-Projects

## Supported Devices
> iOS  17.0+
> 
> MacOS  14.0+
> 
> macCatalyst  17.0+
> 
> tvOS  17.0+
> 
> visionOS  1.0+


## Installation

### Swift Package Manager (SPM
Add the URL below to your project's Package Dependencies
```url
https://github.com/MiaKoring/SwiftSlashCommands
```


## Getting Started

Import SlashCommands
```swift
import SlashCommands
```

Create a Command
```swift
class Example: Command {
    init(completion: @escaping ([String : Any]) -> Void) {
        self.completion = completion
    }
    
    var command: String = "example"
    
    var parameters: [CommandParameter] = [ //enter as many parameters as you like or leave empty
        CommandParameter(id: 0, name: "param1", datatype: .bool, required: true), //throws an error if not included in the executed command
        CommandParameter(id: 1, name: "param2", datatype: .int, required: false) //doesn't need to be in the executed command
    ]

    //set which level of permission is needed to execute this command,
    //set to .none and usen.none in the execution if you don't have permission layers or as default state
    var minPermissions: Permission = .none 

    //Useful for selection if there are multiple commands with the same call-string
    var commandOwner: String = "Example"

    //expects a function in the initializer that gets called when the command gets executed
    var completion: ([String : Any]) -> Void 

    //gets a dictionary of parameter on call.
    //Eg. "/example param1: true param2: 1" results in ["param1": true, "param2": 1], values get checked if they are the correct type
    //Function can be declared anywhere, outside of the class as well
    public static func complete(_ : [String:Any])-> Void { 
        print("-------------------------------------------")
        print("example executed")
        print("-------------------------------------------")
    }
}
```
Create a CommandCollection and add the commands
```swift
let collection = CommandCollection()
collection.commands.append(Example(completion: Example.complete))
```
Get commands for an input string and permissionlevel
```swift
//get all commands that you are allowed to use with .none permissions
let commands = collection.commands(for: "/", highestPermission: .none)
//commands contains [Example] now

//get all commands that you are allowed to use with .muted permissions
let commands = collection.commands(for: "/", highestPermission: .muted)
//commands is empty, since .muted is below .none

//get all commands that start with "e" that you are allowed to use with .none permissions
let commands = collection.commands(for: "/e", highestPermission: .none)
//commands contains [Example] now

//get all commands for "/example param1": (only searches for example) that you are allowed to use with .none permissions
let commands = collection.commands(for: "/example param1:", highestPermission: .none)
//commands contains [Example] now
```
Execute a command
```swift
try collection.execute(collection.commands.first!, with: "/example param1: false", highestPermission: .none)
//prints in the console:
//-------------------------------------------
//example executed
//-------------------------------------------
```
Errorhandling
```
//the following errors can be thrown
public enum CommandError: Error, Equatable{
    case missingParameter
    case regexFailed
    case paramInvalidType(String)
    case insufficientPermissions
    case invalidCommandnameForSelectedCommand
    case missingSlash
}
```

## Bugreport and feature requests
Please open an issue for any bugs that may occure.
If you want to request a feature, please also open an issue, explicitly describing the feature



