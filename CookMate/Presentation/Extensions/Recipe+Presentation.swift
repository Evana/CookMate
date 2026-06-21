import SwiftUI

extension Recipe {
    var cardColor: Color {
        let colors: [Color] = [
            .orange.opacity(0.75),
            .blue.opacity(0.65),
            .green.opacity(0.65),
            .purple.opacity(0.65),
            .pink.opacity(0.65)
        ]
        return colors[Int(id.uuid.0) % colors.count]
    }
}
