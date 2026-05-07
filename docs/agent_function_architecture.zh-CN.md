# XJTU Toolbox 当前功能架构

这份文档总结原 Android 项目的功能架构，方便你或其他智能体在 Flutter 项目中迁移功能时快速定位模块和边界。

## 源码概览

原 Android 项目路径：

```text
D:\learn\code\final\xjtu-toolbox-android
```

主代码目录：

```text
app/src/main/java/com/xjtu/toolbox/
```

原项目是单模块 Kotlin Android 应用，主要技术：

- Jetpack Compose：UI
- MIUIX：HyperOS 风格组件
- OkHttp：网络请求
- Gson / Jsoup：JSON 和 HTML 解析
- Room：本地数据库
- Android EncryptedSharedPreferences：敏感数据存储
- Media3 ExoPlayer：视频播放
- Android AppWidget / RemoteViews：桌面小组件

## 高层运行架构

```text
MainActivity
  AppNavigation
    登录状态恢复
    底部 Tab 和路由分发
    功能页面
  AppLoginState / AppLoginStateViewModel
    共享 CAS 会话
    各子系统登录实例
    CookieJar
    WebVPN 模式
    用户信息和缓存数据

功能页面
  保存局部 UI 状态
  创建功能 API wrapper
  调用 Android 登录 / Session 对象
  按需读写缓存或 Room
  渲染 Compose UI
```

迁移时要注意：

- Android 项目中很多 UI 状态和业务调用直接写在 Compose 页面里。
- `MainActivity.kt` 非常大，混合了路由、应用壳、登录状态、更新弹窗、首页和我的页面等逻辑。
- Flutter 迁移时应该拆分职责，不要再写一个巨大的 Dart 文件。

## 横向基础模块

### 认证模块

Android 包：

```text
auth/
```

职责：

- CAS 统一登录
- 图形验证码和 MFA
- RSA 密码加密
- 各子系统 Token 提取
- 通过共享 OkHttpClient 和 Cookie 复用 SSO
- 子系统自动重认证

关键文件：

- `XJTULogin.kt`
- `LoginScreen.kt`
- `AttendanceLogin.kt`
- `JwappLogin.kt`
- `YwtbLogin.kt`
- `CampusCardLogin.kt`
- `LibraryLogin.kt`
- `VenueLogin.kt`
- `DzpzLogin.kt`
- `CouponLogin.kt`

Flutter 目标位置：

- `core/session`
- 未来的 `core/auth`
- 未来的 `core/network`

### 工具和存储模块

Android 包：

```text
util/
```

职责：

- 凭据安全存储
- 持久化 CookieJar
- WebVPN URL 转换
- 通用缓存
- Room 数据库创建和迁移
- JSON 辅助方法
- 西交上课时间工具

关键文件：

- `CredentialStore.kt`
- `PersistentCookieJar.kt`
- `WebVpnUtil.kt`
- `DataCache.kt`
- `AppDatabase.kt`
- `XjtuTime.kt`
- `JsonExt.kt`

Flutter 目标位置：

- `core/storage`
- `core/network`
- `core/webvpn`
- `core/time`

## 功能模块

### 课表

Android 包：

```text
schedule/
```

功能：

- 个人课表
- 周视图
- 考试安排
- 教材信息
- 自定义课程
- 节假日过滤
- ICS 导出和分享
- 全校课程搜索

关键文件：

- `ScheduleScreen.kt`
- `ScheduleApi.kt`
- `ScheduleCache.kt`
- `ScheduleExport.kt`
- `CustomCourseEntity.kt`
- `CustomCourseDialog.kt`
- `HolidayApi.kt`
- `SchoolCourseScreen.kt`
- `SchoolCourseApi.kt`

迁移建议：

- 等核心存储和登录稳定后分阶段迁移。
- 先迁移 Dart model 和缓存格式。
- 自定义课程涉及数据库迁移。
- 课表导出涉及平台文件和分享能力。

### 校园卡

Android 包：

```text
card/
```

功能：

- 余额
- 消费流水
- 月度 / 分类 / 餐段统计
- 首页卡片缓存
- 校园卡桌面小组件数据

关键文件：

- `CampusCardScreen.kt`
- `CampusCardApi.kt`
- `auth/CampusCardLogin.kt`
- `widget/CampusCardWidgetProvider.kt`

迁移建议：

- 依赖 CAS / OAuth / JWT。
- 小组件仍需要 Android 原生实现。
- 消费统计逻辑可以先迁移到 Dart 并测试。

### 考勤

Android 包：

```text
attendance/
```

功能：

- 考勤记录
- 学期筛选
- 当前周 / 区间统计
- 状态筛选

关键文件：

- `AttendanceScreen.kt`
- `AttendanceApi.kt`
- `auth/AttendanceLogin.kt`

迁移建议：

