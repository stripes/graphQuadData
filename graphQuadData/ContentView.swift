//
//  ContentView.swift
//  graphQuadData
//
//  Created by J Osborne on 4/12/24.
//

import SwiftUI
import Charts

struct ContentView: View {
    var body: some View {
      let xAxis = DataPoints.Axis2.highWater
      let yAxis = DataPoints.Axis2.connectionLimit
      let id2pt = Dictionary(unsortedPoints.map { ($0.id, $0) }, uniquingKeysWith: { (v, _) in preconditionFailure("Duplicate entry for \(v.id)") })
      let acceptableLimit: Double = 40
      let pts: [DataPoints.ProjectedPoint] = unsortedPoints.projected(x: xAxis, y: yAxis, combineSamples: .discardOutliers(.avg), combineProjection: .min)
        VStack {
          Chart {
            ForEach(pts) { (pp: DataPoints.ProjectedPoint) in
              if pp.duration < acceptableLimit {
                RectangleMark(x: pp.x, y: pp.y)
                  .foregroundStyle(by: pp.d).accessibilityLabel(pp.dataPointIds.joined(separator: " & "))
              } else {
                PointMark(x: pp.x, y: pp.y).foregroundStyle(.red.opacity(0.2)).symbol(.cross)
              }
            }
          }.chartXAxisLabel("\(xAxis.label())").chartYAxisLabel("\(yAxis.label())").chartOverlay { proxy in
            GeometryReader { geometry in
              Rectangle().fill(.clear).contentShape(Rectangle())
                .onTapGesture { location in
                  guard let (x, y) = proxy.value(at: location, as: (Int, Int).self)    else  {
                     return
                  }
                  // XXX: do something if >1 hit?
                  let hits = pts.filter { $0.duration < acceptableLimit }.closest(to: DataPoints.P2(x: x, y: y))
                  let dataHits = hits.flatMap { $0.dataPointIds.compactMap { id2pt[$0] } }
                  if let hit0 = hits.first {
                    print("Tapped \(x), \(y): \(hit0.duration) \(dataHits.map { "\($0.id)=\($0.durations)" })")
//                    for pp in pts {
//                      guard pp.p2.x == x && pp.p2.y == y else {
//                        continue
//                      }
//                      print("Found \(pp)")
//                    }
                  } else {
                    print("No data at \(x), \(y)")
                  }
                }
             }
          }

        }
        .padding()
    }
}

//#Preview {
//    ContentView()
//}
