import { loginListen, LoginListen } from "./components/Context"
import { materialIconData, materialIconsFontFamily } from "./components/MaterialIcons"
import { navStack } from "./components/Nav"
import { colors } from "./components/Themes"
import { AppStorageV2 } from "@kit.ArkUI"

@Entry
@ComponentV2
export struct Person {
  @Local loginListen: LoginListen = AppStorageV2.connect(LoginListen, () => loginListen)!;

  build() {
    List() {
      ListItem() {
        this.profile()
      }

      ListItem() {
        Divider()
          .strokeWidth(.5)
          .width('100%')
          .color('#66cccccc')
          .margin({
            top: 10,
            bottom: 20,
          })
      }

      ListItem() {
        this.mangaHistories()
      }

      ListItem() {
        this.novelHistories()
      }
    }
  }

  @Builder
  profile() {
    Column() {
      Blank().height(50)
      Text(materialIconData(this.profileIcon()))
        .fontFamily(materialIconsFontFamily)
        .fontSize(30)
        .border({
          width: 3,
          color: colors.authorColor,
          style: BorderStyle.Solid,
        })
        .width(80)
        .height(80)
        .textAlign(TextAlign.Center)
        .borderRadius(50)
      Blank().height(30)
      Text(this.profileName())
      Blank().height(40)
    }.align(Alignment.Center)
    .width('100%')
    .onClick(() => {
      this.onProfileClick()
    })
  }

  profileIcon(): string {
    if (this.loginListen.loginState.status == 0) {
      return 'person';
    }
    if (this.loginListen.loginState.status == -2) {
      return 'autorenew';
    }
    if (this.loginListen.loginState.status == 2) {
      return 'error';
    }
    return 'unknown';
  }

  profileName(): string {
    if (this.loginListen.loginState.status == 0) {
      return this.loginListen.loginState.data?.nickname ?? "已登录";
    }
    if (this.loginListen.loginState.status == -2) {
      return '登录中';
    }
    if (this.loginListen.loginState.status == 2) {
      return `登录失败 ${this.loginListen.loginState.message}`
    }
    return '点击卡片进行登录';
  }

  onProfileClick() {
    if (this.loginListen.loginState.status == -1 || this.loginListen.loginState.status == 2) {
      navStack.pushPath(new NavPathInfo('pages/Login', ''))
    }
  }

  @Builder
  mangaHistories() {
    Flex({ direction: FlexDirection.Row }) {
      Text('漫画 - 历史记录')
    }
    .padding({
      top: 18,
      bottom: 18,
      left: 25,
      right: 25
    })
    .border({
      color: '#33666666',
      width: .4,
    })
    .width('100%')
    .onClick(()=>{
      navStack.pushPath(new NavPathInfo(
        'pages/MangaHistories',
        '',
      ))
    })
  }

  @Builder
  novelHistories() {
    Flex({ direction: FlexDirection.Row }) {
      Text('小说 - 历史记录')
    }
    .padding({
      top: 18,
      bottom: 18,
      left: 25,
      right: 25
    })
    .border({
      color: '#33666666',
      width: .4,
    })
    .width('100%')
  }
}