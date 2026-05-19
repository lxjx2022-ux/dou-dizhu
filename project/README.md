# 斗地主 - 精美本地单机斗地主游戏

一款采用苹果极简设计风格的本地单机斗地主游戏。纯本地运行，无需联网。

## 功能特性

- **纯本地单机** - 无需联网，打开即玩
- **AI 对手** - 三个难度级别（简单/普通/困难），困难 AI 会完整记牌
- **经典玩法** - 抢地主、加倍、超级加倍、春天、反春
- **癞子模式** - 可在设置中自由开关
- **精美动画** - 发牌飞入、出牌轨迹、炸弹震动光晕、春天特效、胜利彩纸
- **完整系统** - 欢乐豆货币、战绩统计、10种成就、本地存档
- **精致 UI** - 深绿色麂皮牌桌、毛玻璃面板、代码绘制拟物扑克牌

## 获取 APK 的三种方式（任选一种）

### 方式一：GitHub Actions 自动编译（最简单，推荐！）

**不需要电脑环境，不需要安装任何软件，只需一个 GitHub 账号。**

步骤：

1. **注册 GitHub 账号**（如果还没有）：https://github.com/signup

2. **创建新仓库**：
   - 打开 https://github.com/new
   - 仓库名称填 `dou-dizhu`
   - 点击 "Create repository"

3. **上传代码**：
   - 在新仓库页面点击 "uploading an existing file"
   - 将本项目所有文件拖拽上传（或点击选择文件）
   - 点击 "Commit changes"

4. **等待自动编译**：
   - 点击仓库顶部的 "Actions" 标签
   - 等待约 5-10 分钟（自动编译中）
   - 完成后点击 "Releases" 标签

5. **下载 APK**：
   - 在 Releases 页面找到最新版本
   - 下载 `app-release.apk`
   - 传到手机安装即可

> 每次你更新代码推送后，GitHub 都会自动重新编译 APK。

---

### 方式二：手机上用 Termux 编译（不需要电脑）

**在安卓手机上直接编译 APK，不需要电脑。**

步骤：

1. **安装 Termux**：
   - 从 F-Droid 下载安装 Termux（不要从 Google Play 安装）
   - F-Droid 地址：https://f-droid.org/packages/com.termux/

2. **逐行执行以下命令**（复制粘贴到 Termux）：

```bash
# 更新软件源
pkg update -y

# 安装必要工具
pkg install -y git curl unzip openjdk-17

# 下载本项目（如果从 GitHub 上传了，用 git clone 你的仓库地址）
# 或者手动将代码传到手机，然后：
cd /sdcard/Download/
# 将项目 zip 解压到此处，然后：
cd dou-dizhu

# 运行编译脚本
bash termux_build.sh
```

3. **等待编译完成**（约 10-20 分钟）

4. **安装 APK**：
```bash
cp build/app/outputs/flutter-apk/app-release.apk /sdcard/Download/斗地主.apk
```
然后在文件管理器中找到 APK 文件，点击安装。

---

### 方式三：电脑环境编译

如果你有电脑且愿意安装 Flutter 环境：

#### 环境要求

| 工具 | 版本 |
|------|------|
| Flutter SDK | 3.16.0+ |
| Dart SDK | 3.0.0+ |
| Android Studio | 2023.1+ |
| JDK | 17 |

#### 编译步骤

```bash
# 1. 安装 Flutter SDK: https://docs.flutter.dev/get-started/install

# 2. 进入项目目录
cd dou-dizhu

# 3. 获取依赖
flutter pub get

# 4. 编译 APK
flutter build apk --release

# 5. APK 位于
# build/app/outputs/flutter-apk/app-release.apk
```

---

## 安装 APK 到手机

1. 将 `app-release.apk` 传输到手机
2. 在手机设置中开启"允许安装未知来源应用"
3. 点击 APK 文件安装
4. 安装完成后桌面会出现"斗地主"图标

---

## 技术架构

