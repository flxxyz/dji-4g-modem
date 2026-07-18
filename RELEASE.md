# Release Checklist

## Before Tagging

```bash
# 1. Compare with previous tag
git diff $(git describe --tags --abbrev=0)..HEAD --stat
git log $(git describe --tags --abbrev=0)..HEAD --oneline

# 2. Update CHANGELOG.md with all changes since last tag
#    - Added / Fixed / Changed / Verified sections

# 3. Run syntax check
bash -n dji4g && echo PASS

# 4. Test on Tier 1 (PVE) if available
scp dji4g pve:/usr/local/bin/ && ssh pve "dji4g env && sudo dji4g connect --route && dji4g status && sudo dji4g disconnect"

# 5. Bump version in dji4g script
#    SCRIPT_VERSION="X.Y.Z"

# 6. Commit & Tag
git add -A
git commit -m "Release vX.Y.Z

$(sed -n '/## \[X.Y.Z\]/,/## \[/p' CHANGELOG.md | tail -n +2 | head -n -1)"
git tag -a vX.Y.Z -m "vX.Y.Z"
```

## Version Bump Rules

| Change | Bump |
|--------|------|
| New command or debug group | MINOR |
| Bug fix, output format change | PATCH |
| Platform support added/removed | MINOR |
| API/behavior change | MAJOR |

## Test Matrix (see TESTING.md)

| Tier | Environment | Required | 
|------|-------------|----------|
| 1 | PVE 7.x/8.x | Every release |
| 2 | Ubuntu 22.04+, Debian 12+ | Every release |
| 3 | CentOS/RHEL, OpenWRT, Raspberry Pi OS | When available |
