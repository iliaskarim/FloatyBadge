import SwiftUI

struct FloatyBadge: View {
  private let badgeSize = CGSize(width: 50, height: 50)
  private let margin: CGFloat = 12

  var scrollOffset: CGFloat = 0

  @State private var position: CGPoint = .zero
  @State private var lastBounds: CGRect = .zero
  @State private var dragOffset: CGSize = .zero
  @State private var dragStartPosition: CGPoint? = nil

  var body: some View {
    GeometryReader { geo in
      let bounds = safeBounds(in: geo.size)

      badgeView
        .position(position)
        .gesture(
          DragGesture()
            .onChanged { value in
              if dragStartPosition == nil {
                dragStartPosition = position
              }
              let newX = dragStartPosition!.x + value.translation.width
              let newY = dragStartPosition!.y + value.translation.height
              position.x = min(max(newX, bounds.minX), bounds.maxX)
              position.y = min(max(newY, bounds.minY), bounds.maxY)
            }
            .onEnded { _ in
              dragStartPosition = nil
            }
        )
        .onChange(of: bounds) { newBounds in
          if newBounds != lastBounds {
            position.x = min(max(position.x, newBounds.minX), newBounds.maxX)
            position.y = min(max(position.y, newBounds.minY), newBounds.maxY)
            lastBounds = newBounds
          }
        }
        .onAppear {
          lastBounds = bounds
          position = CGPoint(
            x: (bounds.minX + bounds.maxX) / 2,
            y: (bounds.minY + bounds.maxY) / 2
          )
        }
    }
  }

  private var badgeView: some View {
    Image(systemName: "line.3.horizontal.circle")
      .frame(width: badgeSize.width, height: badgeSize.height)
      .background(.ultraThinMaterial, in: Capsule())
      .shadow(radius: 1)
  }

  private func safeBounds(in size: CGSize) -> CGRect {
    let minX = margin + badgeSize.width / 2
    let maxX = size.width - margin - badgeSize.width / 2
    let bounceOffset = scrollOffset > 0 ? scrollOffset : 0
    let minY = margin + badgeSize.height / 2 + bounceOffset
    let maxY = size.height - margin - badgeSize.height / 2
    return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
  }
}

/// FloatyBadge root view
struct RootView: View {
  var body: some View {
    NavigationStack {
      ZStack {
        ScrollView([.horizontal, .vertical]) {
          GeometryReader { proxy in
            Color.clear
              .onChange(of: proxy.frame(in: .named("scroll")).minY) { newValue in
                scrollOffset = newValue
              }
          }
          .frame(height: 0)

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

        FloatyBadge(scrollOffset: scrollOffset)
      }.navigationTitle("COPYING")
    }
  }

  @State private var scrollOffset: CGFloat = 0
}

#Preview {
  RootView()
}
