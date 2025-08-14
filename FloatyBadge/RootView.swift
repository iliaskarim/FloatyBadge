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

        FloatyBadge()
      }.navigationTitle("COPYING")
    }
  }
}

#Preview {
  RootView()
}
