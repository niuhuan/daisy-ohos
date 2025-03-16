@Entry
@Component
export struct Error {
  @Prop errorMessage: string = "";

  build() {
    Text(`出错了 : ${this.errorMessage}`)
  }
}