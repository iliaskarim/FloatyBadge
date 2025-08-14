import SwiftUI

struct FloatyBadge: View {
  // tune these
  private let badgeSize = CGSize(width: 50, height: 50)
  private let margin: CGFloat = 12

  @State private var position: CGPoint? // nil = not placed yet

  var body: some View {
    GeometryReader { geo in
      let bounds = safeBounds(in: geo.size)

      badgeView
        .position(initialPosition(in: bounds))
        .gesture(
          DragGesture()
            .onChanged { value in
              // clamp live to local content bounds
              position = clamp(value.location, to: bounds)
            }
            .onEnded { value in
              // add a touch of inertia using predicted end, then snap to nearest corner
              let predicted = clamp(value.predictedEndLocation, to: bounds)
              let target = nearestCorner(to: predicted, in: bounds)
              withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                position = target
              }
            }
        )
    }
  }

  // MARK: - Views

  private var badgeView: some View {
    Image(systemName: "line.3.horizontal.circle")
      .frame(width: badgeSize.width, height: badgeSize.height)
      .background(.ultraThinMaterial, in: Capsule())
      .shadow(radius: 1)
  }

  // MARK: - Layout helpers

  private func safeBounds(in size: CGSize) -> CGRect {
    // local content rect with margins and badge size accounted for
    let minX = margin + badgeSize.width  / 2
    let maxX = size.width  - margin - badgeSize.width  / 2
    let minY = margin + badgeSize.height / 2
    let maxY = size.height - margin - badgeSize.height / 2
    return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
  }

  private func initialPosition(in bounds: CGRect) -> CGPoint {
    if let position { return position }
    // default start: top-left, nudged down a bit
    let start = CGPoint(x: bounds.minX, y: bounds.minY + 100)
    position = start
    return start
  }

  private func clamp(_ p: CGPoint, to rect: CGRect) -> CGPoint {
    CGPoint(
      x: min(max(p.x, rect.minX), rect.maxX),
      y: min(max(p.y, rect.minY), rect.maxY)
    )
  }

  private func nearestCorner(to p: CGPoint, in rect: CGRect) -> CGPoint {
    let corners = [
      CGPoint(x: rect.minX, y: rect.minY),
      CGPoint(x: rect.maxX, y: rect.minY),
      CGPoint(x: rect.minX, y: rect.maxY),
      CGPoint(x: rect.maxX, y: rect.maxY)
    ]
    return corners.min(by: { dist($0, p) < dist($1, p) }) ?? p
  }

  private func dist(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
    let dx = a.x - b.x, dy = a.y - b.y
    return sqrt(dx*dx + dy*dy)
  }
}

/// FloatyBadge root view
struct RootView: View {
  var body: some View {
    NavigationStack {
      ZStack {
        ScrollView {
          Text("""
Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.


Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old. Richard McClintock, a Latin professor at Hampden-Sydney College in Virginia, looked up one of the more obscure Latin words, consectetur, from a Lorem Ipsum passage, and going through the cites of the word in classical literature, discovered the undoubtable source. Lorem Ipsum comes from sections 1.10.32 and 1.10.33 of "de Finibus Bonorum et Malorum" (The Extremes of Good and Evil) by Cicero, written in 45 BC. This book is a treatise on the theory of ethics, very popular during the Renaissance. The first line of Lorem Ipsum, "Lorem ipsum dolor sit amet..", comes from a line in section 1.10.32.

The standard chunk of Lorem Ipsum used since the 1500s is reproduced below for those interested. Sections 1.10.32 and 1.10.33 from "de Finibus Bonorum et Malorum" by Cicero are also reproduced in their exact original form, accompanied by English versions from the 1914 translation by H. Rackham.

""").padding()
        }

        FloatyBadge()
      }.navigationTitle("Hello, world!")
    }
  }
}

#Preview {
  RootView()
}
