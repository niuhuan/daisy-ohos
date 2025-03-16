import { loadProperty, saveProperty } from "libdaisy_native.so"
import { context } from "./components/Context"
import { navStack } from "./components/Nav"
import { colors } from "./components/Themes"

@Entry
@Component
export struct Login {
  @State username: string = ''
  @State password: string = ''

  aboutToAppear(): void {
    this.init()
  }

  async init() {
    this.username = await loadProperty("username")
    this.password = await loadProperty("password")
  }

  build() {
    NavDestination() {
      Flex({ direction: FlexDirection.Column }) {
        Blank().flexBasis(1)

        TextInput({ placeholder: '用户名', text: this.username })
          .onChange((v) => this.username = v)

        Blank().height(20)

        TextInput({ placeholder: '密码', text: this.password })
          .type(InputType.Password)
          .onChange((v) => this.password = v)

        Blank().height(20)

        Button('保存').width('100%').backgroundColor(colors.authorColor)
          .onClick(() => {
            this.onSave()
          })
        Blank().flexBasis(1)
      }.width('100%').height('100%')
      .padding({
        left: 30,
        right: 30,
      })
    }
  }

  onSave() {
    saveProperty('username', this.username)
    saveProperty('password', this.password)
    context.login()
    navStack.pop()
  }
}