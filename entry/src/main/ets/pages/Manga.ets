import { MangaList } from "./components/MangaList";
import rust from 'daisy_native'
import { ComicUpdateListItem } from 'daisy_native'
import { MangaCardData } from "./components/MangaCard";


class Load {
  load(page: number) {
    return rust.comicUpdateList(
      100,
      page,
    );
  }
}

@Entry
@Component
export struct Manga {
  build() {
    Flex() {
      MangaList({
        loader: new Load(),
      })
        .width('100%')
        .height('100%')
    }
    .width('100%')
    .height('100%')
  }
}