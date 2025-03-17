import { loginListen, LoginListen } from "./components/Context"
import { materialIconData, materialIconsFontFamily } from "./components/MaterialIcons"
import { navStack } from "./components/Nav"
import { colors } from "./components/Themes"
import { Login } from "./Login"
import { Manga } from "./Manga"
import { Novel } from "./Novel"
import { Person } from "./Persion"
import { AppStorageV2 } from "@kit.ArkUI"
import { MangaCard } from "./components/MangaCard"
import { MangaInfo } from "./MangaInfo"
import { MangaReader } from "./MangaReader"
import { NovelReader } from "./NovelReader"
import { NovelInfo } from "./NovelInfo"
import { MangaHistories } from "./MangaHistories"

@Entry
@ComponentV2
struct Home {
  private tabController: TabsController = new TabsController()
  @Local currentIndex: number = 0
  @Local loginListen: LoginListen = AppStorageV2.connect(LoginListen, () => loginListen)!;

  build() {
    Navigation(navStack) {
      this.tabs()
    }.navDestination(this.pageMap)
  }

  @Builder
  pageMap(name: string) {
    if (name == 'pages/Login') {
      Login()
    } else if (name == 'pages/MangaInfo') {
      MangaInfo()
    } else if (name == 'pages/MangaReader') {
      MangaReader()
    } else if (name == 'pages/MangaHistories') {
      MangaHistories()
    } else if (name == 'pages/NovelInfo') {
      NovelInfo()
    } else if (name == 'pages/NovelReader') {
      NovelReader()
    } else {
      NavDestination() {
        Text("未找到页面 404")
      }
    }
  }

  @Builder
  tabs() {
    Tabs({ barPosition: BarPosition.End, controller: this.tabController, index: this.currentIndex }) {
      TabContent() {
        Column() {
          Manga()
            .width('100%')
            .height('100%')
          Blank(1).shadow({
            radius: 3,
            color: '#66666666',
          })
        }
      }.tabBar(this.tabMenu(
        '漫画',
        'auto_stories',
        0
      ))

      TabContent() {
        Column() {
          Novel()
            .width('100%')
            .height('100%')
          Blank(1).shadow({
            radius: 3,
            color: '#66666666',
          })
        }
      }.tabBar(this.tabMenu(
        '小说',
        'menu_book',
        1
      ))

      TabContent() {
        Column() {
          Person()
            .width('100%')
            .height('100%')
          Blank(1).shadow({
            radius: 3,
            color: '#66666666',
          })
        }
      }.tabBar(this.tabMenu(
        '个人',
        'person',
        2
      ))
    }.onChange((i) => this.currentIndex = i)
  }

  @Builder
  tabMenu(name: string, icon: string, index: number) {
    Flex({
      justifyContent: FlexAlign.Center,
      alignItems: ItemAlign.Center,
      direction: FlexDirection.Column
    }) {
      Blank(1)
      Text(materialIconData(icon))
        .fontFamily(materialIconsFontFamily)
        .fontSize(30)
        .fontColor(index == this.currentIndex ? colors.authorColor : colors.notActive)
      Blank(1)
      Text(name)
        .fontSize(12)
        .fontColor(index == this.currentIndex ? colors.authorColor : colors.notActive)
      Blank(1)
    }.width('100%').height('100%')
  }
}