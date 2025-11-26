import { promptAction } from '@kit.ArkUI'
import { webview } from '@kit.ArkWeb'

@Entry
@Component
struct ConnectPage {
  @State
  currentTime: number = 0
  // 混合开发 需要一个网页容器 Web
  // 端口通信
  // 1. 需要使用controller 创建两个端口
  // 2. 需要把其中一个端口传给网页h5
  // 3. 网页h5用端口给原生端发消息
  // 4. 原生端用剩下的端口来接消息
  controller: webview.WebviewController = new webview.WebviewController()
  currentPorts: webview.WebMessagePort[] = [] // 当前的两个端口
  createPorts () {
    this.currentPorts = this.controller.createWebMessagePorts()
    // 两个电话 一个留给我自己 另外一个传到网页端
    if(this.currentPorts.length) {
      // 要将其中一个传递给 网页端
      this.controller.postMessage("trans_port", [this.currentPorts[1]], "*")
      this.currentPorts[0].onMessageEvent((event: webview.WebMessage) => {
        if(typeof event === "string") {
          const data = JSON.parse(event) as DataResult
          if(data.type === 'change') {
           this.currentTime = data.message
          }
        }
      })
    }
  }
  // 发送消息到h5
  sendMessage () {
    this.currentPorts[0].postMessageEvent(Date.now().toString())
  }
  build() {
    Column() {
      Button("原生组件")
        .onClick(() => {
          promptAction.showToast({ message: '提示消息' })
        })
      Button("发送消息到h5")
        .onClick(() => {
          this.sendMessage()
        })
      Text(this.currentTime.toString())
        .fontSize(20)
      // Web网页容器
      // web组件默认禁止所有的弹出 和验证
      Web({
        src: $rawfile("native.html"),  // string | resource 资源
        controller:  this.controller // 控制器
      })
        .onAlert((event) => {
          promptAction.showToast({ message:  event?.message })
          return true
        })
        .onPageEnd(() => {
          // 此时页面加载完毕
           this.createPorts()
        })
        .width('100%')
        .layoutWeight(1)
    }
    .width("100%")
    .height("100%")
    .padding(10)
  }
}

class DataResult {
  type: string = ""
  message: number = 0
}