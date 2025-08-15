import SwiftUI
private struct PillWidthKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

struct FloatyBadge: View {
    private let badgeSize = 50.0
    private let imageSize = 30.0
    var branchName: String = "mainmainmainmainmainmainmainmain"

    @State private var pillWidth: CGFloat = 0
    @State private var corner: Corner = .topRight
    @State private var dragOffset: CGSize = .zero
    @State private var smoothDragOffset: CGSize = .zero

    enum Corner {
        case topLeft, topRight, bottomLeft, bottomRight
        var isLeft: Bool {
            switch self { case .topLeft, .bottomLeft: return true; default: return false }
        }
    }

    private let spacing = 8.0
    private var padding: CGFloat { (badgeSize - imageSize) / 2 }
    private let margin: CGFloat = 12
    private var pillHeightOffset: CGFloat { badgeSize / 2 }

    var body: some View {
        GeometryReader { geo in
            let bounds = safeBounds(in: geo.size)
            let baseX = xPosition(for: corner, in: bounds)
            let baseY = yPosition(for: corner, in: bounds)
            let currentX = baseX + smoothDragOffset.width
            let currentY = baseY + smoothDragOffset.height

          Rectangle()
            .stroke(Color.red, lineWidth: 3)
            .frame(width: bounds.width, height: bounds.height)
            .position(x: bounds.midX, y: bounds.midY)

            HStack(spacing: spacing) {
                Image(systemName: "line.3.horizontal.circle")
                    .resizable()
                    .frame(width: imageSize, height: imageSize)
                    .padding([.leading, .vertical], padding)

                Text(branchName)
                    .lineLimit(1)
                    .padding(.trailing, padding)
                    .frame(maxWidth: bounds.width * 0.4)
                    .fixedSize()
            }
            .background(.ultraThinMaterial, in: Capsule())
            .shadow(radius: 1)
            .background(
                GeometryReader { pillGeo in
                    Color.clear
                        .preference(key: PillWidthKey.self, value: pillGeo.size.width)
                }
            )
            .frame(height: badgeSize)
            .offset(
                x: currentX - (corner.isLeft ? pillHeightOffset : pillWidth - pillHeightOffset),
                y: currentY - badgeSize / 2
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
                        let droppedPoint = CGPoint(
                            x: baseX + value.translation.width,
                            y: baseY + value.translation.height
                        )
                        let newCorner = nearestCorner(to: droppedPoint, in: bounds)
                        withAnimation(.interpolatingSpring(stiffness: 200, damping: 30)) {
                            corner = newCorner
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

    private func safeBounds(in size: CGSize) -> CGRect {
        let minX = margin + badgeSize / 2
        let maxX = size.width - margin - badgeSize / 2
        let minY = margin + badgeSize / 2
        let maxY = size.height - margin - badgeSize / 2
        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }

    private func xPosition(for corner: Corner, in bounds: CGRect) -> CGFloat {
        switch corner {
        case .topLeft, .bottomLeft: return bounds.minX
        case .topRight, .bottomRight: return bounds.maxX
        }
    }

    private func yPosition(for corner: Corner, in bounds: CGRect) -> CGFloat {
        switch corner {
        case .topLeft, .topRight: return bounds.minY
        case .bottomLeft, .bottomRight: return bounds.maxY
        }
    }

    private func nearestCorner(to point: CGPoint, in bounds: CGRect) -> Corner {
        let corners: [Corner: CGPoint] = [
            .topLeft: CGPoint(x: bounds.minX, y: bounds.minY),
            .topRight: CGPoint(x: bounds.maxX, y: bounds.minY),
            .bottomLeft: CGPoint(x: bounds.minX, y: bounds.maxY),
            .bottomRight: CGPoint(x: bounds.maxX, y: bounds.maxY)
        ]
        return corners.min(by: { dist($0.value, point) < dist($1.value, point) })?.key ?? .topRight
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
        ScrollView([.horizontal, .vertical]) {
          GeometryReader { proxy in
            Color.clear.onChange(of: proxy.frame(in: .named("scroll")).minY) { _, newValue in
              scrollOffset = newValue
            }
          }.frame(height: 0)

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
        .coordinateSpace(name: "scroll")

        FloatyBadge()
      }.navigationTitle("COPYING")
    }
  }

  @State private var scrollOffset: CGFloat = 0
}

#Preview {
  RootView()
}
