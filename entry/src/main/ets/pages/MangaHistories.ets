import { MangaList } from "./components/MangaList";
import rust, { ComicViewLog } from 'libdaisy_native.so'
import { ComicUpdateListItem } from 'libdaisy_native.so'
import { MangaCardData } from "./components/MangaCard";
import { hilog } from "@kit.PerformanceAnalysisKit";

class Load {
  async load(page: number): Promise<Array<MangaCardData>> {
    hilog.error(0x0000, 'testTag', 'E %{public}s %{public}i', 'load', page);
    let raw = await rust.loadComicViewLogs(
      page,
    );
    hilog.error(0x0000, 'testTag', 'E %{public}s %{public}s', 'raw', JSON.stringify(raw));
    return raw.map(this.map);
  }

  map(vl: ComicViewLog): MangaCardData {
    hilog.error(0x0000, 'testTag', 'lv: %{public}s', JSON.stringify(vl) ?? '');
    return {
      id: vl.comicId,
      cover: vl.comicCover,
      title: vl.comicTitle,
      authors: vl.comicAuthors,
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
