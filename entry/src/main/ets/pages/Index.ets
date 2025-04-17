import { context } from './components/Context'
import router from '@ohos.router';
import rust from 'daisy_native'

@Entry
@Component
struct Index {
  aboutToAppear(): void {
    this.init()
  }

  async init() {
    await rust.autoClean(3600 * 24 * 7)
    await context.reLogin()
    router.replaceUrl({
      url: 'pages/Home',
    })
  }

  build() {
  }
}