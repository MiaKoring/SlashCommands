import Foundation

public enum CommandError: Error, Equatable{
    case missingParameter
    case regexFailed
    case paramInvalid(String)
    case insufficientPermissions
    case invalidCommandnameForSelectedCommand
    case missingSlash
}
