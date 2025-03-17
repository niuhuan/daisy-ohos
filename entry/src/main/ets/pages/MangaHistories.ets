import { MangaList } from "./components/MangaList";
import rust, { ComicViewLog } from 'libdaisy_native.so'
import { ComicUpdateListItem } from 'libdaisy_native.so'
import { MangaCardData } from "./components/MangaCard";
import { hilog } from "@kit.PerformanceAnalysisKit";

class Load {
  async load(page: number): Promise<Array<MangaCardData>> {
    let raw = await rust.loadComicViewLogs(
      page,
    );
    return raw.map(this.map);
  }

  map(vl: ComicViewLog): MangaCardData {
    return {
      id: vl.comicId,
      cover: vl.comicCover,
      title: vl.comicTitle,
      authorItems: JSON.parse(vl.comicAuthors),
      lastUpdateTime: vl.comicLastUpdateTime,
    };
  }
}

@Component
@Entry
export struct MangaHistories {
  build() {
    NavDestination() {
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
    .width('100%')
    .height('100%')
    .title('漫画 - 历史记录')
  }
}
