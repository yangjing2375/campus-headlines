<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
    <title>素材库 - 校园头条自媒体</title>
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
                    <li><a href="${pageContext.request.contextPath}/editor/materials" class="active">🖼️ 素材库</a></li>
                    <li><a href="${pageContext.request.contextPath}/editor/topics">🏷 我的话题</a></li>
                </ul>
            </aside>

            <div class="admin-main">
                <h2>🖼️ 素材库</h2>

                <!-- 上传 -->
                <div class="upload-area">
                    <input type="file" id="materialFile" accept=".jpg,.jpeg,.png,.gif,.mp4">
                    <button type="button" class="btn btn-primary" id="btnUpload">⬆️ 上传素材</button>
                    <span class="hint">支持 jpg / png / gif / mp4，单个文件最大 50MB</span>
                    <span id="uploadStatus" class="hint"></span>
                </div>

                <!-- 类型筛选 -->
                <div class="status-tabs">
                    <a href="${pageContext.request.contextPath}/editor/materials"
                       class="${empty type ? 'active' : ''}">全部</a>
                    <a href="${pageContext.request.contextPath}/editor/materials?type=image"
                       class="${type == 'image' ? 'active' : ''}">图片</a>
                    <a href="${pageContext.request.contextPath}/editor/materials?type=video"
                       class="${type == 'video' ? 'active' : ''}">视频</a>
                </div>

                <!-- 素材网格 -->
                <div class="materials-grid">
                    <c:forEach items="${page.records}" var="m">
                        <div class="material-card">
                            <div class="material-thumb" onclick="preview('${m.url}', '${m.type}')">
                                <c:choose>
                                    <c:when test="${m.type == 'image'}">
                                        <img src="${pageContext.request.contextPath}${m.url}" alt="${m.name}">
                                    </c:when>
                                    <c:otherwise>
                                        <div class="material-video">🎬</div>
                                    </c:otherwise>
                                </c:choose>
                                <div class="material-hover">预览</div>
                            </div>
                            <div class="material-info">
                                <div class="material-name" title="${m.name}">${m.name}</div>
                                <div class="material-meta">
                                    <span>${m.type == 'image' ? '图片' : '视频'}</span>
                                    <span><fmt:formatNumber value="${m.size / 1024}" pattern="0"/> KB</span>
                                    <span><fmt:formatDate value="${m.createTime}" pattern="yyyy-MM-dd"/></span>
                                </div>
                            </div>
                            <button class="btn btn-sm btn-danger" onclick="del(${m.id})">删除</button>
                        </div>
                    </c:forEach>
                    <c:if test="${empty page.records}">
                        <div class="empty-tip">还没有素材，上传图片或视频后可在写文章时引用</div>
                    </c:if>
                </div>

                <!-- 分页 -->
                <div class="pagination">
                    <c:if test="${page.current > 1}">
                        <a href="${pageContext.request.contextPath}/editor/materials?page=${page.current - 1}&type=${type}"
                           class="btn-page">上一页</a>
                    </c:if>
                    <span class="page-info">第 ${page.current} / ${empty page.pages ? 1 : page.pages} 页，共 ${page.total} 个素材</span>
                    <c:if test="${page.current < page.pages}">
                        <a href="${pageContext.request.contextPath}/editor/materials?page=${page.current + 1}&type=${type}"
                           class="btn-page">下一页</a>
                    </c:if>
                </div>
            </div>
        </div>
    </div>

    <!-- 预览弹层 -->
    <div class="picker-mask" id="previewMask" onclick="closePreview()">
        <div class="preview-dialog" id="previewBody"></div>
    </div>

    <script src="${pageContext.request.contextPath}/static/js/jquery.min.js"></script>
    <script>
        var ctx = "${pageContext.request.contextPath}";

        $("#btnUpload").click(function() { $("#materialFile").click(); });

        $("#materialFile").change(function() {
            var file = this.files[0];
            if (!file) return;
            if (file.size > 50 * 1024 * 1024) { alert("文件不能超过 50MB"); return; }
            var fd = new FormData();
            fd.append("file", file);
            $("#uploadStatus").text("上传中...");
            $.ajax({
                url: ctx + "/editor/upload",
                type: "POST", data: fd, processData: false, contentType: false,
                success: function(res) {
                    if (res.code === 200) { location.reload(); }
                    else { alert(res.msg); $("#uploadStatus").text(""); }
                },
                error: function() { alert("上传失败，请重试"); $("#uploadStatus").text(""); }
            });
            this.value = "";
        });

        function del(id) {
            if (!confirm("确定删除该素材？")) return;
            $.post(ctx + "/editor/material/delete/" + id, function(res) {
                alert(res.msg);
                if (res.code === 200) location.reload();
            });
        }

        function preview(url, type) {
            var html = type === "image"
                ? '<img src="' + ctx + url + '" alt="预览">'
                : '<video src="' + ctx + url + '" controls autoplay></video>';
            $("#previewBody").html(html);
            $("#previewMask").addClass("show");
        }

        function closePreview() { $("#previewMask").removeClass("show"); }
    </script>
</body>
</html>
