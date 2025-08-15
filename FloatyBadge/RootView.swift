import SwiftUI

struct FloatyBadge: View {
  private let badgeSize = CGSize(width: 50, height: 50)
  private let margin: CGFloat = 12
  
  var scrollOffset: CGFloat = 0
  @State private var corner: Corner = .topRight
  @State private var dragOffset: CGSize = .zero
  
  enum Corner {
    case topLeft, topRight, bottomLeft, bottomRight
  }
  
  var body: some View {
    GeometryReader { geo in
      let bounds = safeBounds(in: geo.size)
      let basePosition = position(for: corner, in: bounds)
      let currentPosition = CGPoint(
        x: basePosition.x + dragOffset.width,
        y: basePosition.y + dragOffset.height
      )
      
      badgeView
        .position(currentPosition)
        .gesture(
          DragGesture()
            .onChanged { value in
              dragOffset = value.translation
            }
            .onEnded { value in
              let droppedPosition = CGPoint(
                x: basePosition.x + value.translation.width,
                y: basePosition.y + value.translation.height
              )
              corner = nearestCorner(to: droppedPosition, in: bounds)
              dragOffset = .zero
            }
        )
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
  
  private func position(for corner: Corner, in bounds: CGRect) -> CGPoint {
    switch corner {
    case .topLeft: return CGPoint(x: bounds.minX, y: bounds.minY)
    case .topRight: return CGPoint(x: bounds.maxX, y: bounds.minY)
    case .bottomLeft: return CGPoint(x: bounds.minX, y: bounds.maxY)
    case .bottomRight: return CGPoint(x: bounds.maxX, y: bounds.maxY)
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
            Color.clear.onChange(of: proxy.frame(in: .named("scroll")).minY) { newValue in
              scrollOffset = newValue
            }
          }
          .frame(height: 0)
          //          .coordinateSpace(name: "scroll")
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
