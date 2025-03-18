import { Error } from "./components/Error"
import { Loading } from "./components/Loading"
import { MangaCard, MangaCardData } from "./components/MangaCard"
import rust, { ComicChapter, ComicChapterInfo, ComicDetail, ComicViewLog } from 'libdaisy_native.so'
import { navStack } from "./components/Nav"
import { MangaReaderParam } from "./MangaReader"
import { hilog } from "@kit.PerformanceAnalysisKit"
import { colors } from "./components/Themes"
import { loginListen, LoginListen } from "./components/Context"
import { AppStorageV2, promptAction } from "@kit.ArkUI"

@Entry
@ComponentV2
export struct MangaInfo {
  @Local loadState: '' | 'success' | string = ''
  @Local mangaCardData: MangaCardData | null = null;
  @Local mangaDetail: ComicDetail | null = null;
  @Local mangaViewLog: ComicViewLog | null = null;
  @Local firstShow: boolean = true;
  @Local loginListen: LoginListen = AppStorageV2.connect(LoginListen, () => loginListen)!;
  @Local subscribed: boolean = false;
  @Local subscribing: boolean = false;

  async reloadViewLog() {
    hilog.warn(0, 'testTag', '%{public}s', 'reloadViewLog');
    this.mangaViewLog = await rust.viewLogByComicId(this.mangaCardData!.id);
  }

  async init() {
    this.loadState = '';
    try {
      this.mangaDetail = await rust.comicDetail(this.mangaCardData!.id);
      if (this.loginListen.loginState.status == 0) {
        this.subscribed = await rust.subscribedObj(0, this.mangaDetail!.id);
      }
      await this.reloadViewLog();
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

      ListItem() {
        Text(this.mangaDetail?.description)
          .fontColor(colors.desc)
          .fontSize(13)
          .margin(20)
      }

      ListItem() {
        Column().height(10)
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
    }
    .menus(this.menus())
    .onReady((c) => {
      this.mangaCardData = c.pathInfo.param as MangaCardData;
      this.init()
    })
    .onHidden(() => {
      this.mangaViewLog = null;
    })
    .onShown(() => {
      if (this.firstShow) {
        this.firstShow = false
        return
      }
      this.reloadViewLog()
    })
    .width('100%')
    .height('100%')
  }

  @Builder
  menus() {
    if ('success' == this.loadState) {
      if (this.loginListen.loginState.status == 0) {
        Row() {
          Text() {
            SymbolSpan(
              this.subscribing ? $r('sys.symbol.repeat') :
                this.subscribed ? $r('sys.symbol.folder_fill') : $r('sys.symbol.folder')
            )
              .fontWeight(FontWeight.Normal)
              .fontSize(25)
              .fontColor([colors.icon])
          }
          .onClick(() => {
            this.onSubscribedClick()
          })
        }.alignItems(VerticalAlign.Center)
        .height('100%')
        .padding({ right: 25 })
      }
    }
  }

  async onSubscribedClick() {
    if (this.subscribing) {
      return;
    }
    this.subscribing = true;
    try {
      // "mh" , "xs"
      if (this.subscribed) {
        await rust.subscribeCancel("mh", this.mangaDetail!.id);
      } else {
        await rust.subscribeAdd("mh", this.mangaDetail!.id);
      }
      this.subscribed = !this.subscribed;
      promptAction.showToast({
        message: `订阅已` + (this.subscribed ? "添加" : "取消"),
        duration: 2000,
        showMode: promptAction.ToastShowMode.DEFAULT,
        bottom: 100,
      })
    } catch (e) {
      promptAction.showToast({
        message: "操作失败",
        duration: 2000,
        showMode: promptAction.ToastShowMode.DEFAULT,
        bottom: 100,
      })
    } finally {
      this.subscribing = false;
    }
  }
}
