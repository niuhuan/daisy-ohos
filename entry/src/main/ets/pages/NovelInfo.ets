import { NovelChapter, NovelDetail, NovelInFilter, NovelVolume, NovelVolumeInfo } from "libdaisy_native.so";

import rust, { } from 'daisy_native'
import { hilog } from "@kit.PerformanceAnalysisKit";
import { NovelCard } from "./components/NovelCard";
import { Loading } from "./components/Loading";
import { Error } from "./components/Error";
import { colors } from "./components/Themes";
import { navStack } from "./components/Nav";
import { NovelReaderParam } from "./NovelReader";

@Entry
@Component
export struct NovelInfo {
  @State loadState: '' | 'success' | string = ''
  @State item: NovelInFilter | null = null;
  @State novelDetail: NovelDetail | null = null;
  @State novelChapters: rust.NovelVolume[] = [];
  @State novelViewLog: rust.NovelViewLog | null = null;
  @State firstShow: boolean = true;

  async reloadViewLog() {
    hilog.warn(0, 'testTag', '%{public}s', 'reloadViewLog');
    this.novelViewLog = await rust.viewLogByNovelId(this.item!.id);
  }

  async init() {
    this.loadState = '';
    try {
      this.novelDetail = await rust.novelDetail(this.item!.id);
      this.novelChapters = await rust.novelChapters(this.item!.id);
      await this.reloadViewLog();
      this.loadState = 'success'
    } catch (e) {
      this.loadState = `ERROR : ${e}`
    }
  }

  @Builder
  novel() {
    List() {

      ListItem() {
        Column().height(30)
      }

      ListItem() {
        Text(this.novelDetail?.introduction)
          .fontColor(colors.desc)
          .fontSize(13)
          .margin(20)
      }

      ListItem() {
        Column().height(10)
      }

      if (this.novelViewLog != null && this.novelViewLog.chapterId > 0) {
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

      ForEach(this.novelChapters, (c: NovelVolume) => {
        ListItem() {
          if (c.title != "") {
            Text(c.title)
              .padding(10)
          }
        }

        ListItem() {
          Flex({ wrap: FlexWrap.Wrap, alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceEvenly }) {
            ForEach(c.chapters, (chapterInfo: NovelChapter) => {
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
        `继续阅读 ${this.novelViewLog!.chapterTitle}`,
        this.novelViewLog!.chapterId,
        this.novelViewLog!.progress,
      )
    }.width('100%')
  }

  @Builder
  chapterButton(chapterInfo: NovelChapter) {
    this.chapterButtonA(chapterInfo.chapterName, chapterInfo.chapterId, 0)
  }

  @Builder
  chapterButtonA(text: string, chapterId: number | null, process: number) {
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
          chapterId = this.novelChapters[0].chapters.reduce((a, b) => {
            return a.chapterOrder < b.chapterOrder ? a : b;
          }).chapterId;
        }
        navStack.pushPath(new NavPathInfo(
          "pages/NovelReader",
          {
            novel: this.novelDetail!,
            novelChapters: this.novelChapters!,
            chapterId: chapterId!,
            process: process,
          } as NovelReaderParam,
        ))
      })
      .textAlign(TextAlign.Center)
  }

  build() {
    NavDestination() {
      Flex({ direction: FlexDirection.Column }) {
        NovelCard({ item: this.item! })
          .flexGrow(0)
          .flexShrink(0)
        Column() {
          if (this.loadState == 'success') {
            this.novel()
          } else if (this.loadState == '') {
            Loading()
          } else {
            Error({ errorMessage: this.loadState })
          }
        }.layoutWeight(1)
      }
      .width('100%')
      .height('100%')
    }
    .onReady((c) => {
      this.item = c.pathInfo.param as NovelInFilter;
      this.init();
    })
    .onHidden(() => {
      this.novelViewLog = null;
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
}