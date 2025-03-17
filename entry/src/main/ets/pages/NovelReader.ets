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
  private webController: WebController = new WebController()
  private context = getContext(this) as common.UIAbilityContext;
  @State param: NovelReaderParam | null = null
  @State loadingState: number = 0
  @State volume: NovelVolume | null = null;
  @State chapter: NovelChapter | null = null;
  @State nextChapter: NovelChapter | null = null;
  @State data: string | null = null
  @State toolBarHeight: number = 0
  @State fullScreen: boolean = false

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
      this.data = this.processData(await rust.novelContent(
        this.volume!.id,
        this.chapter!.chapterId,
      ));
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

  processData(bookText: string): string {
    bookText = bookText.replaceAll("<br />\n", "\n");
    bookText = bookText.replaceAll("<br />\n", "\n");
    bookText = bookText.replaceAll("<br />", "\n");
    bookText = bookText.replaceAll("<br/>", "\n");
    bookText = bookText.replaceAll("&nbsp;", " ");
    bookText = bookText.replaceAll("&amp;", "&");
    bookText = bookText.replaceAll("&hellip;", "…");
    bookText = bookText.replaceAll("&bull;", "·");
    bookText = bookText.replaceAll("&lt;", "<");
    bookText = bookText.replaceAll("&gt;", ">");
    bookText = bookText.replaceAll("&quot;", "\"");
    bookText = bookText.replaceAll("&copy;", "©");
    bookText = bookText.replaceAll("&reg;", "®");
    bookText = bookText.replaceAll("&times;", "×");
    bookText = bookText.replaceAll("&pide;", "÷");
    bookText = bookText.replaceAll("&emsp;", " ");
    bookText = bookText.replaceAll("&ensp;", " ");
    bookText = bookText.replaceAll("&ldquo;", "“");
    bookText = bookText.replaceAll("&rdquo;", "”");
    bookText = bookText.replaceAll("&mdash;", "—");
    bookText = bookText.replaceAll("&middot;", "·");
    bookText = bookText.replaceAll("&lsquo;", "‘");
    bookText = bookText.replaceAll("&rsquo;", "’");
    bookText = bookText.trim();
    return bookText
  }

  setChapter(chapter: NovelChapter) {
    this.loadingState = 0
    this.listScroller.scrollTo({ xOffset: 0, yOffset: 0 })
    this.param!.chapterId = chapter.chapterId
    this.data = null
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
    .backgroundColor('#fff')
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
  reader(param: NovelReaderParam, data: string) {

    List({ scroller: this.listScroller }) {
      ListItem().height(this.toolBarHeight)

      ListItem() {
        Text(data)
          .lineHeight(28)
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
    .padding({ left: 20, right: 20 })
    .onScrollIndex((s, e, c) => this.onScrollIndex(s, e, c))
    .onClick(() => {
      this.fullScreen = !this.fullScreen
    })
  }

  onScrollIndex(start: number, end: number, center: number): void {

  }

  toNextChapter() {
    const next = this.nextChapter;
    if (next) {
      this.setChapter(next)
    }
  }

  nextChapterValue(): NovelChapter | null {
    let acc = false
    let vos = this.param!.novelChapters.sort((a, b) => a.rank - b.rank);
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