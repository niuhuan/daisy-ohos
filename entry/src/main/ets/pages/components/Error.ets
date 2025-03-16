@Entry
@Component
export struct Error {
  @Prop errorMessage: string

  build() {
    Column() {
      Text('Error')
      if (this.errorMessage != null && this.errorMessage.length > 0) {
        Blank()
          .height(20)
        Text(this.errorMessage)
      }
    }
    .justifyContent(FlexAlign.Center)
    .height('100%')
    .width('100%')
  }
}