```
lib/
├── main.dart              # 入口（横屏 + 沉浸模式）
├── app.dart               # 主题配置
├── models/                # 7 个数据模型文件
│   ├── card.dart          # 扑克牌（54张）
│   ├── hand_type.dart     # 15种牌型枚举
│   ├── player.dart        # 玩家（人类/AI）
│   ├── game_state.dart    # 完整游戏状态
│   ├── achievement.dart   # 10种成就
│   ├── statistics.dart    # 统计数据
│   └── difficulty.dart    # 三难度枚举
├── engine/                # 游戏引擎
│   ├── poker_engine.dart  # 洗牌/发牌/流程控制
│   ├── hand_evaluator.dart# 牌型判断（支持癞子变牌）
│   ├── ai_player.dart     # 三难度AI策略
│   └── scoring_engine.dart# 计分引擎
├── services/              # 服务层
│   ├── storage_service.dart     # 本地存储
│   ├── audio_service.dart       # 音效管理
│   ├── haptic_service.dart      # 震动反馈
│   └── achievement_service.dart # 成就系统
├── screens/               # 8 个界面
│   ├── splash_screen.dart       # 启动页
│   ├── home_screen.dart         # 主菜单
│   ├── game_screen.dart         # 游戏主界面（横屏）
│   ├── pause_screen.dart        # 暂停菜单
│   ├── settings_screen.dart     # 设置
│   ├── statistics_screen.dart   # 战绩统计
│   ├── achievements_screen.dart # 成就列表
│   └── help_screen.dart         # 玩法说明
├── widgets/               # 12 个可复用组件
│   ├── poker_table.dart         # 牌桌背景
│   ├── card_painter.dart        # 扑克牌绘制器（CustomPaint）
│   ├── playing_card_widget.dart # 扑克牌组件
│   ├── card_animation.dart      # 发牌/出牌动画
│   ├── bomb_effect.dart         # 炸弹特效
│   ├── confetti_effect.dart     # 胜利彩纸
│   ├── glassmorphic_panel.dart  # 毛玻璃面板
│   ├── game_button.dart         # 游戏按钮
│   ├── chip_display.dart        # 欢乐豆显示
│   ├── timer_bar.dart           # 倒计时条
│   └── app_icon_generator.dart  # 应用图标
└── utils/                 # 工具类
    ├── constants.dart     # 颜色/尺寸/动画常量
    ├── extensions.dart    # Dart 扩展方法
    └── card_images.dart   # 牌面路径映射
```

## 游戏操作

1. 启动游戏进入主菜单
2. 点击"开始游戏"进入牌桌
3. 叫地主阶段选择"叫地主"或"不叫"
4. 选择手牌（点击选中，再点击取消），点击"出牌"
5. 使用"提示"获取出牌建议，"不要"跳过回合
6. 游戏结束后查看结算和成就

## 成就列表

| 成就 | 条件 |
|------|------|
| 初出茅庐 | 获得第一场胜利 |
| 小有所成 | 累计获胜10局 |
| 斗地主高手 | 累计获胜100局 |
| 炸弹大师 | 累计打出10个炸弹 |
| 春天制造者 | 累计打出5次春天 |
| 逆袭者 | 累计打出3次反春 |
| 家财万贯 | 欢乐豆达到10万 |
| 连胜将军 | 连胜5局 |
| 地主之王 | 当地主获胜20次 |
| 农民起义军 | 当农民获胜50次 |

## 技术栈

- **Flutter 3.x** + **Dart 3.x**
- SharedPreferences（本地数据存储）
- audioplayers（音效）
- vibration（触感反馈）
- confetti（胜利彩纸特效）
- CustomPainter（扑克牌、图标绘制）

## 注意事项

- 首次启动赠送 5000 欢乐豆
- 所有数据保存在本地，卸载会丢失
- 音效文件为可选，缺失时自动静默处理不影响游戏
- 图标为代码绘制，不需要外部图片资源
- 字体使用系统默认无衬线字体（Android: Roboto）

## 文件说明

| 文件 | 说明 |
|------|------|
| `README.md` | 本文件 |
| `pubspec.yaml` | 项目配置和依赖 |
| `termux_build.sh` | Termux 手机编译脚本 |
| `.github/workflows/build_apk.yml` | GitHub 自动编译配置 |
| `assets/audio/README.md` | 音效文件说明（可选） |

## 许可证

仅供个人学习和娱乐使用。
