[![npm][npm-badge]][npm]
[![react-native][rn-badge]][rn]
[![MIT][license-badge]][license]
[![bitHound Score][bithound-badge]][bithound]
[![Downloads](https://img.shields.io/npm/dm/rnkit-linkface.svg)](https://www.npmjs.com/package/rnkit-linkface)

人脸识别/活体检测-linkface for [React Native][rn].

[**Support me with a Follow**](https://github.com/simman/followers)

[npm-badge]: https://img.shields.io/npm/v/rnkit-linkface.svg
[npm]: https://www.npmjs.com/package/rnkit-linkface
[rn-badge]: https://img.shields.io/badge/react--native-v0.40-05A5D1.svg
[rn]: https://facebook.github.io/react-native
[license-badge]: https://img.shields.io/dub/l/vibe-d.svg
[license]: https://raw.githubusercontent.com/rnkit/rnkit-linkface/master/LICENSE
[bithound-badge]: https://www.bithound.io/github/rnkit/rnkit-linkface/badges/score.svg
[bithound]: https://www.bithound.io/github/rnkit/rnkit-linkface

LinkFace Doc: [http://devdoc.cloud.linkface.cn/](http://devdoc.cloud.linkface.cn/)

## Getting Started

First, `cd` to your RN project directory, and install RNMK through [rnpm](https://github.com/rnpm/rnpm) . If you don't have rnpm, you can install RNMK from npm with the command `npm i -S rnkit-linkface` and link it manually (see below).

### iOS

* #### React Native < 0.29 (Using rnpm)

  `rnpm install rnkit-linkface`

* #### React Native >= 0.29
  `$npm install -S rnkit-linkface`

  `$react-native link rnkit-linkface`

#### Manually
1. Add `node_modules/rnkit-linkface/ios/RNKitLinkFace.xcodeproj` to your xcode project, usually under the `Libraries` group
1. Add `libRNKitLinkFace.a` (from `Products` under `RNKitLinkFace.xcodeproj`) to build target's `Linked Frameworks and Libraries` list
1. Add linkface framework to `$(PROJECT_DIR)/Frameworks.`

### Android

* #### React Native < 0.29 (Using rnpm)

  `rnpm install rnkit-linkface`

* #### React Native >= 0.29
  `$npm install -S rnkit-linkface`

  `$react-native link rnkit-linkface`

#### Manually
1. JDK 7+ is required
1. Add the following snippet to your `android/settings.gradle`:

  ```gradle
include ':rnkit-linkface'
project(':rnkit-linkface').projectDir = new File(rootProject.projectDir, '../node_modules/rnkit-linkface/android/app')
  ```
  
1. Declare the dependency in your `android/app/build.gradle`
  
  ```gradle
  dependencies {
      ...
      compile project(':rnkit-linkface')
  }
  ```
  
1. Import `import io.rnkit.linkface.LinkFacePackage;` and register it in your `MainActivity` (or equivalent, RN >= 0.32 MainApplication.java):

  ```java
  @Override
  protected List<ReactPackage> getPackages() {
      return Arrays.asList(
              new MainReactPackage(),
              new LinkFacePackage()
      );
  }
  ```

Finally, you're good to go, feel free to require `rnkit-linkface` in your JS files.

Have fun! :metal:

## Basic Usage

Import library

```
import RNKitLinkFace from 'rnkit-linkface';
```

### Start

```jsx
try {
  const result = await RNKitLinkFace.start({
    "outType" : "video",
    "Complexity" : 1,
    "sequence" : [
      "BLINK",
      "MOUTH",
      "NOD",
      "YAW"
    ]
  });
	console.log(result);
} catch (error) {
	console.log(`code: ${error.code}, message: ${error.message}`);
}
```

#### Start Input Params

| Key | Type | Default | Description |
| --- | --- | --- | --- |
| Complexity | int |  | 活体检测复杂度
| sequence | array |  | 设置识别序列, 活体检测复杂度 |
| outType | string |  | 输出方案, 单图方案:singleImg, 多图方案:multiImg, 低质量视频方案:video, 高质量视频方案:fullVideo |

#### Start Output Params

| Key | Type | Default | Description |
| --- | --- | --- | --- |
| encryTarData | string |  | 活体识别二进制文件路径 |
| arrSTImage | array[string] |  | 返回的图片路径数组 |
| lfVideoData | string | | 视频地址 |

##### Error

- ArgsNull: 参数不能为空
- BadJson: 解析Json指令失败!
- InitFaild: 初始化失败
- CameraError: 相机权限获取失败
- FaceChanged: 采集失败,人脸变更
- TimeOut: 超时
- WillResignActive: 活体验证失败, 请保持前台运行
- InternalError: 内部错误
- Unknown: 未知错误
- **Cancel**: 用户取消识别


### clean 清理图片临时目录, 上传反馈完, 必须调用此方法

```jsx
RNKitLinkFace.clean();
```

### event MultiLivenessDidStart ( iOS only )

```jsx
import { NativeEventEmitter } from 'react-native';
const nativeEventEmitter = new NativeEventEmitter(RNKitLinkFace);

const listener = nativeEventEmitter.addListener('MultiLivenessDidStart', () => {
	// 此方法可能会回调多次
});

// 使用完后记得移除
listener.remove();
```

### event MultiLivenessDidFail ( iOS only )

```jsx
import { NativeEventEmitter } from 'react-native';
const nativeEventEmitter = new NativeEventEmitter(RNKitLinkFace);

const listener = nativeEventEmitter.addListener('MultiLivenessDidFail', () => {
	// 此方法可能会回调多次
});

// 使用完后记得移除
listener.remove();
```

## Contribution

- [@simamn](mailto:liwei0990@gmail.com) The main author.

## Questions

Feel free to [contact me](mailto:liwei0990@gmail.com) or [create an issue](https://github.com/rnkit/rnkit-linkface/issues/new)

> made with ♥