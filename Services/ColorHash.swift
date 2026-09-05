import Foundation

/// Deterministic id -> color hashing for real (backend-sourced) runs/users, matching
/// API_CONTRACT.md §6: "covers/avatars are client-derived from hashing id" — the server never
/// sends colors/images. Mirrors the intent of frontend/src/utils/hash.ts's fnv1a approach (each
/// client only needs to be internally consistent with itself, not byte-for-byte identical across
/// platforms) adapted to this app's hex-string field convention (`gradientStartHex`/
/// `gradientEndHex`/`avatarColorHex`) rather than frontend's CSS gradient/hsl() strings. The 8
/// gradient pairs are the same ones already hand-picked across this app's mock fixtures, so real
/// and mock data read consistently.
enum ColorHash {
    private static func fnv1a(_ input: String) -> UInt32 {
        var hash: UInt32 = 0x811c9dc5
        for byte in input.utf8 {
            hash ^= UInt32(byte)
            hash = hash &* 0x01000193
        }
        return hash
    }

    private static let coverGradients: [(start: String, end: String)] = [
        ("F0793A", "7A2E12"),
        ("D9A05C", "6B4423"),
        ("3E8161", "163A29"),
        ("A4453D", "3D1414"),
        ("3B4F70", "101820"),
        ("6B4C7A", "241830"),
        ("E0954B", "5C3A17"),
        ("2E4A73", "101828"),
    ]

    static func coverGradient(for seed: String) -> (start: String, end: String) {
        coverGradients[Int(fnv1a(seed) % UInt32(coverGradients.count))]
    }

    static func avatarColorHex(for seed: String) -> String {
        let hue = Double(fnv1a("avatar:\(seed)") % 360)
        return hexFromHSL(hue: hue, saturation: 0.45, lightness: 0.42)
    }

    /// Standard HSL -> RGB -> hex conversion (h in degrees, s/l in 0...1).
    private static func hexFromHSL(hue: Double, saturation: Double, lightness: Double) -> String {
        let c = (1 - abs(2 * lightness - 1)) * saturation
        let hPrime = hue / 60
        let x = c * (1 - abs(hPrime.truncatingRemainder(dividingBy: 2) - 1))
        let m = lightness - c / 2

        let (r1, g1, b1): (Double, Double, Double)
        switch hPrime {
        case 0..<1: (r1, g1, b1) = (c, x, 0)
        case 1..<2: (r1, g1, b1) = (x, c, 0)
        case 2..<3: (r1, g1, b1) = (0, c, x)
        case 3..<4: (r1, g1, b1) = (0, x, c)
        case 4..<5: (r1, g1, b1) = (x, 0, c)
        default: (r1, g1, b1) = (c, 0, x)
        }

        let r = Int(((r1 + m) * 255).rounded())
        let g = Int(((g1 + m) * 255).rounded())
        let b = Int(((b1 + m) * 255).rounded())
        return String(format: "%02X%02X%02X", r, g, b)
    }
}
