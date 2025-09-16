import SwiftUI

struct FloatyBadge: View {
  enum Badge {
    case branch, tag

    fileprivate var image: Image {
      switch self {
      case .branch:
          .init(systemName: "point.topleft.down.to.point.bottomright.curvepath")

      case .tag:
          .init(systemName: "tag")
      }
    }
  }

  private enum Corner: CaseIterable {
    static func nearest(to point: CGPoint, in bounds: CGRect) -> Corner {
      allCases.min { lhs, rhs in
        dist(lhs.point(in: bounds), point) < dist(rhs.point(in: bounds), point)
      } ?? .topRight
    }

    private static func dist(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
      let dx = a.x - b.x, dy = a.y - b.y
      return sqrt(dx * dx + dy * dy)
    }

    case topLeft, topRight, bottomLeft, bottomRight

    var isLeft: Bool {
      self == .topLeft || self == .bottomLeft
    }

    func point(in bounds: CGRect) -> CGPoint {
      switch self {
      case .topLeft:
        .init(x: bounds.minX, y: bounds.minY)

      case .topRight:
        .init(x: bounds.maxX, y: bounds.minY)

      case .bottomLeft:
        .init(x: bounds.minX, y: bounds.maxY)

      case .bottomRight:
        .init(x: bounds.maxX, y: bounds.maxY)
      }
    }
  }

  private struct PillWidthKey: PreferenceKey {
    static let defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
      value = max(value, nextValue())
    }
  }

  var body: some View {
    GeometryReader { proxy in
      let hMargin: CGFloat = 12
      let vMargin: CGFloat = 8

      let bounds = CGRect(
          x: hMargin + badgeSize / 2,
          y: vMargin + badgeSize / 2,
          width: proxy.size.width - 2 * hMargin - badgeSize,
          height: proxy.size.height - 2 * vMargin - badgeSize
      )

      let base = corner.point(in: bounds)

      let imageSize = 20.0

      HStack {
        image
          .resizable()
          .frame(width: imageSize, height: imageSize)
          .padding(.leading, (badgeSize - imageSize) / 2)

        Text(name)
          .frame(maxWidth: bounds.width * 0.4)
          .lineLimit(1)
          .monospaced()
          .padding(.trailing, (badgeSize - imageSize) / 2)
          .fixedSize()
      }
      .padding(.vertical, 11)
      .background(
        Capsule()
          .fill(.ultraThinMaterial)
          .shadow(radius: 1)
          .overlay(
            Capsule()
              .strokeBorder(Color.primary.opacity(0.25), lineWidth: 0.5)
          )
      )
      .background(
        GeometryReader { proxy in
          Color.clear.preference(key: PillWidthKey.self, value: proxy.size.width)
        }
      )
      .frame(height: badgeSize)
      .offset(
        x: base.x + smoothDragOffset.width - (corner.isLeft ? badgeSize / 2 : pillWidth - badgeSize / 2),
        y: base.y + smoothDragOffset.height - badgeSize / 2
      )
      .gesture(
        DragGesture()
          .onChanged { value in
            dragOffset = value.translation
            withAnimation(.easeOut(duration: 0.08)) {
              smoothDragOffset = dragOffset
            }
          }
          .onEnded { value in
            withAnimation(.interpolatingSpring(stiffness: 200, damping: 30)) {
              let droppedPoint = CGPoint(
                x: base.x + value.translation.width,
                y: base.y + value.translation.height
              )
              corner = Corner.nearest(to: droppedPoint, in: bounds)
              dragOffset = .zero
              smoothDragOffset = .zero
            }
          }
      )
      .onPreferenceChange(PillWidthKey.self) { width in
        Task { @MainActor in
          pillWidth = width
        }
      }
    }
  }

  private let badgeSize = 50.0

  @State private var corner: Corner = .bottomRight

  @State private var dragOffset: CGSize = .zero

  private let image: Image

  private let name: String

  @State private var pillWidth: CGFloat = 0

  @State private var smoothDragOffset: CGSize = .zero

  init(name: String, badge: Badge) {
    self.name = name
    self.image = badge.image
  }
}

#Preview {
  RootView()
}
