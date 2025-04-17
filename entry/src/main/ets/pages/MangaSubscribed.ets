import { MangaList } from "./components/MangaList";
import rust, { ComicViewLog, Subscribed } from 'daisy_native'
import { ComicUpdateListItem } from 'daisy_native'
import { MangaCardData } from "./components/MangaCard";
import { hilog } from "@kit.PerformanceAnalysisKit";

class Load {
  async load(page: number): Promise<Array<MangaCardData>> {
    let raw = await rust.subscribedList(
      0,
      page,
    );
    return raw.map(this.map);
  }

  map(vl: Subscribed): MangaCardData {
    return {
      id: vl.id,
      cover: vl.subImg,
      title: vl.name,
      subUpdate: vl.subUpdate,
    };
  }
}

@Component
@Entry
export struct MangaSubscribed {
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
    .title('漫画 - 订阅')
  }
}
