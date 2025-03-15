import { loadProperty } from "libdaisy_native.so"

@Entry
@Component
struct Home {
  aboutToAppear(): void {
    this.init()
  }

  async init() {
    loadProperty("a")
  }

  build() {
    Text("Hello") {
    }
  }
}