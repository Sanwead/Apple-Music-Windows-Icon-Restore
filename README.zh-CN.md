# Apple Music Windows Icon Restore

为微软商店官方 Apple Music 恢复红色运行图标。随 Apple Music 启动，进程退出后自动结束。
不开机常驻、不注入 DLL、不修改安装文件，也不需要重新打包应用。

## 安装

1. 从微软商店安装官方 Apple Music。
2. 下载并解压本项目，放在长期保留、当前用户可写的文件夹中。
3. 使用 Apple Music 的同一账户双击 **Install.cmd**。
4. 从开始菜单或原有快捷方式正常打开 Apple Music。

需要 64 位 Windows 和系统自带的 Windows PowerShell 5.1。在已测试的配置上无需管理员权限、
开发者模式、Python 或额外下载。组织管理的设备可能限制脚本、计划任务或事件日志访问。

可在项目目录打开 Windows PowerShell，指定自己的图标：

```powershell
.\Install.ps1 -IconPath "C:\路径\自选.ico"
```

运行期间不要移动项目或图标；搬动时先卸载，再从新位置安装。
安装时已打开的 Apple Music 会立即应用修改。旧参数 `-StartWithWindows` 已移除；
安装器会清除旧版在本项目目录创建的登录启动快捷方式。

## 关闭与卸载

双击 **Uninstall.cmd**，之后关闭并重新打开 Apple Music。
只移除图标工具的启动任务，不卸载 Apple Music，不删除下载的项目和配置。

辅助程序只跟随绑定的 AppleMusic.exe 进程运行。关闭窗口可能仍让 Apple Music 留在后台；
真正退出 Apple Music 进程后，辅助程序才退出。启动后没有找到对应进程时，最多等待 20 秒。
没有登录触发器，也没有一个常驻程序负责等待下次启动。

## 原理

Windows 计划任务监听 AppModel-Runtime/Admin 日志的 201 事件，并过滤 Apple Music 的
应用标识与进程名。音乐应用启动时，Windows 才启动隐藏的图标程序。
图标程序每次查询当前安装路径，验证进程路径和会话，绑定实际进程，再设置窗口和任务栏图标属性。
不改变开始菜单或桌面快捷方式图标。

事件触发方法参考并改编自 [AMExclusive](https://github.com/AntiOblivionis/AMExclusive)，
保留其 MIT 许可声明，见 [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)。
本工具不包含其 DLL、注入代码或音频修改功能。

不接管 WindowsApps 权限，不启用开发者模式，不修改 Apple Music 安装文件或重新注册应用。
不读取账号和播放记录，不联网。仅在本地 state 文件夹写入诊断信息，该目录不会提交到 Git。
PowerShell 的内存占用高于原生小程序；脚本未签名，组织策略可能禁止运行。

## 更新会怎样

保留官方商店安装方式，不替换应用的更新机制。每次启动重新查询安装路径，
不会把某个版本的 WindowsApps 目录写死。
应用更新后重新打开，只要启动事件和窗口机制未变，工具应能再次应用红色图标。

不能保证未来每个版本都兼容：系统事件、应用标识、窗口结构或权限变化时可能需要更新工具。
任务栏分组、跳转列表及已固定按钮的表现也可能受自定义运行标识影响。
其他 Windows 版本和 ARM64 尚未验证。

如果之前安装过资源修改开发版，需先恢复微软商店官方版。
本安装器不会自行卸载或重装音乐应用，也不会处理其账号和资料库数据。

## 测试与许可证

`Test-Interop.ps1` 验证图标读取、互操作编译、临时窗口属性写入及清除。
事件触发、自动退出和可见图标还需实际 Windows 集成验证。

项目代码和文档使用 [MIT](LICENSE)，改编代码保留原 MIT 声明。
Apple 图标素材与商标不属于 MIT 授权范围，来源见 [NOTICE.md](NOTICE.md)。本项目与 Apple 无隶属关系。
