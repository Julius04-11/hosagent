import { map } from '@kit.MapKit';
import { MapConstants } from '../constants/MapConstants';
import { MetroInfo } from '../model/MetroStationModel';
import { MarkerViewModel } from '../viewmodel/MarkerViewModel';

/**
 * 附近搜索列表组件
 * 显示周边地铁站等POI信息
 */
@Component
export struct SearchNearby {
  // 列表高度
  @State curHeight: string = MapConstants.LIST_HEIGHT_FOLD;
  // 当前索引
  @State curIndex: number = -1;
  @Prop metros: MetroInfo[];
  private scroller: ListScroller = new ListScroller();
  private markerVM: MarkerViewModel = MarkerViewModel.instance;

  aboutToAppear(): void {
    this.markerVM.markerClickCallback = (marker: map.Marker) => {
      this.curIndex = this.markerVM.searchMarkers.indexOf(marker);
      this.curHeight = MapConstants.LIST_HEIGHT_FOLD;
      this.scroller.scrollToIndex(this.curIndex);
      this.markerVM.moveCamera(marker);
    };
  }

  // 修改列表高度
  expanding(offset: number) {
    if (offset > 0 && this.curHeight !== MapConstants.LIST_HEIGHT_FOLD) {
      this.curHeight = MapConstants.LIST_HEIGHT_FOLD;
    } else if (offset < 0 && this.curHeight !== MapConstants.LIST_HEIGHT_EXPAND) {
      this.curHeight = MapConstants.LIST_HEIGHT_EXPAND;
    }
  }

  build() {
    Column({ space: MapConstants.PUBLIC_SPACE_MD }) {
      this.barBuilder();

      this.nearbyBuilder();

      this.listBuilder();
    }
    .height(this.curHeight)
    .width(MapConstants.FULL_SIZE)
    .backgroundColor(Color.White)
    .border({
      width: { bottom: 1 },
      color: Color.Gray,
      radius: { topLeft: MapConstants.BORDER_RADIUS_LARGE, topRight: MapConstants.BORDER_RADIUS_LARGE }
    })
    .padding({
      left: MapConstants.PADDING,
      right: MapConstants.PADDING,
      bottom: MapConstants.PADDING
    })
    .clip(true)
    .animation({ duration: MapConstants.EXPANDING_DURATION })
    .gesture(
      PanGesture({ direction: PanDirection.Vertical })
        .onActionStart((event: GestureEvent) => {
          this.expanding(event.offsetY);
        })
    )
  }

  @Builder
  barBuilder() {
    Row() {
      Row()
        .width(MapConstants.LIST_BAR_WIDTH)
        .height(MapConstants.LIST_BAR_HEIGHT)
        .borderRadius(MapConstants.BORDER_RADIUS_BAR)
        .backgroundColor('#E5E5E5')
    }
    .width(MapConstants.FULL_SIZE)
    .height(MapConstants.IC_BACK_WIDTH)
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Top)
    .padding({ top: MapConstants.PADDING_LARGE / 2 })
  }

  @Builder
  nearbyBuilder() {
    Text('附近地铁站')
      .fontSize(MapConstants.FONT_SIZE_LARGE)
      .fontWeight(FontWeight.Medium)
      .width(MapConstants.FULL_SIZE)
  }

  @Builder
  listBuilder() {
    List({ space: MapConstants.PUBLIC_SPACE, scroller: this.scroller }) {
      ForEach(this.metros, (item: MetroInfo, index) => {
        ListItem() {
          Row() {
            Column() {
              Text(item.name)
                .fontWeight(MapConstants.FONT_WEIGHT)
                .fontSize(MapConstants.FONT_SIZE_MD)
              Text(item.address)
                .fontSize(MapConstants.FONT_SIZE_SMALL)
                .fontColor(Color.Gray)
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)

            Text(`${item.distance.toFixed(0)}m`)
              .fontSize(MapConstants.FONT_SIZE_MD)
              .fontColor('#007AFF')
          }
          .width(MapConstants.FULL_SIZE)
          .backgroundColor(this.curIndex === index ? '#E3F2FD' : Color.White)
          .borderRadius(MapConstants.BORDER_RADIUS)
          .justifyContent(FlexAlign.SpaceBetween)
          .padding(MapConstants.PADDING)
          .onClick(() => {
            this.curIndex = index;
            let marker = this.markerVM.searchMarkers[index];
            this.markerVM.moveCamera(marker);
          })
        }
      }, (item: MetroInfo, index) => JSON.stringify(item) + '_' + index)
    }
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }
}

