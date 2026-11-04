<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
    <title>#${topic.title} - 话题 - 校园头条</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/style.css?v=28">
</head>
<body>
    <%@ include file="/WEB-INF/views/common/header.jsp" %>

    <div class="container">
        <!-- 话题头部 -->
        <section class="topic-detail-head">
            <div class="topic-detail-cover">
                <c:choose>
                    <c:when test="${not empty topic.cover}">
                        <img src="${fn:startsWith(topic.cover, 'http') ? topic.cover : pageContext.request.contextPath.concat(topic.cover)}"
                             alt="${topic.title}" onerror="this.style.display='none'">
                    </c:when>
                    <c:otherwise><span>#</span></c:otherwise>
                </c:choose>
            </div>
            <div class="topic-detail-info">
                <h1>
                    #${topic.title}
                    <c:if test="${topic.isHot == 1}"><span class="badge badge-orange">🔥 热门话题</span></c:if>
                    <c:if test="${topic.status != 1}"><span class="badge badge-gray">未上线</span></c:if>
                </h1>
                <p class="topic-detail-desc">${empty topic.description ? '该话题暂无简介' : topic.description}</p>
                <div class="topic-detail-meta">
                    <span>📰 ${topic.articleCount == null ? 0 : topic.articleCount} 篇文章</span>
                    <span>⭐ <i id="topicFollowerCount">${topic.followerCount == null ? 0 : topic.followerCount}</i> 人关注</span>
                    <span>👤 创建人：${empty topic.creatorName ? '校园头条' : topic.creatorName}</span>
                    <span>🕒 <fmt:formatDate value="${topic.createTime}" pattern="yyyy-MM-dd"/></span>
                </div>
                <div class="topic-detail-actions">
                    <c:if test="${topic.status == 1}">
                        <button id="btnFollowTopic" class="btn follow-btn ${topic.followed ? 'followed' : ''}"
                                onclick="toggleFollow(${topic.id}, this)">
                            ${topic.followed ? '已关注' : '+ 关注话题'}
                        </button>
                    </c:if>
                    <a class="btn btn-outline" href="${pageContext.request.contextPath}/topic/list">← 全部话题</a>
                    <c:if test="${sessionScope.loginUser.role == 'MEDIA'}">
                        <a class="btn btn-outline" href="${pageContext.request.contextPath}/editor/draft/new">为话题写稿</a>
                    </c:if>
                </div>
            </div>
        </section>

        <!-- 话题文章列表 -->
        <div class="topic-detail-list">
            <div class="topic-list-head">
                <h3>📰 话题下的文章</h3>
                <form class="topic-inline-search" action="${pageContext.request.contextPath}/topic/detail/${topic.id}" method="get">
                    <input type="text" name="keyword" value="${keyword}" placeholder="在话题内搜索...">
                    <button type="submit">搜索</button>
                </form>
            </div>

            <c:forEach items="${articlePage.records}" var="article">
                <article class="article-item ${article.cover != null ? 'has-cover' : ''}">
                    <c:if test="${article.cover != null}">
                        <a href="${pageContext.request.contextPath}/news/detail/${article.id}" class="article-thumb">
                            <img src="${fn:startsWith(article.cover, 'http') ? article.cover : pageContext.request.contextPath.concat(article.cover)}"
                                 alt="${article.title}" loading="lazy"
                                 onerror="this.src='${pageContext.request.contextPath}/static/img/no-cover.svg'">
                        </a>
                    </c:if>
                    <div class="article-body">
                        <h3 class="article-title">
                            <c:if test="${article.isTop == 1}"><span class="tag tag-red">置顶</span></c:if>
                            <a href="${pageContext.request.contextPath}/news/detail/${article.id}">${article.title}</a>
                        </h3>
                        <c:if test="${not empty article.summary}">
                            <p class="article-summary">${article.summary}</p>
                        </c:if>
                        <div class="article-meta">
                            <span class="meta-item">${article.channelName}</span>
                            <span class="meta-item">${article.authorName != null ? article.authorName : '校园头条'}</span>
                            <span class="meta-item">
                                <fmt:formatDate value="${article.publishTime}" pattern="MM-dd HH:mm"/>
                            </span>
                            <span class="meta-item">👁 ${article.viewCount}</span>
                            <span class="meta-item">💬 ${article.commentCount != null ? article.commentCount : 0}</span>
                            <span class="meta-item">❤️ ${article.likeCount != null ? article.likeCount : 0}</span>
                        </div>
                    </div>
                </article>
            </c:forEach>

            <c:if test="${empty articlePage.records}">
                <div class="empty-tip">该话题下暂无已发布文章</div>
            </c:if>

            <c:if test="${articlePage.pages > 1}">
                <div class="pagination">
                    <c:if test="${articlePage.current > 1}">
                        <a href="${pageContext.request.contextPath}/topic/detail/${topic.id}?page=${articlePage.current - 1}${empty keyword ? '' : '&keyword='.concat(keyword)}" class="btn-page">上一页</a>
                    </c:if>
                    <span class="page-info">${articlePage.current} / ${articlePage.pages}</span>
                    <c:if test="${articlePage.current < articlePage.pages}">
                        <a href="${pageContext.request.contextPath}/topic/detail/${topic.id}?page=${articlePage.current + 1}${empty keyword ? '' : '&keyword='.concat(keyword)}" class="btn-page">下一页</a>
                    </c:if>
                </div>
            </c:if>
        </div>
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
                    $(btn).toggleClass("followed", followed).text(followed ? "已关注" : "+ 关注话题");
                    $("#topicFollowerCount").text(res.data.followerCount);
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
