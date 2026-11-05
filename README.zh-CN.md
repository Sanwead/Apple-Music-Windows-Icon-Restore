# Apple Music Windows Icon Restore

为微软商店版 Apple Music 恢复红色运行图标。

## 使用

需要 64 位 Windows、系统内置的 Windows PowerShell 5.1 和微软商店版 Apple Music。
下载并解压项目，放在长期保留、当前用户可写的文件夹中。在该文件夹打开 Windows PowerShell：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Install.ps1 -StartWithWindows
```

打开 Apple Music 后通常三秒内变红。省略 `-StartWithWindows` 可仅在本次登录期间运行。
添加 `-IconPath "C:\路径\自选.ico"` 可使用自己的图标，更换后请重新打开 Apple Music。
运行期间不要移动项目或图标；需要搬动时先卸载，再从新位置安装。

关闭辅助程序并取消登录启动：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Uninstall.ps1
```

之后关闭并重新打开 Apple Music，即可恢复默认窗口图标。卸载保留项目和本地配置文件。

无需管理员权限、Python 或额外下载。后台每三秒检查一次，直到卸载或退出登录。
PowerShell 后台进程的内存占用高于原生程序。脚本未签名，组织管理的设备可能禁止运行。

## 原理和限制

单独修改窗口图标可能只让悬停缩略图变红。本工具同时设置窗口的 AppUserModelID、
任务栏图标资源、重新启动命令与显示名称。自定义标识可能影响任务栏分组与跳转列表。
不处理开始菜单、桌面快捷方式或已有的任务栏固定快捷方式。

已在一台 Windows 电脑、Apple Music 1.1792.39682.0 上验证运行时任务栏图标变红；
其他版本和固定图标行为尚未验证。系统或应用更新后可能需要调整。

不修改安装包，不接管 WindowsApps 权限，不注入代码，不读取账号或播放记录，辅助程序不联网。

代码与文档使用 [MIT](LICENSE) 许可证。Apple 图标素材和商标不包含在 MIT 授权范围内，
来源和说明见 [NOTICE.md](NOTICE.md)。本项目与 Apple 无隶属关系。
