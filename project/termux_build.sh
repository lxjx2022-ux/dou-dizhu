#!/data/data/com.termux/files/usr/bin/bash
# ============================================================
# 斗地主 APK 编译脚本 - Termux 版本
# 
# 使用方法（在 Termux 中逐行执行）：
#   1. 安装 Termux 应用（F-Droid 下载）
#   2. 打开 Termux，复制粘贴以下命令：
#
#      pkg update -y
#      pkg install -y git curl unzip openjdk-17
#      git clone https://github.com/<你的用户名>/dou-dizhu.git
#      cd dou-dizhu
#      bash termux_build.sh
#
#   3. 等待编译完成，APK 在 build/app/outputs/flutter-apk/
# ============================================================

set -e

echo "========================================"
echo "  斗地主 APK 编译脚本"
echo "========================================"

# 1. 安装必要工具
echo "[1/6] 安装依赖..."
pkg install -y git curl unzip clang cmake ninja pkg-config

# 2. 安装 Flutter
echo "[2/6] 安装 Flutter SDK..."
if [ ! -d "$HOME/flutter" ]; then
    git clone --depth 1 https://github.com/flutter/flutter.git -b stable "$HOME/flutter"
fi
export PATH="$HOME/flutter/bin:$PATH"

# 3. 同意 Android 许可
echo "[3/6] 配置 Android SDK..."
flutter doctor --android-licenses <<< $(echo -e "y\ny\ny\ny\ny\ny\ny\ny\ny\ny\ny\ny\ny") 2>/dev/null || true

# 4. 获取依赖
echo "[4/6] 获取项目依赖..."
flutter pub get

# 5. 编译 APK
echo "[5/6] 编译 APK（可能需要 5-10 分钟）..."
flutter build apk --release

# 6. 完成
echo ""
echo "========================================"
echo "  编译完成！"
echo "========================================"
echo ""
echo "APK 文件位置:"
echo "  build/app/outputs/flutter-apk/app-release.apk"
echo ""
echo "安装到手机:"
echo "  cp build/app/outputs/flutter-apk/app-release.apk /sdcard/Download/斗地主.apk"
echo ""
echo "然后在文件管理器中点击安装"
echo "========================================"
