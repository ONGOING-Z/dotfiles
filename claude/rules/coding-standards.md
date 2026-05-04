# 全局编码规范

---

## Shell / Bash

### 模板

```bash
#!/usr/bin/env bash
set -euo pipefail

# 函数命名：小写下划线
my_function() {
    local var="${1:-default}"
    echo "${var}"
}

my_function "$@"
```

### 示例

```bash
#!/usr/bin/env bash
set -euo pipefail

check_dependency() {
    local cmd="$1"
    if ! command -v "${cmd}" >/dev/null 2>&1; then
        echo "[错误] 缺少依赖: ${cmd}" >&2
        return 1
    fi
}

# 变量引用加双引号
for dep in git zsh fzf; do
    check_dependency "${dep}"
done
```

---

## Python

### 模板

```python
#!/usr/bin/env python3
"""模块说明"""

def main(argv: list[str] | None = None) -> int:
    """主函数"""
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
```

### 示例

```python
def load_config(path: Path) -> dict:
    """从 JSON 文件加载配置"""
    if not path.exists():
        return {}
    with open(path, encoding="utf-8") as f:
        return json.load(f)

class ConfigManager:
    def __init__(self, root: Path) -> None:
        self._root = root
        self._cache: dict[str, Any] = {}

    def get(self, key: str) -> Any:
        if key not in self._cache:
            self._cache[key] = self._load(key)
        return self._cache[key]
```

---

## Java

### 模板

```java
public class Main {
    public static void main(String[] args) {
    }
}
```

### 示例

```java
public class ConfigLoader {
    private final Path root;

    public ConfigLoader(Path root) {
        this.root = root;
    }

    public Map<String, String> load() throws IOException {
        // ...
        return result;
    }
}
```

---

## Go

### 模板

```go
package main

import "fmt"

func main() {
    fmt.Println("hello")
}
```

### 示例

```go
type Config struct {
    Path string
    Mode int
}

func LoadConfig(p string) (*Config, error) {
    if p == "" {
        return nil, fmt.Errorf("path required")
    }
    return &Config{Path: p, Mode: 0644}, nil
}
```

---

## Git Commit

### 模板

```
<type>(<scope>): <subject>
```

### 示例

```
feat(cli): add verbose output flag
fix(parser): handle empty input gracefully
chore(deps): bump requests to 2.31.0
```

类型: feat / fix / chore / docs / refactor / test / ci

---

## 通用规则

### 模板

```
- 规则描述
```

### 示例

- 优先编辑现有文件，避免新建
- 不写解释"做了什么"的注释，只写"为什么这样做"
- 不主动添加未发生的错误场景
- 不在 main/master 上 force push
