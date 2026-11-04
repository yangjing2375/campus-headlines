<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
    <title>个人中心 - 校园头条</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/style.css?v=28">
</head>
<body>
    <%@ include file="/WEB-INF/views/common/header.jsp" %>

    <c:choose>
        <c:when test="${empty sessionScope.loginUser.avatar}">
            <c:set var="avatarSrc" value="${pageContext.request.contextPath}/static/img/avatars/a1.svg"/>
        </c:when>
        <c:otherwise>
            <c:set var="avatarSrc" value="${pageContext.request.contextPath}${sessionScope.loginUser.avatar}"/>
        </c:otherwise>
    </c:choose>

    <div class="profile-wrap">

        <!-- 顶部个人信息 -->
        <div class="profile-hero">
            <div class="profile-avatar-box" id="pickAvatarBtn" title="点击更换头像">
                <img id="avatarPreview" class="profile-avatar" src="${avatarSrc}" alt="我的头像">
                <div class="avatar-mask">更换</div>
            </div>
            <h2 class="profile-name">
                <c:choose>
                    <c:when test="${not empty sessionScope.loginUser.nickname}">${sessionScope.loginUser.nickname}</c:when>
                    <c:otherwise>${sessionScope.loginUser.username}</c:otherwise>
                </c:choose>
            </h2>
            <span class="profile-role">
                <c:choose>
                    <c:when test='${sessionScope.loginUser.role == "ADMIN"}'>系统管理员</c:when>
                    <c:when test='${sessionScope.loginUser.role == "MEDIA"}'>自媒体人</c:when>
                    <c:otherwise>普通用户</c:otherwise>
                </c:choose>
            </span>
            <p class="profile-sub">${sessionScope.loginUser.college}</p>
            <input type="file" id="avatarFile" accept="image/*" style="display:none">
        </div>

        <!-- 自媒体创作 -->
        <div class="profile-card">
            <h3 class="profile-card-title">自媒体创作</h3>
            <c:choose>
                <c:when test="${sessionScope.loginUser.role == 'MEDIA'}">
                    <p class="apply-desc">你已认证为自媒体人，可以发布资讯与话题。</p>
                    <a class="btn btn-primary profile-save" href="${pageContext.request.contextPath}/editor/index">进入自媒体工作台</a>
                </c:when>
                <c:when test="${sessionScope.loginUser.role == 'ADMIN'}">
                    <p class="apply-desc">管理员账号已拥有内容管理权限，无需申请自媒体人。</p>
                </c:when>
                <c:otherwise>
                    <p class="apply-desc">想发布校园资讯和话题？申请成为自媒体人，经管理员审核通过后即可开通创作权限。</p>
                    <a class="btn btn-primary profile-save" href="${pageContext.request.contextPath}/user/media-apply">申请成为自媒体人</a>
                </c:otherwise>
            </c:choose>
        </div>

        <!-- 个人资料 -->
        <div class="profile-card">
            <h3 class="profile-card-title">个人资料</h3>

            <div class="profile-row">
                <label>学号 / 手机号</label>
                <input type="text" value="${sessionScope.loginUser.username}" disabled>
            </div>
            <div class="profile-row">
                <label>昵称</label>
                <input type="text" id="nickname" value="${sessionScope.loginUser.nickname}" placeholder="请输入昵称">
            </div>
            <div class="profile-row">
                <label>院系</label>
                <input type="text" id="college" value="${sessionScope.loginUser.college}" placeholder="请输入院系">
            </div>

            <button class="btn btn-primary profile-save" onclick="saveProfile()">保存修改</button>
        </div>

        <!-- 修改密码 -->
        <div class="profile-card">
            <h3 class="profile-card-title">修改密码</h3>

            <div class="profile-row">
                <label>原密码</label>
                <input type="password" id="oldPassword" placeholder="请输入原密码">
            </div>
            <div class="profile-row">
                <label>新密码</label>
                <input type="password" id="newPassword" placeholder="请输入新密码">
            </div>

            <button class="btn btn-primary profile-save" onclick="changePwd()">修改密码</button>
        </div>
    </div>

    <script src="${pageContext.request.contextPath}/static/js/jquery.min.js"></script>
    <script>
        var ctx = "${pageContext.request.contextPath}";

        // 点击头像更换
        $("#pickAvatarBtn").click(function() { $("#avatarFile").click(); });

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
                    if (res.code !== 200) { alert(res.msg); return; }
                    $.post(ctx + "/user/updateAvatar", { avatar: res.data }, function(r2) {
                        alert(r2.msg);
                        if (r2.code === 200) location.reload();
                    });
                },
                error: function() { alert("头像上传失败，请重试"); }
            });
        });

        function saveProfile() {
            $.ajax({
                url: ctx + "/user/updateProfile",
                type: "POST",
                contentType: "application/json",
                data: JSON.stringify({
                    nickname: $("#nickname").val(),
                    college:  $("#college").val()
                }),
                success: function(res) {
                    alert(res.msg);
                    if (res.code === 200) location.reload();
                }
            });
        }

        function changePwd() {
            var oldP = $("#oldPassword").val(), newP = $("#newPassword").val();
            if (!oldP || !newP) { alert("请填写完整"); return; }
            $.post(ctx + "/user/changePassword", { oldPassword: oldP, newPassword: newP }, function(res) {
                alert(res.msg);
                if (res.code === 200) { $("#oldPassword").val(""); $("#newPassword").val(""); }
            });
        }
    </script>
</body>
</html>
