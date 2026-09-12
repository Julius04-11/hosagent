/**
 * 行程时间轴：左侧时间，右侧交通方式与起终点。
 */
import { RouteSegment } from '../models/RoutePlan';
import { Colors } from '../utils/StyleConstants';

@Component
export struct TimelineView {
  @Prop segments: RouteSegment[];

  build() {
    Column({ space: 0 }) {
      ForEach(this.segments, (seg: RouteSegment, index: number) => {
        Row() {
          Column({ space: 2 }) {
            Text(seg.startTime ?? '--:--').fontSize(12).fontColor(Colors.TEXT_SUB)
            Text(seg.endTime ?? '--:--').fontSize(12).fontColor(Colors.TEXT_SUB)
          }.width(52).alignItems(HorizontalAlign.Start)

          Column() {
            Circle({ width: 8, height: 8 }).fill(Colors.PRIMARY)
            if (index < this.segments.length - 1) {
              Divider().vertical(true).height(40).color(Colors.DIVIDER).strokeWidth(1)
            }
          }.width(16).alignItems(HorizontalAlign.Center)

          Column({ space: 2 }) {
            Text(`${seg.mode} · ${seg.from} → ${seg.to}`)
              .fontSize(13).fontColor(Colors.TEXT)
            Text(`${seg.durationMinutes}分钟` +
              (seg.distanceMeters ? ` · ${Math.round(seg.distanceMeters / 1000 * 10) / 10}公里` : ''))
              .fontSize(11).fontColor(Colors.TEXT_SUB)
          }.alignItems(HorizontalAlign.Start).layoutWeight(1)
        }
        .width('100%')
        .alignItems(VerticalAlign.Top)
        .padding({ top: 4, bottom: 4 })
      }, (seg: RouteSegment, index: number) => `${index}-${seg.mode}-${seg.from}`)
    }
    .width('100%')
  }
}
