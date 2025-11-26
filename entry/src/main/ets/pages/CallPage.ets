import { webview } from '@kit.ArkWeb'
import { promptAction } from '@kit.ArkUI'
import { picker } from '@kit.CoreFileKit'

@Entry
@Component
struct CallPage {
  webSdk: WebSdk = new WebSdk()

  build() {
    Column() {
      Button("调用h5方法")
        .onClick(() => {
          this.webSdk.controller.runJavaScript("test(123)")
        })
      Web({
        src: $rawfile("photo.html"),
        controller: this.webSdk.controller
      })
        .javaScriptProxy({
          name: 'heima', // jsBridge在网页中的全局变量名称
          methodList: ["openAlbum"],
          controller: this.webSdk.controller,
          object: this.webSdk // sdk的工具集
        })// jsBridge
        .width("100%")
        .layoutWeight(1)
    }
    .width("100%")
    .height("100%")
  }
}

class WebSdk {
  controller: webview.WebviewController = new webview.WebviewController()

  // 打开项目
  async openAlbum(methodName: string) {
    const album = new picker.PhotoViewPicker() // 得到相册选择器
    const result = await album.select({
      maxSelectNumber: 1,
      MIMEType: picker.PhotoViewMIMETypes.IMAGE_TYPE
    })
    if (result.photoUris.length) {
      // AlertDialog.show({ message:  result.photoUris[0] })
      // h5调原生 不能 得到异步的结果
      this.controller.runJavaScript(`${methodName}('${result.photoUris[0]}')`)

    }

  }
}