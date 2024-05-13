import Foundation

enum Instructions: String, CaseIterable {
    enum Kind {
        case p
        case pm
        case pmm
    }

    case ens, ins, loff, lon,  loll, nop2, hlt, jie
    case js2, js1, jrt,  jc,   la,   tm,   mvi, ni
    case cmi, ci,  xi,   peri, lpsr, per,  str, lr
    case cmr, amr, smr,  mvc,  nc,   cmc,  oc,  xc
    case upk, sr,  pk,   sl,   tl,   edt,  mvp, cmp
    case ap,  sp,  mp,   dp,   pks,  upks, mvq, cmq
    case ad,  sd,  ab,   sb

    var opcode: UInt8 {
        switch self {
        case .ens:  return 0x02
        case .ins:  return 0x02
        case .loff: return 0x02
        case .lon:  return 0x02
        case .loll: return 0x02
        case .nop2: return 0x07
        case .hlt:  return 0x0a
        case .jie:  return 0x53
        case .js2:  return 0x53
        case .js1:  return 0x53
        case .jrt:  return 0x41
        case .jc:   return 0x43
        case .la:   return 0x68
        case .tm:   return 0x91
        case .mvi:  return 0x92
        case .ni:   return 0x94
        case .cmi:  return 0x95
        case .ci:   return 0x96
        case .xi:   return 0x97
        case .peri: return 0x9c
        case .lpsr: return 0x9d
        case .per:  return 0x9e
        case .str:  return 0x84
        case .lr:   return 0xbc
        case .cmr:  return 0xbd
        case .amr:  return 0xbe
        case .smr:  return 0xbf
        case .mvc:  return 0xd2
        case .nc:   return 0xd4
        case .cmc:  return 0xd5
        case .oc:   return 0xd6
        case .xc:   return 0xd7
        case .upk:  return 0xd8
        case .sr:   return 0xd9
        case .pk:   return 0xda
        case .sl:   return 0xdb
        case .tl:   return 0xdc
        case .edt:  return 0xde
        case .mvp:  return 0xe8
        case .cmp:  return 0xe9
        case .ap:   return 0xea
        case .sp:   return 0xeb
        case .mp:   return 0xec
        case .dp:   return 0xed
        case .pks:  return 0xee
        case .upks: return 0xef
        case .mvq:  return 0xf8
        case .cmq:  return 0xf9
        case .ad:   return 0xfa
        case .sd:   return 0xfb
        case .ab:   return 0xfe
        case .sb:   return 0xff
        }
    }

    var secondChar: UInt8? {
        switch self {
        case .ens:  return 0x10
        case .ins:  return 0x20
        case .loff: return 0x40
        case .lon:  return 0x80
        case .loll: return 0x91
        case .jie:  return 0x20
        case .js2:  return 0x40
        case .js1:  return 0x80
        default: return nil
        }
    }

    var kind: Kind {
        switch self {
        case .ens, .ins, .loff, .lon, .loll, .nop2, .hlt:
            return .p

        case .jie, .js2, .js1,  .jrt, .jc,   .la,   .tm,  .mvi,
             .ni,  .cmi, .ci,   .xi,  .peri, .lpsr, .per, .str,
             .lr,  .cmr, .amr,  .smr:
            return .pm


        case .mvc, .nc,  .cmc,  .oc,  .xc,   .upk,  .sr,  .pk,
             .sl,  .tl,  .edt,  .mvp, .cmp,  .ap,   .sp,  .mp,
             .dp,  .pks, .upks, .mvq, .cmq,  .ad,   .sd,  .ab,
             .sb:
            return .pmm
        }
    }

    static var singleByteInstructions: [(UInt8, Instructions)] {
        allCases.filter { $0.secondChar == nil }.map { ($0.opcode, $0) }
    }

    static var singleByteOpcodes: [UInt8: Instructions]
        = Dictionary(uniqueKeysWithValues: singleByteInstructions)

    static var twoByteInstructions: [(UInt16, Instructions)] {
        allCases
            .compactMap { insn in 
                insn.secondChar.map { ((UInt16(insn.opcode) << 8) + UInt16($0), insn) }
            }
    }

    static var twoByteOpcodes: [UInt16: Instructions]
        = Dictionary(uniqueKeysWithValues: twoByteInstructions)
}
