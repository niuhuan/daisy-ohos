import { NovelDetail } from 'libdaisy_native.so'

export interface NovelReaderParam {
  novel: NovelDetail,
  chapterId: number,
  process: number,
}

@Entry
@Component
export struct NovelReader {
  build() {
  }
}