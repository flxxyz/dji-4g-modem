# dji4g 版本发布测试矩阵

每次版本发布前，必须在以下环境中通过全部测试。

## 测试环境分级

| 顺序 | 环境 | 要求 | 备注 |
|------|------|------|------|
| 1 | Ubuntu 22.04+ | 必须 | `apt`, `dhclient`, cloud image 需 `linux-modules-extra` |
| 2 | Debian 12+ | 必须 | `apt`, `dhclient`, cdc_ether 自动绑定 |
| 3 | CentOS/RHEL 8+ | 有环境时 | `yum`/`dnf`, `dhclient`, SELinux |
| 4 | OpenWRT 21+ | 有环境时 | `opkg`, `udhcpc`, busybox |
| 5 | Raspberry Pi OS | 有设备时 | `apt`, `dhclient`, 物理设备 |
| * | PVE 7.x/8.x | 可选 | 宿主机，每轮测试的底座 |

## 测试用例

### TC-01: 基础语法

```bash
bash -n dji4g && echo PASS
```

### TC-02: 平台识别

```bash
dji4g env
```

验证：Distro 正确识别，核心工具标记为 available，设备状态正确。

### TC-03: 帮助系统

```bash
dji4g --help
dji4g connect --help
dji4g debug --help
```

验证：每个子命令都有帮助输出。

### TC-04: AT 命令 (无 root)

```bash
dji4g at ATI
dji4g at AT+CSQ
dji4g at AT+CGSN
```

验证：返回有效响应，无权限错误。

### TC-05: 状态查询 (无 root)

```bash
dji4g status
dji4g status --json
dji4g info
dji4g signal
dji4g signal --graph
```

验证：设备信息、信号强度正确显示，JSON 输出合法。

### TC-06: 一键连接 (需要 root)

```bash
sudo dji4g connect
```

验证：
- 6 个步骤全部 OK
- 获取到 192.168.225.x IP
- 公网 IP 非空
- 信号栏显示有效值

### TC-07: 强制复位连接 (需要 root)

```bash
sudo dji4g disconnect
sudo dji4g connect --force
```

验证：CFUN reset 执行，设备重新枚举后正常连接。

### TC-08: 联网验证 (需要 root)

```bash
# 连接后测试
ping -c 3 -I <ECM_INTERFACE> 8.8.8.8
curl --interface <ECM_INTERFACE> http://baidu.com
```

验证：ping 通，HTTP 返回非 000。

### TC-09: 断连清理 (需要 root)

```bash
sudo dji4g disconnect
```

验证：
- 路由移除
- 接口关闭
- 驱动解绑
- ls /dev/ttyUSB* 返回空或接口不可用

### TC-10: Debug - USB

```bash
dji4g debug usb
```

验证：显示 USB 设备树、接口映射表（含 ECM 接口）、端点信息。

### TC-11: Debug - Driver

```bash
dji4g debug driver
```

验证：显示 option/cdc_ether 等模块状态，驱动绑定信息，dmesg 日志。

### TC-12: Debug - Modem

```bash
sudo dji4g debug modem
```

验证：~20 条 AT 命令逐一执行，显示 OK/ERROR 统计。

### TC-13: Debug - Network

```bash
sudo dji4g debug network
```

验证：显示注册状态、信号图表、PDP 上下文、APN、IP。

### TC-14: Debug - Connectivity

```bash
sudo dji4g debug connectivity
```

验证：15 步测试从 USB 检测到 HTTP 全量通过，结果 "fully operational"。

### TC-15: Debug - System

```bash
dji4g debug system
```

验证：显示发行版、内核、USB 控制器、已知配置对照表。

### TC-16: 全量 Dump

```bash
dji4g dump
dji4g dump --json
```

验证：所有 debug 组依次输出，JSON 格式合法。

### TC-17: 监控模式

```bash
# 后台运行，然后插拔设备
dji4g monitor &
# ... 插拔设备 ...
kill %1
```

验证：设备插拔时输出 ATTACHED/NOT FOUND。

### TC-18: 故障恢复

```bash
# 模拟异常：设备已在连接状态，再执行 connect
sudo dji4g connect
# 验证：不报严重错误，使用已有连接
sudo dji4g disconnect
# 验证：正常清理
```

### TC-19: SMS 发送 (需要 root)

```bash
sudo dji4g connect --route
dji4g sms send '+8617671773306' 'Test SMS from dji4g'
```

验证：返回 `+CMGS: <mr>` 和 `OK`。

### TC-20: 基站信息查询

```bash
dji4g cell
dji4g cell --json
```

验证：显示技术/运营商/频段/带宽/PCI/CellID 及信号指标，JSON 格式正确。

## 发布检查清单

| # | 检查项 | |
|---|--------|---|
| 1 | `bash -n` 语法检查通过 | ☐ |
| 2 | Ubuntu 22.04 (120) 全量 TC01-TC20 | ☐ |
| 3 | Debian 12 (121) 全量 TC01-TC20 | ☐ |
| 4 | CentOS/RHEL 如有环境 TC01-TC05,TC19-20 | ☐ |
| 5 | OpenWRT 如有环境 TC01-TC05 | ☐ |
| 6 | Raspberry Pi OS 如有设备 TC01-TC20 | ☐ |
| 7 | `dji4g dump` 所有 debug 组无报错 | ☐ |
| 8 | 已知问题已记录到 RELEASE_NOTES.md | ☐ |

## 当前版本状态

**v2.0.0** (2026-07-18) — 当前版本
- [x] Ubuntu 22.04 (VM 120, kernel 5.15.0-186-generic) — TC01-TC20
- [x] Debian 12 (VM 121, kernel 6.1.0-50) — TC01-TC15
- [x] PVE 7.0 (宿主机, kernel 7.0.2) — 可选
- [ ] CentOS 8+ (VM 122)
- [ ] OpenWRT 21+ (VM 119)
- [ ] Raspberry Pi OS
- [ ] OpenWRT 21+

## RouterOS 说明

MikroTik RouterOS 使用专有用户态（非标准 Linux shell），本脚本无法直接运行。
如需在 RouterOS 上使用 DJI 4G 模块，需要单独编写 RouterOS 脚本（使用 `/interface lte` 等 RouterOS 命令）。

## 已知限制

1. **AT 端口探测**：首次探测会遍历所有 /dev/ttyUSB* 端口（约 4-8 秒），后续使用缓存的端口
2. **OpenWRT**：如缺少 `timeout` 命令使用 BusyBox 回退方案；DHCP 需要 `udhcpc`
3. **CentOS/RHEL**：可能需要先 `modprobe option` 并手动注册 `new_id`；SELinux 可能需要配置
4. **无 Root 时**：connect/disconnect 不可用，但 status/info/signal/at/debug 均可正常使用
