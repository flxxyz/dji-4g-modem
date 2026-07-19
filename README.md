# dji4g

> 大疆一代 4G 图传模块命令行工具箱
>
> 把 DJI 无人机配件变成一个正经的 Linux USB 4G 网卡

## 这是什么

大疆一代 4G 增强图传模块（USB ID `2ca3:4006`，设备名 Baiwang），内置**中兴 V1E / 移远 QDC507** 模组。插上 Linux 后是一个 CDC ECM 以太网设备，能直接上网。

## 安装

```bash
curl -fsSL https://dji-4g-modem.sao.sh | sh
```

安装脚本自动完成：检测发行版 → 装系统依赖 → 检查内核 → 下载 → 验证。

插上模块，一键上线：

```bash
sudo dji4g connect --route
```

## 功能

```bash
# 联网 / 断网（默认开启断线自动重连）
sudo dji4g connect              # 上线，不改变系统默认路由
sudo dji4g connect --route      # 上线 + 设为默认路由
sudo dji4g disconnect           # 下线

# 状态
dji4g status                    # 信号、IP、运营商
dji4g info                      # 模组型号、IMEI
dji4g signal --graph            # 实时信号柱状图
dji4g cell                      # 基站 / 频段 / RSRP / SINR

# 短信
dji4g sms send '+8613800138000' 'Hello!'

# 诊断（6 层，从 USB 到 HTTP）
dji4g debug connectivity        # 15 步端到端连通性测试
dji4g dump                      # 一键输出所有诊断

# 路由
dji4g route add                 # 手动添加默认路由
dji4g route del                 # 移除默认路由
```

## 支持的平台

| 发行版 | x86_64 | arm64 | armhf |
|--------|--------|-------|-------|
| Ubuntu 22.04+ | ✅ | ✅ | — |
| Debian 12+ | ✅ | ✅ | — |
| PVE 7.x/8.x | ✅ | — | — |
| CentOS/RHEL 8+ | ✅ | — | — |
| Raspberry Pi OS | — | ✅ | ✅ |
| OpenWRT 21+ | ✅ | ✅ | — |
| RouterOS 7.x | ✅ | — | — |

## 硬件

- 大疆一代 4G 模块（USB-A 接口）
- ⚠️ USB **数据线**（纯充电线不行）
- 已激活的 Nano SIM 卡

## 项目

| 文件 | 内容 |
|------|------|
| `dji4g` | 主脚本 |
| `install.sh` | 一键安装 |
| `CHANGELOG.md` | 版本变更 |
| `TESTING.md` | 测试用例 |
| `RELEASE.md` | 发版流程 |
| `ROADMAP.md` | 路线图 |

## License

MIT © [flxxyz](https://github.com/flxxyz)
