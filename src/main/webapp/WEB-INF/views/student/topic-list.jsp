<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
    <title>话题广场 - 校园头条</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/style.css?v=28">
</head>
<body>
    <%@ include file="/WEB-INF/views/common/header.jsp" %>

    <div class="container">
        <section class="topic-hero">
            <h1>🔥 话题广场</h1>
            <p>聚合校园热点话题，关注你感兴趣的话题，第一时间获取相关资讯。</p>
            <form class="topic-search" action="${pageContext.request.contextPath}/topic/list" method="get">
                <input type="text" name="keyword" value="${keyword}" placeholder="搜索话题名称或简介...">
                <button type="submit">搜索</button>
            </form>
            <c:if test="${not empty keyword}">
                <div class="topic-search-tip">
                    正在搜索「${keyword}」，
                    <a href="${pageContext.request.contextPath}/topic/list">查看全部话题</a>
                </div>
            </c:if>
        </section>

        <c:if test="${empty pageList.records}">
            <div class="empty-tip">暂无上线话题，稍后再来看看吧</div>
        </c:if>

        <div class="topic-grid">
            <c:forEach items="${pageList.records}" var="t">
                <div class="topic-card" id="topic-card-${t.id}">
                    <a class="topic-card-cover" href="${pageContext.request.contextPath}/topic/detail/${t.id}">
                        <c:choose>
                            <c:when test="${not empty t.cover}">
                                <img src="${fn:startsWith(t.cover, 'http') ? t.cover : pageContext.request.contextPath.concat(t.cover)}"
                                     alt="${t.title}" onerror="this.style.display='none'">
                            </c:when>
                            <c:otherwise>
                                <span class="topic-card-hash">#</span>
                            </c:otherwise>
                        </c:choose>
                        <c:if test="${t.isHot == 1}"><span class="topic-hot-flag">🔥 热门</span></c:if>
                    </a>
                    <div class="topic-card-body">
                        <a class="topic-card-title" href="${pageContext.request.contextPath}/topic/detail/${t.id}">
                            #${t.title}
                        </a>
                        <p class="topic-card-desc">${empty t.description ? '暂无话题简介' : t.description}</p>
                        <div class="topic-card-meta">
                            <span>📰 ${t.articleCount == null ? 0 : t.articleCount} 篇文章</span>
                            <span>⭐ <i id="follow-count-${t.id}">${t.followerCount == null ? 0 : t.followerCount}</i> 人关注</span>
                            <span>👤 ${empty t.creatorName ? '校园头条' : t.creatorName}</span>
                        </div>
                    </div>
                    <div class="topic-card-actions">
                        <button class="btn btn-sm follow-btn ${t.followed ? 'followed' : ''}"
                                data-id="${t.id}" onclick="toggleFollow(${t.id}, this)">
                            ${t.followed ? '已关注' : '+ 关注'}
                        </button>
                        <a class="btn btn-sm btn-outline" href="${pageContext.request.contextPath}/topic/detail/${t.id}">查看话题</a>
                    </div>
                </div>
            </c:forEach>
        </div>

        <c:if test="${pageList.pages > 1}">
            <div class="pagination">
                <c:if test="${pageList.current > 1}">
                    <a href="${pageContext.request.contextPath}/topic/list?page=${pageList.current - 1}${empty keyword ? '' : '&keyword='.concat(keyword)}" class="btn-page">上一页</a>
                </c:if>
                <span class="page-info">${pageList.current} / ${pageList.pages}</span>
                <c:if test="${pageList.current < pageList.pages}">
                    <a href="${pageContext.request.contextPath}/topic/list?page=${pageList.current + 1}${empty keyword ? '' : '&keyword='.concat(keyword)}" class="btn-page">下一页</a>
                </c:if>
            </div>
        </c:if>
    </div>

    <script src="${pageContext.request.contextPath}/static/js/jquery.min.js"></script>
    <script>
        var ctx = "${pageContext.request.contextPath}";
        var loggedIn = ${sessionScope.loginUser != null};

        function toggleFollow(id, btn) {
            if (!loggedIn) {
                if (confirm("关注话题需要先登录，现在去登录？")) location.href = ctx + "/user/login";
                return;
            }
            $.post(ctx + "/topic/follow/" + id, function(res) {
                if (res.code === 200) {
                    var followed = res.data.followed;
                    $(btn).toggleClass("followed", followed).text(followed ? "已关注" : "+ 关注");
                    $("#follow-count-" + id).text(res.data.followerCount);
                } else if (res.code === 401) {
                    if (confirm(res.msg + "，现在去登录？")) location.href = ctx + "/user/login";
                } else {
                    alert(res.msg);
                }
            }).fail(function() { alert("网络异常，请重试"); });
        }
    </script>
</body>
</html>
