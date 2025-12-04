import { promptAction } from '@kit.ArkUI'
import { webview } from '@kit.ArkWeb'
import { mediaLibrary } from '@kit.MediaLibraryKit'
import { permission } from '@kit.SecurityKit'
import { BusinessError } from '@kit.BasicServicesKit'

@Entry
@Component
struct Index {
  // WebView控制器
  private webviewController: webview.WebviewController = new webview.WebviewController()
  // 媒体库实例
  private ml: mediaLibrary.MediaLibrary | null = null

  // 初始化媒体库
  async aboutToAppear() {
    try {
      this.ml = await mediaLibrary.getMediaLibrary(getContext())
    } catch (error) {
      console.error('获取媒体库失败:', error)
      promptAction.showToast({ message: '获取媒体库失败' })
    }
  }

  // 打开系统相册
  async openAlbum(callbackName: string) {
    if (!this.ml) {
      promptAction.showToast({ message: '媒体库未初始化' })
      return
    }

    try {
      // 检查读取媒体库权限
      const hasPermission = await permission.requestPermissionsFromUser([permission.CAMERA, permission.READ_MEDIA])
      if (!hasPermission) {
        promptAction.showToast({ message: '需要读取媒体库权限' })
        return
      }

      // 选择图片
      const result = await this.ml.pickMedia({
        type: mediaLibrary.MediaType.IMAGE,
        count: 1
      })

      if (result && result.length > 0) {
        const media = result[0]
        // 获取图片URI
        const uri = media.uri
        // 将图片URI传递给HTML页面
        this.webviewController.runJavaScript(`if (window.${callbackName}) window.${callbackName}('${uri}')`)
      }
    } catch (error) {
      console.error('选择图片失败:', error)
      promptAction.showToast({ message: '选择图片失败' })
    }
  }

  build() {
    Column() {
      // Web网页容器
      Web({
        src: $rawfile('photo.html'),  // 使用本地的photo.html文件
        controller: this.webviewController // 控制器
      })
        .width('100%')
        .layoutWeight(1) // 占据剩余空间
        .javaScriptAccess(true) // 启用JavaScript
        .domStorageAccess(true) // 支持本地存储
        .onLoadFinish(() => {
          // 网页加载完成后，注入原生功能
          this.webviewController.runJavaScript(`
            window.heima = {
              openAlbum: function(callbackName) {
                window.dispatchEvent(new CustomEvent('openAlbum', { detail: callbackName }))
              }
            }
          `)
        })
        .onConsoleLog((event) => {
          // 打印网页控制台日志
          console.log('WebView Log:', event.message)
        })
        .onWindowEvent('openAlbum', (event) => {
          // 处理来自网页的打开相册请求
          const callbackName = event.data as string
          this.openAlbum(callbackName)
        })
    }
    .width("100%")
    .height("100%")
    .padding(10)
  }
}