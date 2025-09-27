; =================================================================================
; QuickPath Opener v3 - AutoHotkey (v3) 脚本
;
; [v3 更新日志]
;   - 修复: 当 file:/// 路径被双引号包裹时无法正确识别的 Bug。
;   - 优化: 调整了路径清理步骤的顺序，将“去除引号”操作提前，以确保后续处理的正确性。
;
; [核心功能]
;   - 拦截 Win+E 快捷键。
;   - 检查剪贴板内容是否为一个有效的、已存在的文件夹或文件路径。
;   - 如果是文件夹 -> 直接打开。
;   - 如果是文件 -> 打开其父文件夹。
;   - 如果不是有效路径 -> 执行默认的 Win+E 功能。
; =================================================================================

#NoEnv
SendMode Input

$#e::
{
    ; 1. 从剪贴板获取纯文本内容
    path := Clipboard

    ; 如果剪贴板为空，直接执行默认功能
    if (path = "")
    {
        Send, #e
        return
    }

    ; -----------------------------------------------------------------------------
    ; 2. 路径智能修正与清理
    ; -----------------------------------------------------------------------------

    ; a) 移除路径前后的所有空格和制表符
    path := Trim(path)

    ; b) 如果路径被英文双引号包裹，则【优先】移除双引号
    if (SubStr(path, 1, 1) = """" and SubStr(path, 0) = """")
    {
        StringTrimLeft, path, path, 1
        StringTrimRight, path, path, 1
        ; 再次 Trim，可以处理引号内部可能存在的空格，例如 " D:\folder "
        path := Trim(path)
    }
    
    ; c) 现在，在没有引号干扰的情况下，处理 "file:///" URI 格式
    if (SubStr(path, 1, 8) = "file:///")
    {
        StringTrimLeft, path, path, 8
    }

    ; d) 将所有正斜杠 '/' 替换为反斜杠 '\'
    StringReplace, path, path, /, \, All

    ; e) 移除末尾的斜杠，除非路径本身就是一个根目录 (例如 "C:\")
    if (SubStr(path, 0) = "\" and StrLen(path) > 3)
    {
        StringTrimRight, path, path, 1
    }

    ; -----------------------------------------------------------------------------
    ; 3. 验证路径并执行相应操作
    ; -----------------------------------------------------------------------------

    file_attributes := FileExist(path)

    ; a) 检查路径是否指向一个存在的文件夹 (Directory)
    if InStr(file_attributes, "D")
    {
        ; 是文件夹，直接用资源管理器打开
        Run, explorer.exe "%path%"
    }
    ; b) 如果不是文件夹，检查它是否指向一个存在的文件
    else if (file_attributes != "")
    {
        ; 是文件，获取其父目录并打开
        SplitPath, path, , parentDir
        Run, explorer.exe "%parentDir%"
    }
    else
    {
        ; c) 如果路径不存在，则执行原始的 Win+E 功能
        Send, #e
    }
    return
}