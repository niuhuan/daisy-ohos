import { common } from "@kit.AbilityKit";
import { window } from "@kit.ArkUI";
import rust, { ComicChapter, ComicChapterDetail, ComicChapterInfo, ComicDetail, ComicViewLog } from 'libdaisy_native.so'
import { image } from "@kit.ImageKit";
import { Loading } from "./components/Loading";
import { Error } from "./components/Error";
import { navStack } from "./components/Nav";
import { CachedImage } from "./components/CachedImage";


export interface MangaReaderParam {
  manga: ComicDetail,
  chapterId: number,
  pageRank: number,
}

@Entry
@Component
export struct MangaReader {
  private listScroller: ListScroller = new ListScroller()
  private context = getContext(this) as common.UIAbilityContext;
  @State param: MangaReaderParam | null = null
  @State loadingState: number = 0
  @State chapter: ComicChapterInfo | null = null;
  @State nextChapter: ComicChapterInfo | null = null;
  @State data: ComicChapterDetail | null = null
  @State sizeMap: Map<number, image.Size> = new Map()
  @State toolBarHeight: number = 0
  @State fullScreen: boolean = false
  @State sliderValue: number = 0
  @State sliderInValue: number | undefined = undefined
  @State sliderOutValue: number = 0

  async init() {
    this.loadingState = 0
    let win = await window.getLastWindow(this.context)
    const avoidAreaType = window.AvoidAreaType.TYPE_SYSTEM;
    const avoidArea = win.getWindowAvoidArea(avoidAreaType);
    const height = avoidArea.topRect.height;
    this.toolBarHeight = height
    this.chapter =
      this.param!.manga.chapters.flatMap(cg => cg.data).filter(c => c.chapterId == this.param!.chapterId)[0];
    this.nextChapter = this.nextChapterValue()
    try {
      this.data = await rust.comicChapterDetail(this.param!.manga.id, this.param!.chapterId)
      await rust.comicViewPage(
        this.param!.manga.id,
        this.param!.chapterId,
        this.chapter!.chapterTitle,
        this.chapter!.chapterOrder,
        0,
      )
      this.loadingState = 1
    } catch (e) {
      this.loadingState = 2
    }
  }

  setChapter(chapter: ComicChapterInfo) {
    this.loadingState = 0
    this.listScroller.scrollTo({ xOffset: 0, yOffset: 0 })
    this.param!.chapterId = chapter.chapterId
    this.data = null
    this.sizeMap.clear()
    this.sliderValue = 0
    this.sliderInValue = undefined
    this.init()
  }

  build() {
    NavDestination() {
      if (this.param != null) {
        this.content(this.param!)
      }
    }.onReady(context => {
      this.param = context.pathInfo.param! as MangaReaderParam
      this.init()
    })
    .backgroundColor('#000')
    .hideTitleBar(true)
    .ignoreLayoutSafeArea([LayoutSafeAreaType.SYSTEM]) // LayoutSafeAreaEdge
  }

  @Builder
  content(param: MangaReaderParam) {
    if (this.loadingState == 0) {
      Loading()
    } else if (this.loadingState == 1) {
      Stack() {
        this.reader(param, this.data!)
        if (!this.fullScreen) {
          this.barTop()
          this.barBottom()
        }
        if (this.sliderInValue != undefined) {
          this.sliding()
        }
      }
    } else {
      Error({ errorMessage: '点击重试' })
        .flexGrow(1)
        .flexShrink(1)
        .onClick(() => {
          this.init()
        })
    }
  }

  @Builder
  barTop() {
    Flex() {
      Text() {
        SymbolSpan($r('sys.symbol.arrow_left'))
          .fontSize(20)
      }.fontColor('#fff')
      .onClick(() => {
        navStack.pop()
      })
    }.position({ top: 0 })
    .padding({
      top: 45,
      bottom: 25,
      left: 30,
      right: 20
    })
    .backgroundColor('#99000000')
  }

