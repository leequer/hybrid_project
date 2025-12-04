import { webview } from '@kit.ArkWeb';
import { picker } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { fileIo } from '@kit.CoreFileKit';

@Entry
@Component
struct AlbumPage {
  @State selectedImagePath: string = '';
  @State showImage: boolean = false;
  webController: webview.WebviewController = new webview.WebviewController();

  // 打开系统相册选择图片
  async openAlbum() {
    try {
      const result = await picker.pick({ 
        MIMEType: picker.PhotoViewMIMETypes.IMAGE_JPEG, 
        maxSelectNumber: 1 
      });
      
      if (result && result.photoUris && result.photoUris.length > 0) {
        this.selectedImagePath = result.photoUris[0];
        this.showImage = true;
        
        // 将图片路径传递给WebView中的HTML页面
        this.webController.evaluateJavaScript(`window.updateImage('${this.selectedImagePath}')`);
      }
    } catch (error) {
      promptAction.showToast({ message: '选择图片失败: ' + error.message });
    }
  }

  build() {
    Column() {
      Button("打开相册")
        .onClick(() => {
          this.openAlbum();
        })
        .margin({ bottom: 10 })
      
      // Web网页容器，显示本地HTML文件
      Web({
        src: 'file://' + getContext().filesDir + '/album/index.html',
        controller: this.webController
      })
        .domStorageAccess(true) // 支持本地存储
        .width("100%")
        .layoutWeight(1)
    }
    .width("100%")
    .height("100%")
    .padding(10)
  }
}