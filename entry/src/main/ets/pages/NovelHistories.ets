import { NovelList } from "./components/NovelList";
import rust, { ComicViewLog, NovelInFilter, NovelViewLog } from 'daisy_native'
import { ComicUpdateListItem } from 'daisy_native'
import { hilog } from "@kit.PerformanceAnalysisKit";
import { NovelCardData } from "./components/NovelCard";

class Load {
  async load(page: number): Promise<Array<NovelCardData>> {
    let raw = await rust.loadNovelViewLogs(
      page,
    );
    return raw.map(this.map);
  }

  map(vl: NovelViewLog): NovelCardData {
    return {
      id: vl.novelId,
      name: vl.novelTitle,
      cover: vl.novelCover,
      // authorItems: JSON.parse(vl.novelAuthors),
      // lastUpdateTime: vl.novelLastUpdateTime,
    };
  }
}

@Component
@Entry
export struct NovelHistories {
  build() {
    NavDestination() {
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
    .width('100%')
    .height('100%')
    .title('小说 - 历史记录')
  }
}
