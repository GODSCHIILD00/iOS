import Foundation

enum BannerErrorEntity: Error {

    case unexpected

    case userSessionTimeout

    case `internal`

    case resourceDoesNotExist
}
