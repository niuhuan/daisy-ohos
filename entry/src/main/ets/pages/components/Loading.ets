@Entry
@Component
export struct Loading {
  @Prop text: string

  build() {
    Column() {
      Progress({
        type: ProgressType.Ring,
        value: 50,
      }).style({ strokeWidth: 20, status: ProgressStatus.LOADING })
      if (this.text != null && this.text.length > 0) {
        Blank()
          .height(20)
        Text(this.text)
      }
    }
    .justifyContent(FlexAlign.Center)
    .height('100%')
    .width('100%')
  }
}