- 依赖内网服务和 WebVPN。
- 不建议在 WebVPN 和认证稳定前迁移。

### 空教室

Android 包：

```text
emptyroom/
```

功能：

- 空教室查询
- 校区 / 教学楼 / 节次筛选
- 教室座位数量查询

关键文件：

- `EmptyRoomScreen.kt`
- `EmptyRoomApi.kt`

迁移建议：

- 如果数据源无需复杂登录，这是早期迁移的好候选。

### 通知公告

Android 包：

```text
notification/
```

功能：

- 多来源公告聚合
- 公告列表和详情

关键文件：

- `NotificationScreen.kt`
- `NotificationApi.kt`

迁移建议：

- 如果接口不依赖复杂认证，可作为早期迁移模块。

### 图书馆

Android 包：

```text
library/
```

功能：

- 座位状态
- 预约状态
- 座位推荐
- 座位地图可视化
- 签到 / 取消等操作

关键文件：

- `LibraryScreen.kt`
- `LibraryApi.kt`
- `SeatMapCanvas.kt`
- `SeatMapView.kt`
- `SeatNeighborData.kt`
- `auth/LibraryLogin.kt`

迁移建议：

- 依赖认证和内网 / WebVPN。
- 座位地图可在 API model 稳定后迁移到 Flutter Canvas。

### 场馆预约

Android 包：

```text
venue/
```

功能：

- 场馆列表
- 可预约时段
- 收藏
- 预约
- 滑块验证码

关键文件：

- `VenueScreen.kt`
- `VenueApi.kt`
- `VenueFavorites.kt`
- `SliderCaptcha.kt`
- `auth/VenueLogin.kt`

迁移建议：

- 滑块验证码敏感，必须明确 API 和手势逻辑后再迁移。
- 收藏存储应迁移到 Flutter 存储层。

### 课程回放和下载

Android 包：

```text
classreplay/
```

功能：

- TronClass 课程列表
- 回放活动列表
- 多机位视频播放
- 回放下载队列
- 暂停 / 恢复 / 取消下载
- 下载管理页面

关键文件：

- `ClassScreen.kt`
- `ClassApi.kt`
- `ClassLogin.kt`
- `VideoPlayerScreen.kt`
- `DownloadManager.kt`
- `DownloadManagerScreen.kt`
- `DownloadTaskEntity.kt`

迁移建议：

- 高风险模块，涉及视频、文件系统、后台任务、Room 下载状态。
- 在需求稳定前应先放在平台桥接边界后面。

### LMS 思源学堂

Android 包：

```text
lms/
```

功能：

- 课程
- 作业
- 成绩 / 评论
- 课件和资源
- 直播 / 回放资源链接
- 附件下载

关键文件：

- `LmsScreen.kt`
- `LmsApi.kt`
- `LmsLogin.kt`
- `LmsModels.kt`

迁移建议：

- Model 适合先迁移。
- 下载能力需要平台支持。

### JWAPP 和成绩报表

Android 包：

```text
jwapp/
score/
```

功能：

- 正式成绩
- FineReport / 报表类成绩查询
- GPA 和成绩展示

关键文件：

- `jwapp/JwappScoreScreen.kt`
- `jwapp/JwappApi.kt`
- `jwapp/CjcxApi.kt`
- `score/ScoreReportScreen.kt`
- `score/ScoreReportApi.kt`
- `auth/JwappLogin.kt`

迁移建议：

- 依赖认证和 HTML / 报表解析。
- 先用样例数据迁移解析器，再做 UI。

### 评教

Android 包：

```text
judge/
```

功能：

- 常规评教
- GSTE 研究生评教
- 一键评教流程

关键文件：

- `JudgeScreen.kt`
- `JudgeApi.kt`
- `GsteJudgeScreen.kt`
- `GsteJudgeApi.kt`
- `auth/GsteLogin.kt`

迁移建议：

- 高风险，因为涉及提交写操作。
- 认证、确认 UI、dry-run 防护设计好之前不要实现。

### 电子凭证 / 成绩单

Android 包：

```text
dzpz/
```

功能：

- 成绩单 / 证明申请流程
- 表单联动
- 提交、检查、下载 PDF

关键文件：

- `TranscriptScreen.kt`
- `TranscriptApi.kt`
- `auth/DzpzLogin.kt`

迁移建议：

- 多步骤工作流，先建状态机。
- 下载和导出需要平台文件支持。

### 加餐券

Android 包：

```text
coupon/
```

功能：

- 电子加餐券记录
- 类型筛选
- 状态展示
- 图片加载

关键文件：

- `CouponScreen.kt`
- `CouponApi.kt`
- `CouponModels.kt`
- `auth/CouponLogin.kt`

迁移建议：

- Android 项目已有 parser 测试，可优先迁移到 Dart 测试。

### 教材中心

Android 包：

