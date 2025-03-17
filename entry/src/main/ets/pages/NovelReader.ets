import { NovelChapter, NovelDetail, NovelVolume } from 'libdaisy_native.so'
import { common } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import rust from 'libdaisy_native.so'
import { Loading } from './components/Loading';
import { Error } from './components/Error';
import { navStack } from './components/Nav';

export interface NovelReaderParam {
  novel: NovelDetail,
  novelChapters: NovelVolume[];
  chapterId: number,
  process: number,
}

@Entry
@Component
export struct NovelReader {
  private listScroller: ListScroller = new ListScroller()
  private context = getContext(this) as common.UIAbilityContext;
  @State param: NovelReaderParam | null = null
  @State loadingState: number = 0
  @State volume: NovelVolume | null = null;
  @State chapter: NovelChapter | null = null;
  @State nextChapter: NovelChapter | null = null;
  @State data: string | null = null
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
    this.nextChapter = this.nextChapterValue()
    this.volume = null;
    this.chapter = null;
    try {
      for (let volume of this.param!.novelChapters) {
        for (let chapter of volume.chapters) {
          if (chapter.chapterId == this.param!.chapterId) {
            this.volume = volume;
            this.chapter = chapter;
          }
        }
      }
      this.data = await rust.novelContent(
        this.volume!.id,
        this.chapter!.chapterId,
      );
      await rust.novelViewPage(
        this.param!.novel.id,
        this.volume!.id,
        this.volume!.title,
        this.volume!.rank,
        this.chapter!.chapterId,
        this.chapter!.chapterName,
        this.chapter!.chapterOrder,
        this.param!.process,
      );
      this.loadingState = 1
    } catch (e) {
      this.loadingState = 2
    }
  }

  setChapter(chapter: NovelChapter) {
    this.loadingState = 0
    this.listScroller.scrollTo({ xOffset: 0, yOffset: 0 })
    this.param!.chapterId = chapter.chapterId
    this.data = null
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
      this.param = context.pathInfo.param! as NovelReaderParam
      this.init()
    })
    .backgroundColor('#000')
    .hideTitleBar(true)
    .ignoreLayoutSafeArea([LayoutSafeAreaType.SYSTEM]) // LayoutSafeAreaEdge
  }

  @Builder
  content(param: NovelReaderParam) {
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
          // this.sliding()
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
      // Slider({
      //   value: this.sliderValue,
      //   min: 0,
      //   max: this.data!.pageUrl.length - 1,
      //   step: 1,
      // })
      //   .onTouch((e) => {
      //     if (e.type == TouchType.Down) {
      //       this.sliderInValue = this.sliderValue
      //       this.sliderOutValue = this.sliderInValue
      //     }
      //     if (e.type == TouchType.Up) {
      //       console.error(`LEAVE ${this.sliderInValue} ${this.sliderOutValue}`)
      //       if (this.sliderOutValue != this.sliderInValue) {
      //         this.sliderValue = this.sliderOutValue
      //         this.listScroller.scrollToIndex(this.sliderValue + 1)
      //       }
      //       this.sliderInValue = undefined
      //     }
      //   })
      //   .onChange((e) => {
      //     if (this.sliderValue != undefined) {
      //       this.sliderOutValue = e
      //     }
      //   })
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

  // @Builder
  // sliding() {
  //   Row() {
  //     Text(`${this.sliderOutValue! + 1} / ${this.data!.pageUrl.length}`)
  //       .align(Alignment.Center)
  //       .alignSelf(ItemAlign.Center)
  //       .textAlign(TextAlign.Center)
  //       .fontColor('#FFF')
  //       .fontWeight(FontWeight.Bold)
  //       .fontSize(35)
  //       .borderRadius(8)
  //       .backgroundColor('#99000000')
  //       .padding(30)
  //   }.alignItems(VerticalAlign.Center)
  // }

  @Builder
  reader(param: NovelReaderParam, data: string) {
    List({ scroller: this.listScroller }) {
      ListItem().height(this.toolBarHeight)

      ListItem() {
        Text(data)
          .fontColor('#fff')
      }

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
    .onScrollIndex((s, e, c) => this.onScrollIndex(s, e, c))
    .onClick(() => {
      this.fullScreen = !this.fullScreen
    })
  }

  onScrollIndex(start: number, end: number, center: number): void {
    // if (this.data != null) {
    //   if (start < 1) {
    //     this.sliderValue = 0
    //   } else if (start >= this.data!.pageUrl.length) {
    //     this.sliderValue = this.data!.pageUrl.length - 1
    //   } else {
    //     this.sliderValue = start - 1
    //   }
    // }
    // if (start > 0 && start <= this.data!.pageUrl.length) {
    //   rust.comicViewPage(
    //     this.param!.manga.id,
    //     this.param!.chapterId,
    //     this.chapter!.chapterTitle,
    //     this.chapter!.chapterOrder,
    //     start - 1,
    //   )
    // }
  }

  toNextChapter() {
    const next = this.nextChapter;
    if (next) {
      this.setChapter(next)
    }
  }

  nextChapterValue(): NovelChapter | null {
    let acc = false
    let vos = this.param!.novelChapters.sort((a,b) => a.rank - b.rank);
    for (let i = 0; i < vos.length; i++) {
      let g = vos[i]!;
      let cs: Array<NovelChapter> = g.chapters.sort((a, b) => a.chapterOrder - b.chapterOrder);
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