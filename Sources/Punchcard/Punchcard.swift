import Foundation

let rows = "XU0123456789"

struct Column {
    var punches: Set<Character>

    init(punches: Set<Character>) {
        self.punches = punches
    }

    init(string: any StringProtocol) {
        punches = Set(rows.compactMap { string.contains($0) ? $0 : nil })
    }

    func punched(_ punch: Character) -> Bool {
        punches.contains(punch)
    }

    func punched(_ punch: String) -> Bool {
        punched(Character(punch))
    }

    var commaValue: String {
        punches.map { String($0) }.joined()
    }

}

struct Card {
    var columns: [Column]

    init(columns: [Column]) {
        self.columns = columns
    }

    init(line: any StringProtocol) {
        columns = line
            .split(separator: ",")
            .map { Column(string: $0) }
    }

    var asciiartRows: [String] {
        rows.map { r in
            columns.map { c in
                c.punched(r) ? r : Character(" ")
            }
            .reduce("") { "\($0)\($1)" }
        }
    }

    var asciiart: String {
        asciiartRows.joined(separator: "\n")
    }

    var commaValue: String {
        columns
            .map { $0.commaValue }
            .joined(separator: ",")
    }
}

struct Deck {
    var cards: [Card]

    var asciiart: String {
        cards
            .enumerated()
            .map { index, card in
                let cardArt = card.asciiartRows.enumerated().map {
                    $0.0 == 0
                        ? "\(String(format: "%04d", index)) |  \($0.1)"
                        : "     |  \($0.1)"
                }

                return (cardArt + ["", Transcoder.string(card), ""])
                    .joined(separator: "\n")
            }
            .joined(separator: "\n\n\n")
    }
}

func to_set(_ x: String) -> Set<Character> {
    Set(x.filter { $0 != " " })
}

func to_card(_ f: @escaping (Column) -> String) -> ((Card) -> String) {
    { $0.columns.map(f).joined()}
}
