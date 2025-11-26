import { webview } from '@kit.ArkWeb';

@Entry
@Component
struct WebPage {
  @State message: string = 'Hello World';

  build() {
     Column() {
       Web({
         src: "file://" + getContext().filesDir + '/toutiao/index.html',
         controller: new webview.WebviewController()
       })
         .domStorageAccess(true) // 支持本地存储
         .width("100%")
         .height("100%")
     }
    .width("100%")
    .height("100%")
  }
}