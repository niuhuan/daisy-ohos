import { Error } from "./components/Error"
import { Loading } from "./components/Loading"
import { MangaCard, MangaCardData } from "./components/MangaCard"
import rust, { ComicChapter, ComicChapterInfo, ComicDetail, ComicViewLog } from 'libdaisy_native.so'
import { navEvents, navNamesJoin, navStack } from "./components/Nav"
import { Uuid } from './components/Uuid';
import { MangaReaderParam } from "./MangaReader"

@Entry
@Component
export struct MangaInfo {
  @State loadState: '' | 'success' | string = ''
  @State mangaCardData: MangaCardData | null = null;
  @State mangaDetail: ComicDetail | null = null;
  @State mangaViewLog: ComicViewLog | null = null;
  private uuid: string = '';
  private namesJoin: string = ''

  aboutToAppear(): void {
    this.namesJoin = navNamesJoin()
    this.uuid = Uuid.v4()
    navEvents.set(this.uuid, (nj) => {
      if (nj == this.namesJoin) {
        this.reloadViewLog()
      }
    })
  }

  aboutToDisappear(): void {
    navEvents.delete(this.uuid)
  }

  async reloadViewLog() {
    this.mangaViewLog = await rust.viewLogByComicId(this.mangaCardData!.id);
  }

  async init() {
    this.loadState = '';
    try {
      this.mangaDetail = await rust.comicDetail(this.mangaCardData!.id);
      this.mangaViewLog = await rust.viewLogByComicId(this.mangaCardData!.id);
      this.loadState = 'success'
    } catch (e) {
      this.loadState = `ERROR : ${e}`
    }
  }

  @Builder
  manga() {
    List() {

      ListItem() {
        Column().height(30)
      }

      if (this.mangaViewLog != null && this.mangaViewLog.chapterId > 0) {
        this.continueButton()
        ListItem() {
          Column().height(30)
        }
      }

      ListItem() {
        this.restartButton()
      }

      ListItem() {
        Column().height(30)
      }

      ForEach(this.mangaDetail!.chapters, (c: ComicChapter) => {
        ListItem() {
          if (c.title != "") {
            Text(c.title)
              .padding(10)
          }
        }

        ListItem() {
          Flex({ wrap: FlexWrap.Wrap, alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceEvenly }) {
            ForEach(c.data, (chapterInfo: ComicChapterInfo) => {
              this.chapterButton(chapterInfo)
            })
          }
        }

      })

      ListItem() {
        Column().height(30)
      }
    }.width('100%').height('100%')
  }

  @Builder
  restartButton() {
    Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
      this.chapterButtonA(`从头开始`, null, 0)
    }.width('100%')
  }

  @Builder
  continueButton() {
    Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
      this.chapterButtonA(
        `继续阅读 ${this.mangaViewLog!.chapterTitle} P${this.mangaViewLog!.pageRank + 1}`,
        this.mangaViewLog!.chapterId,
        this.mangaViewLog!.pageRank
      )
    }.width('100%')
  }

  @Builder
  chapterButton(chapterInfo: ComicChapterInfo) {
    this.chapterButtonA(chapterInfo.chapterTitle, chapterInfo.chapterId, 0)
  }

  @Builder
  chapterButtonA(text: string, chapterId: number | null, pageRank: number) {
    Text(text)
      .fontSize(12)
      .margin(10)
      .padding({
        left: 18,
        right: 18,
        top: 10,
        bottom: 10,
      })
      .backgroundColor(Color.White)
      .borderRadius(5)
      .shadow({ radius: 3, color: Color.Gray })
      .onClick(() => {
        if (chapterId == null) {
          chapterId = this.mangaDetail!.chapters[0].data.reduce((a, b) => {
            return a.chapterOrder < b.chapterOrder ? a : b;
          }).chapterId;
        }
        navStack.pushPath(new NavPathInfo(
          "pages/MangaReader",
          {
            manga: this.mangaDetail,
            chapterId: chapterId,
            pageRank: pageRank,
          } as MangaReaderParam,
        ))
      })
      .textAlign(TextAlign.Center)
  }

  build() {
    NavDestination() {
      Flex({ direction: FlexDirection.Column }) {
        MangaCard({ item: this.mangaCardData! })
          .flexGrow(0)
          .flexShrink(0)
        Column() {
          if (this.loadState == 'success') {
            this.manga()
          } else if (this.loadState == '') {
            Loading()
          } else {
            Error({ errorMessage: this.loadState })
          }
        }.layoutWeight(1)
      }.width('100%').height('100%')
    }.onReady((c) => {
      this.mangaCardData = c.pathInfo.param as MangaCardData;
      this.init()
    }).width('100%').height('100%')
  }
}
