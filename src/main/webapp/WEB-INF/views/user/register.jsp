<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
    <title>校园头条 - 注册</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/style.css?v=28">
</head>
<body class="login-body">
    <a href="${pageContext.request.contextPath}/news/home" class="back-home-fixed">‹ 返回首页</a>
    <div class="login-container">
        <div class="login-card">
            <h1 class="login-title">
                <img src="${pageContext.request.contextPath}/static/img/logo.svg?v=5" alt="校园头条" class="login-logo-img">
                <span>校园头条</span>
            </h1>
            <p class="login-subtitle">新用户注册</p>

            <form id="registerForm" class="login-form">
                <div class="form-group">
                    <label>通过学号或者手机号注册 *</label>
                    <input type="text" name="username" required placeholder="请输入学号或手机号">
                </div>
                <div class="form-group">
                    <label>密码 *</label>
                    <input type="password" name="password" required placeholder="至少6位">
                </div>
                <div class="form-group">
                    <label>头像</label>
                    <div class="avatar-upload">
                        <img id="avatarPreview" class="avatar-preview"
                             src="${pageContext.request.contextPath}/static/img/avatars/a1.svg" alt="头像预览">
                        <div class="avatar-upload-side">
                            <button type="button" class="btn-outline" id="pickAvatarBtn">上传本地图片</button>
                            <span class="avatar-hint">不设置则使用默认绿色笑脸头像</span>
                        </div>
                    </div>
                    <input type="file" id="avatarFile" accept="image/*" style="display:none">
                    <input type="hidden" name="avatar" id="avatarInput" value="/static/img/avatars/a1.svg">
                </div>
                <div class="form-group">
                    <label>昵称</label>
                    <input type="text" name="nickname" placeholder="选填">
                </div>
                <div class="form-group">
                    <label>院系</label>
                    <input type="text" name="college" placeholder="选填">
                </div>
                <button type="submit" class="btn btn-primary btn-block">注 册</button>
                <div class="form-actions">
                    <a href="${pageContext.request.contextPath}/user/login" class="link">已有账号？去登录</a>
                </div>
            </form>
        </div>
    </div>

    <script src="${pageContext.request.contextPath}/static/js/jquery.min.js"></script>
    <script>
        var ctx = "${pageContext.request.contextPath}";

        // 点击按钮打开本地文件选择
        $("#pickAvatarBtn").click(function() { $("#avatarFile").click(); });

        // 选择本地图片后立即上传，并回填头像路径
        $("#avatarFile").change(function() {
            var file = this.files[0];
            if (!file) return;
            if (file.size > 5 * 1024 * 1024) { alert("头像图片不能超过 5MB"); return; }
            var fd = new FormData();
            fd.append("file", file);
            $.ajax({
                url: ctx + "/user/uploadAvatar",
                type: "POST",
                data: fd,
                processData: false,
                contentType: false,
                success: function(res) {
                    if (res.code === 200) {
                        $("#avatarInput").val(res.data);
                        $("#avatarPreview").attr("src", ctx + res.data);
                    } else {
                        alert(res.msg);
                    }
                },
                error: function() { alert("头像上传失败，请重试"); }
            });
        });

        $("#registerForm").submit(function(e) {
            e.preventDefault();
            var account = $(this).find("[name=username]").val().trim();
            if (!account) { alert("请输入学号或手机号"); return; }
            var data = $(this).serialize();
            // 输入的是手机号时同步提交 phone 字段
            if (/^1\d{10}$/.test(account)) {
                data += "&phone=" + encodeURIComponent(account);
            }
            $.ajax({
                url: "${pageContext.request.contextPath}/user/doRegister",
                type: "POST",
                data: data,
                success: function(res) {
                    if (res.code === 200) {
                        alert("注册成功！请登录");
                        location.href = "${pageContext.request.contextPath}/user/login";
                    } else {
                        alert(res.msg);
                    }
                }
            });
        });
    </script>
</body>
</html>
