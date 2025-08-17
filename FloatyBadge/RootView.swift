import SwiftUI

struct FloatyBadge: View {
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
      let margin: CGFloat = 12
      let bounds = CGRect(
          x: margin + badgeSize / 2,
          y: margin + badgeSize / 2,
          width: proxy.size.width - 2 * margin - badgeSize,
          height: proxy.size.height - 2 * margin - badgeSize
      )

      let base = corner.point(in: bounds)

      let imageSize = 30.0

      HStack {
        image
          .resizable()
          .frame(width: imageSize, height: imageSize)
          .padding([.leading, .vertical], (badgeSize - imageSize) / 2)

        Text(name)
          .frame(maxWidth: bounds.width * 0.4)
          .lineLimit(1)
          .monospaced()
          .padding(.trailing, (badgeSize - imageSize) / 2 + 5)
          .fixedSize()
      }
      .background(.ultraThinMaterial, in: Capsule())
      .shadow(radius: 1)
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

  @State private var corner: Corner = .topRight

  @State private var dragOffset: CGSize = .zero

  private let image: Image

  private let name: String

  @State private var pillWidth: CGFloat = 0

  @State private var smoothDragOffset: CGSize = .zero

  init(name: String, image: Image) {
    self.name = name
    self.image = image
  }
}

/// FloatyBadge root view
struct RootView: View {
  var body: some View {
    NavigationStack {
      ZStack {
        ScrollView([.horizontal, .vertical]) {
          Text("""
                       GNU LESSER GENERAL PUBLIC LICENSE
                           Version 3, 29 June 2007

          Copyright (C) 2007 Free Software Foundation, Inc. <http://fsf.org/>
          Everyone is permitted to copy and distribute verbatim copies
          of this license document, but changing it is not allowed.


          This version of the GNU Lesser General Public License incorporates
          the terms and conditions of version 3 of the GNU General Public
          License, supplemented by the additional permissions listed below.

            0. Additional Definitions.

            As used herein, "this License" refers to version 3 of the GNU Lesser
          General Public License, and the "GNU GPL" refers to version 3 of the GNU
          General Public License.

            "The Library" refers to a covered work governed by this License,
          other than an Application or a Combined Work as defined below.

            An "Application" is any work that makes use of an interface provided
          by the Library, but which is not otherwise based on the Library.
          Defining a subclass of a class defined by the Library is deemed a mode
          of using an interface provided by the Library.

            A "Combined Work" is a work produced by combining or linking an
          Application with the Library.  The particular version of the Library
          with which the Combined Work was made is also called the "Linked
          Version".

            The "Minimal Corresponding Source" for a Combined Work means the
          Corresponding Source for the Combined Work, excluding any source code
          for portions of the Combined Work that, considered in isolation, are
          based on the Application, and not on the Linked Version.

            The "Corresponding Application Code" for a Combined Work means the
          object code and/or source code for the Application, including any data
          and utility programs needed for reproducing the Combined Work from the
          Application, but excluding the System Libraries of the Combined Work.
          """).monospaced().padding()
        }

        FloatyBadge(name: name, image: image)
      }.navigationTitle("COPYING")
    }
  }

  private let image: Image

  private let name: String

  init(name: String, image: Image) {
    self.name = name
    self.image = image
  }

  init() {
    self.init(name: "main", image: .init(systemName: "line.3.horizontal.decrease.circle.fill"))
  }
}

#Preview {
  RootView(name: "main", image: .init(systemName: "line.3.horizontal.decrease.circle.fill"))
}

#Preview {
  RootView(name: "mainmainmainmainmainmain", image: .init(systemName: "line.3.horizontal.decrease.circle.fill"))
}

#Preview {
  RootView(name: "1.1.1", image: .init(systemName: "tag.circle.fill"))
}
