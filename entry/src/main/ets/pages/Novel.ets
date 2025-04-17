import { NovelList } from "./components/NovelList"
import rust, { NovelInFilter } from 'daisy_native'

class Load {
  load(pageNumber: number): Promise<Array<NovelInFilter>> {
    return rust.novelList(
      0, 0, 1, pageNumber
    );
  }
}

@Entry
@Component
export struct Novel {
  build() {
    Flex() {
      NovelList({
        loader: new Load(),
      })
        .width('100%')
        .height('100%')
    }
    .width('100%')
    .height('100%')
  }
}