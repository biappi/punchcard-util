import Foundation

struct Transcoder {
    static let ibm = Transcoder(list: ibmCardTable)
    static let bull = Transcoder(list: bullCardTable)
    static let normal = Transcoder(hex: hexTable)
    static let ibmInternal = Transcoder(cardCodeTable: ibmCardCodeTable)

    let table: [Set<Character>: String]

    init(cardCodeTable: [(Int, [String])]) {
        let codes = cardCodeTable.flatMap { (group, columns) in
            columns.enumerated().map {
                (to_set($0.1), String(format: "%0x", group  + $0.0))
            }
        }

        table = Dictionary(uniqueKeysWithValues: codes)
    }

    init(hex: [String]) {
        let codes =  hex.enumerated().map {
            (to_set($0.1), String(format: "%0x", $0.0))
        }

        table = Dictionary(uniqueKeysWithValues: codes)
    }

    init(list: [(String, String)]) {
        let list = list.map { (to_set($0.0), $0.1) }
        table = Dictionary(uniqueKeysWithValues: list)
    }

    func string(_ column: Column) -> String {
        table[column.punches] ?? "⊘"
    }

    func card(_ string: String) -> Card {
        let reverseCode = table.map { ($0.1, $0.0) }
        let reverseTable = Dictionary(uniqueKeysWithValues: reverseCode)

        let columns = string.map {
            Column(punches: reverseTable[String($0)] ?? [])
        }

        return Card(columns: columns)
    }

    static let all = [
        (" IBM", Transcoder.ibm.string),
        ("BULL", Transcoder.bull.string),
        (" HEX", Transcoder.normal.string),
        // (" BIN", Transcoder.binary),
    ]

    static func string(_ card: Card) -> String {
        all.map {
            "\($0.0) |  \(to_card($0.1)(card))"
        }.joined(separator: "\n") + "\nDASM |\n\(disassemble(card))"
    }

    static func data(_ card: Card) -> Data {
        let hextable = Transcoder.hexTable.enumerated().map {
            (Set($0.1.filter { $0 != " " }), UInt8($0.0))
        }

        let hex = Dictionary(uniqueKeysWithValues: hextable)
        let maybedata = card.columns.map { hex[$0.punches] }
        let doubledata = maybedata.compactMap { $0 }
        var data = Data(capacity: 40)

        var char: UInt8?
        var it = doubledata.makeIterator()

        while let i = it.next() {
            if let oldChar = char {
                char = nil
                data.append(((oldChar & 0x0f) << 4) + (i & 0x0f))
            } else {
                char = i
            }
        }

        return data
    }

    static func disassemble(_ card: Card) -> String {
        let data = data(card)
        return disasm(data)
    }

    static func binary(_ column: Column) -> String {
        let mangle = { (x: Int) in
            let b5 = (x & (1 << 5)) != 0

            let b7 =  b5 ? (1 << 7) : 0
            let b6 = !b5 ? (1 << 6) : 0

            return x + b6 + b7
        }

        let first =
            (column.punched("X") ? (1 << 5) : 0) |
            (column.punched("U") ? (1 << 4) : 0) |
            (column.punched("0") ? (1 << 3) : 0) |
            (column.punched("1") ? (1 << 2) : 0) |
            (column.punched("2") ? (1 << 1) : 0) |
            (column.punched("3") ? (1 << 0) : 0)

        let second =
            (column.punched("4") ? (1 << 5) : 0) |
            (column.punched("5") ? (1 << 4) : 0) |
            (column.punched("6") ? (1 << 3) : 0) |
            (column.punched("7") ? (1 << 2) : 0) |
            (column.punched("8") ? (1 << 1) : 0) |
            (column.punched("9") ? (1 << 0) : 0)


        return String(format: "%02x %02x ", mangle(first), mangle(second))
    }

}

