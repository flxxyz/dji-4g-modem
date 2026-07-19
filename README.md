# dji4g

> 大疆一代 4G 图传模块命令行工具箱
>
> 把 DJI 无人机配件变成一个正经的 Linux USB 4G 网卡

## 这是什么

大疆一代 4G 增强图传模块（USB ID `2ca3:4006`，设备名"Baiwang"），内置**中兴 V1E / 移远 QDC507** 模组。插上 Linux 后是一个 CDC ECM 以太网设备，能直接上网。

这个脚本帮你：
- **一键联网** — 驱动加载、APN 配置、DHCP 全自动
- **发短信** — 支持 AT 文本模式
- **看基站** — 频段/信号/PCI 一目了然
- **6 层诊断** — 从 USB 物理层到 HTTP 应用层

## 快速开始

```bash
# 下载
git clone https://github.com/flxxyz/dji-4g-modem.git
cd dji-4g-modem

# 安装
sudo cp dji4g /usr/local/bin/
sudo chmod +x /usr/local/bin/dji4g

# 插上 4G 模块，一键上线
sudo dji4g connect --route
```

搞定。现在你能用 4G 上网了。

## 常用命令

```bash
# 联网 / 断网
sudo dji4g connect              # 上线（不改变系统默认路由）
sudo dji4g connect --route      # 上线 + 设为默认路由
sudo dji4g disconnect           # 下线

# 状态查看
dji4g status                    # 信号、IP、运营商
dji4g info                      # 模组型号、IMEI、注册状态
dji4g signal                    # RSSI 信号强度
dji4g signal --graph            # 实时信号柱状图
dji4g cell                      # 基站频段、信号指标

# 短信
dji4g sms send '+8613800138000' 'Hello!'

# 诊断
dji4g debug usb                 # USB 描述符、接口映射
dji4g debug modem               # 20 条 AT 命令全量采集
dji4g debug connectivity        # 15 步端到端连通性测试
dji4g dump                      # 一键输出所有诊断

# 环境
dji4g env                       # 发行版、内核、工具链
dji4g preflight                 # 依赖检查（缺什么自动装）
```

## 支持的 Linux 发行版

| 发行版 | 状态 | 备注 |
|--------|------|------|
| Ubuntu 22.04+ | ✅ 已验证 | cloud image 需 `linux-modules-extra`，preflight 自动处理 |
| Debian 12+ | ✅ 已验证 | cdc_ether 自动绑定 |
| PVE 7.x/8.x | ✅ 已验证 | 需手动 `new_id` 注册 option 驱动 |
| CentOS/RHEL 8+ | 待测 | |
| OpenWRT 21+ | 待测 | 使用 `udhcpc`、`opkg` |
| Raspberry Pi OS | 待测 | |
| macOS | ❌ | Apple Silicon 无 CDC ECM 驱动 |
| RouterOS | ❌ | 需单独实现 |

## 硬件需求

- 大疆一代 4G 模块（USB-A 接口）
- USB 数据线（⚠️ 必须能传数据，纯充电线不行）
- 已激活的 Nano SIM 卡

## 前置条件

脚本需要 root 权限（加载内核模块、配置网络）。首次运行 `sudo dji4g connect` 会自动检查并安装缺失依赖：

```bash
sudo dji4g preflight     # 检查依赖
sudo dji4g preflight --fix  # 自动安装
```

## 工作原理

```
USB 插入 → option 驱动 (串口/AT) + cdc_ether 驱动 (以太网)
                ↓
          AT 命令激活 PDP → 获取移动 IP
                ↓
          DHCP 获取 192.168.225.x → 模块 NAT 转发
```

## 项目结构

```
dji-4g-modem/
├── dji4g          # 单文件 Bash 脚本
├── CHANGELOG.md   # 版本变更
├── TESTING.md     # 测试用例
├── RELEASE.md     # 发版清单
├── ROADMAP.md     # 路线图
└── README.md      # 你正在读的文件
```

## License

MIT
