/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import LocationPopup from '../components/LocationPopup'
import { StyleConstant } from '../constant/StyleConstant'
import TabMainView from './TabMainView'


@Entry
@Component
export default struct HomePageView {
  @State changeValue: string = ''
  @State submitValue: string = ''


  build() {
    Column(){
      Column() {
        Row() {
          Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center,justifyContent:FlexAlign.SpaceBetween }) {
            LocationPopup({'locationText':$r('app.string.location_text')})
            Image($r('app.media.down_arrow'))
              .width($r('app.float.vp_twenty'))
              .objectFit(ImageFit.Contain)
              .margin({ left: $r('app.float.vp_five'), right: $r('app.float.vp_five') })

            Search({ value: this.changeValue, placeholder: $r('app.string.search_placeholder') })
              .searchIcon({
                src: $r('sys.media.ohos_ic_public_search_filled')
              })
              .height($r('app.float.forty'))
              .maxLength(StyleConstant.TWENTY)
              .backgroundColor('rgba(0, 0, 0, 0.05)')
              .placeholderColor(Color.Grey)
              .placeholderFont({ size: $r('app.float.vp_fourteen'), weight: StyleConstant.FOUR_HUNDRED })
              .textFont({ size: $r('app.float.vp_fourteen'), weight: StyleConstant.FOUR_HUNDRED  })
              .onSubmit((value: string) => {
                this.submitValue = value
              })
              .onChange((value: string) => {
                this.changeValue = value
              })
              .margin($r('app.float.vp_twenty'))
          }
        }.padding({left:$r('app.float.vp_ten')})
        .height($r('app.float.forty'))
        .alignItems(VerticalAlign.Center)
      }
      .width($r('app.string.full_width'))

      TabMainView()

    }.height('100%')
  }
}