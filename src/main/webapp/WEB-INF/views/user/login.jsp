<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
    <title>校园头条 - 登录</title>
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
            <p class="login-subtitle">校园资讯 · 校园声音</p>

            <form id="loginForm" class="login-form">
                <div class="form-group">
                    <label>学号 / 手机号</label>
                    <input type="text" id="username" name="username" required placeholder="请输入学号或手机号">
                </div>
                <div class="form-group">
                    <label>密码</label>
                    <input type="password" id="password" name="password" required placeholder="请输入密码">
                </div>
                <div class="form-group">
                    <label>验证码</label>
                    <div class="captcha-row">
                        <input type="text" id="captcha" name="captcha" maxlength="4" autocomplete="off" placeholder="请输入右侧 4 位数字">
                        <img id="captchaImg" class="captcha-img" alt="验证码" title="看不清？点击换一张">
                    </div>
                </div>
                <button type="submit" class="btn btn-primary btn-block">登 录</button>
                <div class="form-actions">
                    <a href="${pageContext.request.contextPath}/user/register" class="link">没有账号？立即注册</a>
                </div>
            </form>
        </div>
    </div>

    <script src="${pageContext.request.contextPath}/static/js/jquery.min.js"></script>
    <script>
        var ctx = "${pageContext.request.contextPath}";

        // 加载 / 刷新验证码（加时间戳避免浏览器缓存）
        function refreshCaptcha() {
            $("#captchaImg").attr("src", ctx + "/user/captcha?t=" + new Date().getTime());
            $("#captcha").val("");
        }
        $("#captchaImg").click(refreshCaptcha);
        refreshCaptcha();

        $("#loginForm").submit(function(e) {
            e.preventDefault();
            var username = $("#username").val().trim();
            var password = $("#password").val().trim();
            var captcha = $("#captcha").val().trim();
            if (!username || !password) { alert("请填写完整信息"); return; }
            if (!/^\d{4}$/.test(captcha)) { alert("请输入 4 位数字验证码"); return; }
            $.ajax({
                url: ctx + "/user/doLogin?captcha=" + encodeURIComponent(captcha),
                type: "POST",
                contentType: "application/json",
                data: JSON.stringify({ username: username, password: password }),
                success: function(res) {
                    if (res.code === 200) {
                        // 根据角色跳转不同首页
                        var role = res.data.role;
                        if (role === 'ADMIN') {
                            location.href = ctx + "/admin/dashboard";
                        } else if (role === 'MEDIA') {
                            location.href = ctx + "/editor/index";
                        } else {
                            location.href = ctx + "/news/home";
                        }
                    } else {
                        alert(res.msg);
                        refreshCaptcha();
                    }
                },
                error: function() {
                    alert("登录失败，请稍后重试");
                    refreshCaptcha();
                }
            });
        });
    </script>
</body>
</html>
