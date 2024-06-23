import Foundation

public enum Permission: Int, Equatable, Codable {
    case muted ///User is muted
    case none ///allowed to send messages
    case mute ///allowed to mute others
    case alterChannels ///allowed to alter channels
    case kick ///allowed to kick users
    case ban ///allowed to ban users
    case modifyRoles ///allowed to modify roles
    case admin ///user has admin permissions
    case owner ///user is owner
    case system ///command gets executed by the system
}
