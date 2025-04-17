import rust, { ComicDetail, Item } from 'daisy_native'
import { CachedImage } from './CachedImage'
import { materialIconData, materialIconsFontFamily } from './MaterialIcons'
import { colors } from './Themes'

export interface MangaCardData {
  id: number
  cover: string
  title: string
  authors?: string
  authorItems?: Array<Item>
  lastUpdateTime?: number,
  subUpdate?: string,
}

@Entry
@Component
export struct MangaCard {
  @Require @Prop item: MangaCardData

  build() {
    Flex() {
      CachedImage({
        source: this.item.cover,
        useful: 'COMIC_COVER',
        extendsFieldIntFirst: this.item.id,
        borderOptions: { radius: 3.5 },
        imageWidth: 328 / 4,
        imageHeight: 422 / 4,
      }
      )
        .width(328 / 4)
        .height(422 / 4)
        .flexShrink(0)
        .flexGrow(0)
      Blank(10)
      Column() {
        Blank(10)
        Text(`${this.item.title}\n`)
          .maxLines(2)
          .fontWeight(FontWeight.Bold)
        if (this.item.authorItems != null && this.item.authorItems.length > 0) {
          Blank(10)
          Text(this.item.authorItems.map((e) => e.title).join("、"))
            .fontSize(14)
            .fontColor(colors.authorColor)
        } else if (this.item.authors != null && this.item.authors.length > 0) {
          Blank(10)
          Text(this.item.authors)
            .fontSize(14)
            .fontColor(colors.authorColor)
        }
        Blank(10)
        Flex({ wrap: FlexWrap.Wrap }) {
          if (this.item.lastUpdateTime != null) {
            Text(`更新时间 ${timestampToDate(this.item.lastUpdateTime)}`)
              .flexGrow(0)
              .flexShrink(0)
            Blank(1)
              .width(30)
          }
          if (this.item.subUpdate != null) {
            Text(`更新至 ${this.item.subUpdate}`)
              .flexGrow(0)
              .flexShrink(0)
            Blank(1)
              .width(30)
          }
          // Text(materialIconData('local_fire_department'))
          //   .fontFamily(materialIconsFontFamily)
          //   .fontColor(colors.authorColor)
          //   .fontSize(16)
          // Text(` ${this.item.popular}`)
          //   .flexGrow(0)
          //   .flexShrink(0)
          //   .fontSize(14)
        }
      }
      .flexGrow(1)
      .alignItems(HorizontalAlign.Start)
    }
    .padding({
      top: 8,
      bottom: 8,
      left: 15,
      right: 15
    })
    .border({
      color: '#33666666',
      width: .4,
    })
    .width('100%')
  }
}


// 方法一：使用JavaScript内置的Date对象进行时间戳转日期的实现
function timestampToDate(timestamp: number) {
  let date = new Date(timestamp * 1000);
  let year = date.getFullYear();
  let month = date.getMonth() + 1; // 月份从0开始，需要加1
  let day = date.getDate();
  let hours = date.getHours();
  let minutes = date.getMinutes();
  let seconds = date.getSeconds();
  return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`;
}
