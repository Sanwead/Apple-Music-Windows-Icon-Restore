# Apple Music Windows Icon Restore

把 Windows 版 Apple Music 的任务栏图标换回熟悉的红色。

打开 Apple Music 时，工具自动启动并应用图标；退出 Apple Music 后，工具也随之退出。
应用仍使用微软商店的官方版本和原安装位置。

## 安装

到 [Releases](https://github.com/Sanwead/Apple-Music-Windows-Icon-Restore/releases/latest)
下载 **install.exe**，运行后选择一个独立文件夹，再照常打开 Apple Music。

工具需要 64 位 Windows 和系统自带的 .NET Framework 4.x、Windows PowerShell 5.1。
已在 Windows 11 x64、Apple Music 1.1792.39682.0 上验证。
发布程序未签名，Windows 下载提示中可能显示“未知发布者”。

安装文件夹需要保留，工具会从这里运行。账号、资料库和播放操作都在原来的 Apple Music 中。

也可以下载源码，双击 **Install.cmd** 安装。想换成自己的图标，在项目目录运行：

```powershell
.\Install.ps1 -IconPath "C:\路径\自选.ico"
```

## 运行方式

工具通过 Windows 计划任务接收 Apple Music 的启动事件，然后为当前窗口设置红色图标。
因此平时没有常驻进程；Apple Music 运行期间会有一个 PowerShell 辅助进程。
如果关闭窗口后 Apple Music 仍在后台，辅助进程也会继续运行，直到音乐应用真正退出。

修改的是运行时任务栏和悬停缩略图的图标。开始菜单、桌面快捷方式仍使用应用原有图标。

## 更新

Apple Music 照常通过微软商店更新。工具每次启动都会查询当前安装位置，
更新应用后重新打开即可。若新版改变启动事件或窗口机制，需要再更新本工具。

工具自身升级时，运行新版 **install.exe**，选择现有工具目录即可。

## 卸载

在 Windows“已安装的应用”中卸载 **Apple Music Red Icon**，或运行 **uninstall.exe**。
源码安装版使用 **Uninstall.cmd**。

重新打开 Apple Music 后，图标恢复默认。卸载后可能保留配置、日志及卸载程序，
需要时可手动删除工具文件夹。

## 从源码构建

```powershell
.\packaging\Build-Release.ps1
```

输出位于 `dist/`：`install.exe`、`uninstall.exe` 和 SHA-256 校验文件。
构建使用 Windows 自带的 .NET Framework C# 编译器。

## 致谢与许可

事件触发方案参考 [AMExclusive](https://github.com/AntiOblivionis/AMExclusive)。
项目代码使用 [MIT](LICENSE)；改编代码的许可见 [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)，
Apple 图标素材来源见 [NOTICE.md](NOTICE.md)。
