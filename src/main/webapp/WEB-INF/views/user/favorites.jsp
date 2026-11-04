<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
    <title>我的收藏 - 校园头条</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/style.css?v=28">
</head>
<body>
    <%@ include file="/WEB-INF/views/common/header.jsp" %>

    <div class="container">
        <div class="list-page-head">
            <h2>⭐ 我的收藏</h2>
            <a href="${pageContext.request.contextPath}/user/likes" class="btn-outline">❤️ 我赞过的</a>
        </div>

        <div id="favList" class="list-section"></div>
        <div class="pagination" id="favPage"></div>
    </div>

    <script src="${pageContext.request.contextPath}/static/js/jquery.min.js"></script>
    <script>
    var ctx = "${pageContext.request.contextPath}";

    function esc(s) {
        return String(s == null ? "" : s).replace(/&/g, "&amp;").replace(/</g, "&lt;")
            .replace(/>/g, "&gt;").replace(/"/g, "&quot;");
    }

    function articleHtml(a) {
        var html = '<a href="' + ctx + '/news/detail/' + a.id + '" class="article-item has-cover" style="text-decoration:none;">';
        if (a.cover) {
            var coverUrl = /^https?:\/\//.test(a.cover) ? a.cover : (ctx + a.cover);
            html += '<div class="article-thumb"><img src="' + coverUrl + '" loading="lazy" onerror="this.src=\'' + ctx + '/static/img/no-cover.svg\'"></div>';
        }
        html += '<div class="article-body">';
        html += '<h3 class="article-title">' + esc(a.title) + '</h3>';
        if (a.summary) html += '<p class="article-summary">' + esc(a.summary) + '</p>';
        html += '<div class="article-meta">';
        html += '<span class="meta-item"><span class="cat-dot" style="background:var(--primary)"></span>' + esc(a.channelName || '校园头条') + '</span>';
        html += '<span class="meta-item">👁 ' + (a.viewCount || 0) + '</span>';
        html += '<span class="meta-item">❤️ ' + (a.likeCount || 0) + '</span>';
        html += '</div></div></a>';
        return html;
    }

    function loadList(url, page) {
        $.get(url, { page: page || 1, size: 10 }, function(res) {
            var html = "";
            if (res.code === 200 && res.data && res.data.records && res.data.records.length > 0) {
                res.data.records.forEach(function(o) {
                    if (!o) return;
                    html += articleHtml(o);
                });
                renderPage(res.data);
            } else if (res.code === 401) {
                html = '<div class="empty-tip">请先登录后查看</div>';
            } else {
                html = '<div class="empty-tip">还没有收藏任何文章</div>';
            }
            $("#favList").html(html);
        });
    }

    function renderPage(data) {
        var pages = data.pages || 0;
        if (pages <= 1) { $("#favPage").html(""); return; }
        var html = "";
        if (data.current > 1) {
            html += '<a href="javascript:;" onclick="loadList(ctx+\'/user/favorites/data\',' + (data.current - 1) + ')" class="btn-page">上一页</a>';
        }
        html += '<span class="page-info">' + data.current + ' / ' + pages + '</span>';
        if (data.current < pages) {
            html += '<a href="javascript:;" onclick="loadList(ctx+\'/user/favorites/data\',' + (data.current + 1) + ')" class="btn-page">下一页</a>';
        }
        $("#favPage").html(html);
    }

    loadList(ctx + "/user/favorites/data", 1);
    </script>
</body>
</html>