  @Builder
  barBottom() {
    Flex() {
      Slider({
        value: this.sliderValue,
        min: 0,
        max: this.data!.pageUrl.length - 1,
        step: 1,
      })
        .onTouch((e) => {
          if (e.type == TouchType.Down) {
            this.sliderInValue = this.sliderValue
            this.sliderOutValue = this.sliderInValue
          }
          if (e.type == TouchType.Up) {
            console.error(`LEAVE ${this.sliderInValue} ${this.sliderOutValue}`)
            if (this.sliderOutValue != this.sliderInValue) {
              this.sliderValue = this.sliderOutValue
              this.listScroller.scrollToIndex(this.sliderValue + 1)
            }
            this.sliderInValue = undefined
          }
        })
        .onChange((e) => {
          if (this.sliderValue != undefined) {
            this.sliderOutValue = e
          }
        })
    }
    .position({ bottom: 0 })
    .padding({
      top: 10,
      bottom: 25,
      left: 20,
      right: 20
    })
    .backgroundColor('#99000000')

  }

  @Builder
  sliding() {
    Row() {
      Text(`${this.sliderOutValue! + 1} / ${this.data!.pageUrl.length}`)
        .align(Alignment.Center)
        .alignSelf(ItemAlign.Center)
        .textAlign(TextAlign.Center)
        .fontColor('#FFF')
        .fontWeight(FontWeight.Bold)
        .fontSize(35)
        .borderRadius(8)
        .backgroundColor('#99000000')
        .padding(30)
    }.alignItems(VerticalAlign.Center)
  }

  @Builder
  reader(param: MangaReaderParam, data: ComicChapterDetail) {
    List({ scroller: this.listScroller, initialIndex: this.param!.pageRank > 0 ? this.param!.pageRank + 1 : null }) {
      ListItem().height(this.toolBarHeight)
      ForEach(
        data.pageUrl,
        (image: string, idx) => {
          ListItem() {
            CachedImage({
              source: image,
              useful: 'comic_reader',
              extendsFieldIntFirst: param.manga.id,
              extendsFieldIntSecond: param.chapterId,
              extendsFieldIntThird: idx,
              onSize: {
                onSize: (size) => this.sizeMap[idx] = size
              },
              imageWidth: '100%',
              ratio: this.sizeMap[idx] ? this.sizeMap[idx]!.width / this.sizeMap[idx].height : 1,
            })
          }
        }
      )

      ListItem().height(this.toolBarHeight)

      ListItem() {
        Column() {
          Text(' 下一章 ')
            .padding(40)
            .fontSize(35)
            .fontColor('#fff')
            .backgroundColor('#66999999')
            .align(Alignment.Center)
            .alignSelf(ItemAlign.Center)
            .onClick(() => this.toNextChapter())
        }.alignItems(HorizontalAlign.Center)
        .width('100%')
      }

      ListItem().height(this.toolBarHeight)
    }
    .width('100%')
    .height('100%')
    .onScrollIndex((s, e, c) => {
      if (this.data != null) {
        if (s < 1) {
          this.sliderValue = 0
        } else if (s >= this.data!.pageUrl.length) {
          this.sliderValue = this.data!.pageUrl.length - 1
        } else {
          this.sliderValue = s - 1
        }
      }
    })
    .onScrollIndex((s, e, c) => this.onScrollIndex(s, e, c))
    .onClick(() => {
      this.fullScreen = !this.fullScreen
    })
  }

  onScrollIndex(start: number, end: number, center: number): void {
    if (center > 0 && center <= this.data!.pageUrl.length) {
      rust.comicViewPage(
        this.param!.manga.id,
        this.param!.chapterId,
        this.chapter!.chapterTitle,
        this.chapter!.chapterOrder,
        center - 1,
      )
    }
  }

  toNextChapter() {
    const next = this.nextChapter;
    if (next) {
      this.setChapter(next)
    }
  }

  nextChapterValue(): ComicChapterInfo | null {
    let acc = false
    for (let i = 0; i < this.param!.manga.chapters.length; i++) {
      let g = this.param!.manga.chapters[i]!;
      let cs: Array<ComicChapterInfo> = g.data.sort((a, b) => a.chapterOrder - b.chapterOrder);
      for (let j = 0; j < cs.length; j++) {
        let c = cs[j]!;
        if (acc) {
          return c
        }
        if (c.chapterId == this.param!.chapterId) {
          acc = true
        }
      }
    }
    return null
  }
}
