import Foundation
import ArgumentParser

let example = "9,68,8,0,0,0,2,2,9,68,8,0,0,0,2,0,9,68,8,0,0,0,2,6,4,3,1,0,0,0,2,5,58,2,0,2,0,0,1,7,0,0,3,0,58,2,0,0,0,0,0,0,0,0,3,3,4,3,78,0,0,0,0,4,0,0,4,0,8,0,28,0,0,0,2,8,48,0,4,28"


public struct TheApp: ParsableCommand {

    static public let configuration = CommandConfiguration(
        abstract: "GE-130 punch card utility",
        subcommands: [
            Read.self,
            Encode.self,
        ],
        defaultSubcommand: Read.self
    )

    public init() { }

    struct Read: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Try to read a punch card deck file"
        )

        @Argument(help: "a file with a list of keypunches")
        var filename: String?

        func deckFromFile(filename: String) throws -> Deck {
            let file = try String(contentsOfFile: filename)
            let lines = file
                .split(separator: "\n")
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.hasPrefix("#") }
                .filter { !$0.isEmpty }

            let cards = lines.map(Card.init)
            return Deck(cards: cards)
        }

        func makeDeck() throws -> Deck {
            if let filename {
                return try deckFromFile(filename: filename)
            } else {
                print("Using a default example card\n")
                return Deck(cards: [Card(line: example)])
            }
        }

        public func run() throws {
            let deck = try makeDeck()
            print(deck.asciiart)
        }
    }

    struct Encode: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Encode a string to a card"
        )

        @Argument(help: "a string to encode")
        var string: String

        func run() throws {
            let card = Transcoder.ibm.card(string)
            let deck = Deck(cards: [card])
            print(deck.asciiart)
        }
    }
}

