import { promptAction } from '@kit.ArkUI'
import { webview } from '@kit.ArkWeb'
import photo from '@rawfile/photo.html'
import { mediaLibrary } from '@kit.MediaLibrary'

@Entry
@Component
struct Index {
  // 混合开发 需要一个网页容器 Web
  private webviewController: webview.WebviewController = new webview.WebviewController()
  private ml: mediaLibrary.MediaLibrary | null = null

  aboutToAppear() {
    // 初始化媒体库
    this.ml = mediaLibrary.getMediaLibrary(getContext())
  }

  build() {
    Column() {
      // Web网页容器
      Web({
        src: photo,  // 加载本地的photo.html文件
        controller: this.webviewController
      })
        .width('100%')
        .height('100%')
        .javaScriptAccess(true) // 允许JavaScript访问
        .onLoadContentFinish(() => {
          // 向JavaScript注入对象
          this.webviewController.registerJavaScriptProxy({
            object: {
              openAlbum: (callbackName: string) => {
                this.openAlbum(callbackName)
              }
            },
            name: 'heima',
            methodList: ['openAlbum']
          })
        })
    }
    .width("100%")
    .height("100%")
  }

  // 打开相册的方法
  async openAlbum(callbackName: string) {
    if (!this.ml) {
      promptAction.showToast({ message: '媒体库初始化失败' })
      return
    }

    try {
      // 选择照片
      const result = await this.ml.selectMediaItems({
        type: mediaLibrary.MediaType.IMAGE,
        selectionMode: mediaLibrary.SelectionMode.SINGLE
      })

      if (result && result.length > 0) {
        // 获取照片的URI
        const photoUri = result[0].uri
        
        // 调用JavaScript回调函数，将照片URI传递给HTML
        this.webviewController.runJavaScript(
          `${callbackName}('${photoUri}')`
        )
      }
    } catch (error) {
      promptAction.showToast({ message: '选择照片失败' })
    }
  }
}