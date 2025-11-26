import { promptAction } from '@kit.ArkUI'
import { webview } from '@kit.ArkWeb'

@Entry
@Component
struct ResourcePage {
  // 混合开发 需要一个网页容器 Web

  build() {
    Column() {
      Button("原生组件")
        .onClick(() => {
          promptAction.showToast({ message: '提示消息' })
        })
      // Web网页容器
      Web({
        src: $rawfile("native.html"),  // string | resource 资源
        controller:  new webview.WebviewController() // 控制器
      })
        .width('100%')
        .layoutWeight(1)
    }
    .width("100%")
    .height("100%")
    .padding(10)
  }
}