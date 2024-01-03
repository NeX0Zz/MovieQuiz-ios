import UIKit

struct GameRecord: Codable, Comparable {
    let correctAnswers: Int
    let totalQuestions: Int
    let date: Date
    
    static func <(lhs: GameRecord, rhs: GameRecord) -> Bool {
        return lhs.correctAnswers < rhs.correctAnswers
    }
    
    static func >(lhs: GameRecord, rhs: GameRecord) -> Bool {
        return lhs.correctAnswers > rhs.correctAnswers
    }
    
}
