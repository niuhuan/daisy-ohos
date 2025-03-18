import rust from "libdaisy_native.so";
import { loginListen } from './Context';
import { Error } from './Error'
import { Loading } from './Loading';
import { navStack } from './Nav';
import { Nothing } from './Nothing';
import { promptAction } from '@kit.ArkUI';
import { NovelCard, NovelCardData } from "./NovelCard";
import { hilog } from "@kit.PerformanceAnalysisKit";

interface NovelLoader {
  load(page: number): PromiseLike<Array<NovelCardData>>;
}


@Entry
@Component
export struct NovelList {
  @State loading: boolean = false;
  @State needLoadPageNumber: number = 0;
  @State end: boolean = false;
  @State mangaList: Array<NovelCardData> = [];
  @State error: boolean = false;
  @State errorMessage: string = "";
  @Prop @Require loader: NovelLoader;
  private scroller: Scroller = new ListScroller()

  aboutToAppear(): void {
    this.load()
  }

  async load(crossError: boolean = false) {
    if (this.loading || this.end) {
      return
    }
    if (!crossError) {
      if (this.error) {
        return;
      }
    }
    try {
      this.loading = true;
      this.error = false;
      let page = await this.loader.load(this.needLoadPageNumber);
      this.end = page.length == 0;
      this.mangaList.push(...page);
      this.needLoadPageNumber++;
    } catch (e) {
      this.errorMessage = `${e}`
      this.error = true;
    } finally {
      this.loading = false;
    }
  }

  build() {
    if (this.mangaList.length == 0) {
      if (this.error) {
        Error({
          errorMessage: this.errorMessage,
        })
      } else if (this.loading) {
        Loading()
      } else {
        Nothing()
      }
    } else {
      List({ scroller: this.scroller }) {
        ForEach(this.mangaList, (item: NovelCardData, idx: number) => {
          ListItem() {
            NovelCard({ item: item })
          }.onClick(() => {
            this.goToMangaInfo(item);
          })
        })
        ListItem() {
          this.paddingLastItem()
        }
      }.onReachEnd(() => {
        this.load()
      })
    }
  }

  @Builder
  paddingLastItem() {
  }

  goToMangaInfo(item: NovelCardData) {
    if (loginListen.loginState.status == -1 || loginListen.loginState.status == 2) {
      promptAction.showToast({
        message: '请先登录',
        duration: 2000,
        showMode: promptAction.ToastShowMode.TOP_MOST,
        bottom: 100,
      })
      return
    }
    if (loginListen.loginState.status == -2) {
      promptAction.showToast({
        message: '正在登录, 请稍后',
        duration: 2000,
        showMode: promptAction.ToastShowMode.TOP_MOST,
        bottom: 100,
      })
      return
    }
    navStack.pushPath(new NavPathInfo(
      'pages/NovelInfo',
      item,
    ))
  }
}