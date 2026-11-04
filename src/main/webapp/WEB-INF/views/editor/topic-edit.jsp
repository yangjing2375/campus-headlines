<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
    <title>${empty topic.id ? '新建话题' : '编辑话题'} - 校园头条自媒体</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/style.css?v=28">
</head>
<body>
    <%@ include file="/WEB-INF/views/common/header.jsp" %>

    <div class="container">
        <div class="admin-layout">
            <aside class="admin-sidebar">
                <h3>自媒体工作台</h3>
                <ul>
                    <li><a href="${pageContext.request.contextPath}/editor/index">📊 概览</a></li>
                    <li><a href="${pageContext.request.contextPath}/editor/draft/new">✍️ 写文章</a></li>
                    <li><a href="${pageContext.request.contextPath}/editor/drafts">📝 我的文章</a></li>
                    <li><a href="${pageContext.request.contextPath}/editor/materials">🖼️ 素材库</a></li>
                    <li><a href="${pageContext.request.contextPath}/editor/topics" class="active">🏷 我的话题</a></li>
                </ul>
            </aside>

            <div class="admin-main">
                <h2>${empty topic.id ? '🏷 新建话题' : '🏷 编辑话题'}</h2>

                <c:if test="${topic.status == 2}">
                    <div class="reject-alert">
                        <strong>审核未通过：</strong>${topic.rejectReason}
                        <span class="hint">修改保存后将自动重新进入待审核</span>
                    </div>
                </c:if>

                <form id="topicForm" class="editor-form">
                    <input type="hidden" id="topicId" value="${topic.id}">
                    <input type="hidden" id="coverInput" value="${topic.cover}">

                    <div class="form-group">
                        <label>话题名称 *</label>
                        <input type="text" id="topicTitle" value="${topic.title}" maxlength="40"
                               placeholder="如：开学季 / 人工智能与校园">
                        <span class="avatar-hint">建议 2-12 个字，尽量不与已有话题重复</span>
                    </div>

                    <div class="form-group">
                        <label>话题简介</label>
                        <textarea id="topicDesc" rows="4" maxlength="200"
                                  placeholder="简单介绍话题的内容范围，帮助用户理解与关注">${topic.description}</textarea>
                    </div>

                    <div class="form-group">
                        <label>话题封面</label>
                        <div class="cover-picker">
                            <div class="cover-preview" id="coverPreview">
                                <c:choose>
                                    <c:when test="${not empty topic.cover}">
                                        <img src="${pageContext.request.contextPath}${topic.cover}" alt="封面">
                                    </c:when>
                                    <c:otherwise>
                                        <span class="cover-empty">暂无封面</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                            <div class="cover-actions">
                                <button type="button" class="btn-outline" id="btnUploadCover">⬆️ 上传封面</button>
                                <button type="button" class="btn-outline" onclick="clearCover()">清除</button>
                                <span class="avatar-hint">可选，jpg / png / gif，不超过 50MB</span>
                            </div>
                            <input type="file" id="coverFile" accept="image/*" style="display:none">
                        </div>
                    </div>

                    <div class="form-actions">
                        <button type="button" id="btnSave" class="btn btn-primary">💾 保存并提交审核</button>
                        <a href="${pageContext.request.contextPath}/editor/topics" class="btn btn-link">返回我的话题</a>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script src="${pageContext.request.contextPath}/static/js/jquery.min.js"></script>
    <script>
        var ctx = "${pageContext.request.contextPath}";

        $("#btnUploadCover").click(function() { $("#coverFile").click(); });

        $("#coverFile").change(function() {
            var file = this.files[0];
            if (!file) return;
            if (file.size > 50 * 1024 * 1024) { alert("文件不能超过 50MB"); this.value = ""; return; }
            var fd = new FormData();
            fd.append("file", file);
            $.ajax({
                url: ctx + "/editor/upload",
                type: "POST", data: fd, processData: false, contentType: false,
                success: function(res) {
                    if (res.code === 200) {
                        $("#coverInput").val(res.data.url);
                        $("#coverPreview").html('<img src="' + ctx + res.data.url + '" alt="封面">');
                    } else { alert(res.msg); }
                },
                error: function() { alert("上传失败，请重试"); }
            });
            this.value = "";
        });

        function clearCover() {
            $("#coverInput").val("");
            $("#coverPreview").html('<span class="cover-empty">暂无封面</span>');
        }

        $("#btnSave").click(function() {
            var title = $.trim($("#topicTitle").val());
            if (!title) { alert("请填写话题名称"); return; }
            var idVal = $("#topicId").val();
            var data = {
                id: idVal ? parseInt(idVal) : null,
                title: title,
                description: $.trim($("#topicDesc").val()),
                cover: $("#coverInput").val()
            };
            var $btn = $(this).prop("disabled", true);
            $.ajax({
                url: ctx + "/editor/topic/save",
                type: "POST", contentType: "application/json",
                data: JSON.stringify(data),
                success: function(res) {
                    alert(res.msg);
                    if (res.code === 200) location.href = ctx + "/editor/topics?status=0";
                    else $btn.prop("disabled", false);
                },
                error: function() {
                    alert("保存失败，请重试");
                    $btn.prop("disabled", false);
                }
            });
        });
    </script>
</body>
</html>