```text
jiaocai/
```

功能：

- 教材中心搜索
- WebView 在线阅读
- PDF 下载

关键文件：

- `JiaocaiScreen.kt`
- `JiaocaiApi.kt`
- `JiaocaiLogin.kt`

迁移建议：

- WebView Cookie 同步是核心风险。
- 下载能力需要平台支持。

### NeoSchool

Android 包：

```text
neo/
```

功能：

- 课程列表
- 章节
- 资源
- 资源下载链接

关键文件：

- `NeoScreen.kt`
- `NeoApi.kt`
- `NeoModels.kt`
- `NeoSession.kt`

迁移建议：

- 适合先迁移 Model。
- Session 行为和 CAS 类型登录不同，需要单独设计。

### 一网通办和 NSA

Android 包：

```text
ywtb/
nsa/
```

功能：

- 一网通办用户数据
- 昵称 / 个人资料
- NSA OAuth2 学生信息和照片

关键文件：

- `YwtbScreen.kt`
- `YwtbApi.kt`
- `NsaApi.kt`
- `auth/YwtbLogin.kt`

迁移建议：

- 这些数据用于首页和“我的”页面。
- 缓存时要注意敏感数据边界。

### GMIS 研究生系统

Android 包：

```text
gmis/
```

功能：

- 研究生课程
- 研究生成绩

关键文件：

- `GmisScreen.kt`
- `GmisApi.kt`
- `auth/GmisLogin.kt`

迁移建议：

- 依赖 OAuth / Cookie 登录。

### 付款码

Android 包：

```text
pay/
```

功能：

- 付款码展示

关键文件：

- `PaymentCodeScreen.kt`
- `PaymentCodeApi.kt`

迁移建议：

- 属于敏感金融 / 身份类 UI。
- 迁移前要确认 Token 生命周期和截屏 / 隐私要求。

### 应用内浏览器

Android 包：

```text
browser/
```

功能：

- 应用内浏览器
- 从 OkHttp 会话同步 Cookie
- 下载交给系统

关键文件：

- `BrowserScreen.kt`

迁移建议：

- Flutter 中应设计成共享 WebView 服务，不要每个功能各自复制一套。

### 校历

Android 包：

```text
calendar/
```

功能：

- 校历
- 学期
- 日历事件

关键文件：

- `SchoolCalendarScreen.kt`
- `SchoolCalendarApi.kt`

迁移建议：

- 如果接口不依赖复杂认证，适合作为早期迁移模块。

### 设置和通用 UI

Android 包：

```text
ui/
ui/settings/
ui/components/
ui/theme/
```

功能：

- 主题 / 深色模式
- 导航栏样式
- 默认 Tab
- 网络模式
- 更新通道
- 通用 Chip、下拉菜单、顶部栏、状态组件

关键文件：

- `ui/settings/SettingsScreen.kt`
- `ui/components/AppChip.kt`
- `ui/components/AppDropdownMenu.kt`
- `ui/components/AppTopBar.kt`
- `ui/components/StateComponents.kt`
- `ui/theme/Theme.kt`
- `ui/theme/Color.kt`
- `ui/ScheduleComponents.kt`

迁移建议：

- 适合早期做 Flutter 应用壳和设计系统。

### Android 桌面小组件

Android 包：

```text
widget/
```

功能：

- 2x2 课表小组件
- 4x2 课表小组件
- 校园卡小组件

关键文件：

- `ScheduleWidgetProvider.kt`
- `ScheduleWidgetRemoteViewsService.kt`
- `CampusCardWidgetProvider.kt`

迁移建议：

- 保留 Android 原生实现或通过原生桥接重建。
- Flutter 本身不能直接替代 Android RemoteViews 小组件。

## 建议迁移优先级

1. 应用壳、主题、底部导航、设置 UI
2. 静态通用组件、空状态、错误状态、加载状态
3. 校历、空教室、通知公告的 Model
4. 公开 API 客户端和解析器，并配样例测试
5. 课表 Model、缓存、自定义课程存储
6. Auth / Session 基础层
7. WebVPN 和 Cookie 持久化
8. 校园卡、考勤、图书馆、场馆
9. WebView 类功能
10. 下载、视频、小组件、APK 更新 / 安装

## 给其他智能体的 Prompt 模板

可以直接复制：

```text
请先阅读 docs/agent_technical_constraints.zh-CN.md 和 docs/agent_function_architecture.zh-CN.md。
目标 Flutter 项目：D:\learn\code\final\xjtu_toolbox_flutter。
参考 Android 文件：<填写具体文件列表>。
任务：<填写一个小而明确的任务>。
约束：
- 不要修改无关功能。
- 平台相关逻辑放在 lib/src/platform_bridge 后面。
- 新增模型、解析器、状态逻辑时补测试。
- 最后说明改了哪些文件，以及如何验证。
```

