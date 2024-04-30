import Foundation

public enum CommandError: Error, Equatable{
    case missingParameter
    case regexFailed
    case paramInvalidType(String)
    case insufficientPermissions
    case invalidCommandnameForSelectedCommand
    case missingSlash
}
