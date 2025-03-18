import { loginListen } from './Context';
import { Error } from './Error'
import { Loading } from './Loading';
import { MangaCard, MangaCardData } from './MangaCard';
import { navStack } from './Nav';
import { Nothing } from './Nothing';
import { promptAction } from '@kit.ArkUI';

interface MangaLoader {
  load(page: number): PromiseLike<Array<MangaCardData>>;
}

@Entry
@Component
export struct MangaList {
  @State loading: boolean = false;
  @State needLoadPageNumber: number = 0;
  @State end: boolean = false;
  @State mangaList: Array<MangaCardData> = [];
  @State error: boolean = false;
  @State errorMessage: string = "";
  @Prop @Require loader: MangaLoader;
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
        ForEach(this.mangaList, (item: MangaCardData, idx: number) => {
          ListItem() {
            MangaCard({ item: item })
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

  goToMangaInfo(item: MangaCardData) {
    if (loginListen.loginState.status == -1 || loginListen.loginState.status == 2) {
      promptAction.showToast({
        message: '请先登录',
        duration: 2000,
        showMode: promptAction.ToastShowMode.DEFAULT,
        bottom: 100,
      })
      return
    }
    if (loginListen.loginState.status == -2) {
      promptAction.showToast({
        message: '正在登录, 请稍后',
        duration: 2000,
        showMode: promptAction.ToastShowMode.DEFAULT,
        bottom: 100,
      })
      return
    }
    navStack.pushPath(new NavPathInfo(
      'pages/MangaInfo',
      item,
    ))
  }
}