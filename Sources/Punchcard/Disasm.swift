import Foundation

struct Iterator {
    let data: Data
    var position: Int = 0

    mutating func next() -> UInt8? {
        guard position < data.count else { return nil }
        let next = data[position]
        position += 1
        return next
    }

    func peekNext() -> UInt8? {
        guard position < (data.count - 1) else { return nil }
        return data[position + 1]
    }
}

func disasmOperands(_ insn: Instructions, _ i: inout Iterator) throws -> String {
    switch insn.kind {
    case .p:
        let c = try i.next().or(error: "no c char in p")
        return String(format: "%02x %02x", insn.opcode, c)

    case .pm:
        let c = try i.next().or(error: "no c char in p")
        let l1_hi = try i.next().or(error: "no l1_hi char in pm")
        let l1_lo = try i.next().or(error: "no l1_lo char in pm")
        return String(format: "%02x %02x %02x%02x", insn.opcode, c, l1_hi, l1_lo)

    case .pmm:
        let c  = try i.next().or(error: "no c char in pm")
        let l1_hi = try i.next().or(error: "no l1_hi char in pm")
        let l1_lo = try i.next().or(error: "no l1_lo char in pm")
        let l2_hi = try i.next().or(error: "no l2_hi char in pm")
        let l2_lo = try i.next().or(error: "no l2_lo char in pm")

        return String(format: "%02x %02x %02x%02x %02x%02x", insn.opcode, c, l1_hi, l1_lo, l2_hi, l2_lo)
    }
}

func disasm(_ data: Data) -> String {
    var output = [String]()

    do {
        var i = Iterator(data: data)
        var offset = i.position

        while let data = i.next() {
            let mnemonic: String
            let operands: String

            if let insn = Instructions.singleByteOpcodes[data] {
                mnemonic = insn.rawValue
                operands = try disasmOperands(insn, &i)
            }
            else if let c = i.peekNext(),
                      let insn = Instructions.twoByteOpcodes[UInt16(data) << 8 + UInt16(c)] {
                mnemonic = insn.rawValue
                operands = try disasmOperands(insn, &i)
            } else {
                mnemonic = "dati"
                operands = String(format: "%02x", data)
            }

            let mnemo = mnemonic.padding(toLength: 5, withPad: " ", startingAt: 0)
            output.append(String(format: "%04x  \(mnemo) \(operands)", offset))
            offset = i.position
        }
    }
    catch {
        output.append("dasm error \(error)")
    }

    return output.map { "     |  \($0)" }.joined(separator: "\n")
}

struct DisasmError: Error, CustomStringConvertible {
    let description: String

    init(_ d: String) {
        description = d
    }
}

extension Optional {
    func or(error: String) throws -> Wrapped {
        if let self { return self }
        else { throw DisasmError(error) }
    }
}
