import { request, zlib } from '@kit.BasicServicesKit'
import { fileIo } from '@kit.CoreFileKit'
import { promptAction, router } from '@kit.ArkUI'

@Entry
@Component
struct HotReload {
  // 下载资源
  async downLoad() {
    const context = getContext()
    // context.filesDir // 沙箱目录files目录
    // context.cacheDir
    //  context.tempDir
    const fileName = "toutiao.zip"
    const filePath = context.filesDir + "/" + fileName
    // 只要你下载 下载是最新的 原有的东西要备份
    if (fileIo.listFileSync(context.filesDir).includes(fileName)) {
      // 此时要备份
      fileIo.renameSync(filePath, context.filesDir + "/toutiao.bak.zip") // 重命名
    }
    const task = await request.downloadFile(context, {
      url: 'https://gitee.com/shuiruohanyu/toutiao_net/raw/master/resources/toutiao.zip', // 文件从哪里来
      filePath // 文件存到哪里去 只有一个地方 沙箱目录
    })
    task.on("complete", () => {
      // 认为下载完成
      promptAction.showToast({ message: "下载完成" })
      // 要去解压
      this.decompressFile(filePath)
    })
    task.on("progress", () => {

    })
    task.on("fail", () => {

    })
  }
  // 解压文件
 async decompressFile(path: string ) {
   await zlib.decompressFile(path, getContext().filesDir)
   promptAction.showToast({ message: '解压完成' })
   router.pushUrl({
     url: 'pages/WebPage'
   })
  }

  build() {
    Row() {
      Column() {
        Button("更新包")
          .onClick(() => {
            // 1 检查 下载 资源包
            // 2 下载的包放入到沙箱目录
            // 3 zip进行解压
            // 4. 解压完成直接预览打开
            this.downLoad()
          })
      }
      .width("100%")

    }
    .height('100%')
  }
}