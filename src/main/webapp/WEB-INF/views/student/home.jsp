<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
    <title>校园头条 - 发现校园好新闻</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/style.css?v=28">
</head>
<body>
    <%@ include file="/WEB-INF/views/common/header.jsp" %>

    <!-- ============ Hero Banner 轮播 ============ -->
    <section class="hero-banner" id="heroBanner">
        <div class="hero-track">
            <c:forEach items="${bannerList}" var="b" varStatus="i">
                <a href="${pageContext.request.contextPath}/news/detail/${b.id}"
                   class="hero-slide ${i.index == 0 ? 'active' : ''}"
                   style="background-image: url('${fn:startsWith(b.cover, 'http') ? b.cover : pageContext.request.contextPath.concat(b.cover)}')">
                    <div class="hero-overlay"></div>
                    <div class="hero-caption">
                        <span class="hero-tag">🔥 头条推荐</span>
                        <h2>${b.title}</h2>
                        <p>${b.summary}</p>
                    </div>
                </a>
            </c:forEach>
            <c:if test="${empty bannerList}">
                <a href="${pageContext.request.contextPath}/news/detail/1" class="hero-slide active"
                   style="background-image: url('https://picsum.photos/seed/campus-hero/1200/500')">
                    <div class="hero-overlay"></div>
                    <div class="hero-caption">
                        <span class="hero-tag">🎓 校园头条</span>
                        <h2>发现校园好新闻</h2>
                        <p>实时掌握校园动态 · 精选权威资讯 · 开放创作平台</p>
                    </div>
                </a>
            </c:if>
        </div>
        <button class="hero-btn hero-prev" onclick="slideHero(-1)">‹</button>
        <button class="hero-btn hero-next" onclick="slideHero(1)">›</button>
        <div class="hero-dots">
            <c:forEach items="${bannerList}" var="b" varStatus="i">
                <span class="hero-dot ${i.index == 0 ? 'active' : ''}" onclick="slideHeroTo(${i.index})"></span>
            </c:forEach>
            <c:if test="${empty bannerList}">
                <span class="hero-dot active"></span>
            </c:if>
        </div>
    </section>

    <!-- ============ 置顶头条 - 白底卡片 ============ -->
    <c:if test="${not empty topList}">
    <div class="container pinned-bar-wrap">
        <div class="pinned-bar">
            <div class="pinned-head">
                <span class="pinned-head-icon">
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="3">
                        <path d="M12 2L2 7l10 5 10-5-10-5z"/>
                    </svg>
                </span>
                <span class="pinned-head-title">置顶头条</span>
                <span class="pinned-head-sub">共 ${topList.size()} 篇</span>
            </div>
            <ul class="pinned-list">
                <c:forEach items="${topList}" var="t" varStatus="i">
                    <li>
                        <span class="pinned-num">${i.index + 1}</span>
                        <a href="${pageContext.request.contextPath}/news/detail/${t.id}">
                            <c:if test="${t.isUrgent == 1}"><span class="tag tag-danger tag-sm">紧急</span></c:if>
                            <c:if test="${t.isTop == 1 and t.isUrgent != 1}"><span class="tag tag-red tag-sm">置顶</span></c:if>
                            ${t.title}
                        </a>
                    </li>
                </c:forEach>
            </ul>
        </div>
    </div>
    </c:if>

    <!-- ============ 热门话题 ============ -->
    <c:if test="${not empty hotTopics}">
    <div class="container topic-strip">
        <span class="topic-strip-label">🔥 热门话题</span>
        <div class="topic-strip-list">
            <c:forEach items="${hotTopics}" var="t">
                <a class="topic-chip" href="${pageContext.request.contextPath}/topic/detail/${t.id}">
                    #${t.title}<em>${t.articleCount != null ? t.articleCount : 0}</em>
                </a>
            </c:forEach>
            <a class="topic-chip-more" href="${pageContext.request.contextPath}/topic/list">全部话题 ›</a>
        </div>
    </div>
    </c:if>

    <!-- ============ 频道 Tab ============ -->
    <div class="container category-nav-wrap">
    <nav class="category-nav">
        <a href="${pageContext.request.contextPath}/news/home"
           class="${empty currentChannel ? 'active' : ''}">全部</a>
        <c:forEach items="${channels}" var="cat">
            <a href="${pageContext.request.contextPath}/news/home?channelId=${cat.id}"
               class="${currentChannel eq cat.id ? 'active' : ''}">${cat.name}</a>
        </c:forEach>
    </nav>
    </div>

    <div class="container main-layout">
        <!-- ============ 左侧：文章列表 ============ -->
        <div class="content-main">
            <c:forEach items="${pageList.records}" var="article">
                <article class="article-item ${article.cover != null ? 'has-cover' : ''}">
                    <c:if test="${article.cover != null}">
                        <a href="${pageContext.request.contextPath}/news/detail/${article.id}" class="article-thumb">
                            <img src="${fn:startsWith(article.cover, 'http') ? article.cover : pageContext.request.contextPath.concat(article.cover)}" alt="${article.title}" loading="lazy"
                                 onerror="this.src='${pageContext.request.contextPath}/static/img/no-cover.svg'">
                        </a>
                    </c:if>
                    <div class="article-body">
                        <h3 class="article-title">
                            <c:if test="${article.isTop == 1}"><span class="tag tag-red">置顶</span></c:if>
                            <c:if test="${article.isUrgent == 1}"><span class="tag tag-danger">紧急</span></c:if>
                            <a href="${pageContext.request.contextPath}/news/detail/${article.id}">${article.title}</a>
                        </h3>
                        <c:if test="${not empty article.summary}">
                            <p class="article-summary">${article.summary}</p>
                        </c:if>
                        <div class="article-meta">
                            <span class="meta-item">
                                <span class="cat-dot" style="background: var(--primary)"></span>
                                ${article.channelName}
                            </span>
                            <span class="meta-item">${article.authorName != null ? article.authorName : '校园头条'}</span>
                            <span class="meta-item">
                                <fmt:formatDate value="${article.publishTime}" pattern="MM-dd HH:mm"/>
                            </span>
                            <c:if test="${not empty article.topicName}">
                                <a class="topic-mini-tag" href="${pageContext.request.contextPath}/topic/detail/${article.topicId}">#${article.topicName}</a>
                            </c:if>
                            <span class="meta-item">👁 ${article.viewCount}</span>
                            <span class="meta-item">💬 ${article.commentCount != null ? article.commentCount : 0}</span>
                            <span class="meta-item">❤️ ${article.likeCount != null ? article.likeCount : 0}</span>
                        </div>
                    </div>
                </article>
            </c:forEach>

            <c:if test="${empty pageList.records}">
                <div class="empty-tip">暂无资讯，换个频道看看？</div>
            </c:if>

            <!-- 分页 -->
            <c:if test="${pageList.pages > 1}">
                <div class="pagination">
                    <c:if test="${pageList.current > 1}">
                        <a href="?page=${pageList.current - 1}&channelId=${currentChannel}&keyword=${keyword}" class="btn-page">上一页</a>
                    </c:if>
                    <span class="page-info">${pageList.current} / ${pageList.pages}</span>
                    <c:if test="${pageList.current < pageList.pages}">
                        <a href="?page=${pageList.current + 1}&channelId=${currentChannel}&keyword=${keyword}" class="btn-page">下一页</a>
                    </c:if>
                </div>
            </c:if>
        </div>

        <!-- ============ 右侧栏 ============ -->
        <aside class="sidebar">
            <!-- 用户卡 -->
            <c:if test="${sessionScope.loginUser != null}">
                <div class="side-card user-card">
                    <c:set var="u" value="${sessionScope.loginUser}"/>
                    <div class="user-card-avatar">
                        <c:choose>
                            <c:when test="${not empty u.avatar}">
                                <img class="avatar-img" src="${pageContext.request.contextPath}${u.avatar}" alt="头像">
                            </c:when>
                            <c:otherwise>
                                ${fn:escapeXml(u.nickname != null ? u.nickname.charAt(0) : u.username.charAt(0))}
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <div class="user-card-info">
                        <div class="user-card-name">${u.nickname != null ? u.nickname : u.username}</div>
                        <div class="user-card-role">
                            <c:choose>
                                <c:when test="${u.role == 'ADMIN'}">🔧 系统管理员</c:when>
                                <c:when test="${u.role == 'MEDIA'}">✍️ 自媒体人</c:when>
                                <c:otherwise>👤 普通用户</c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                    <div class="user-card-actions">
                        <a href="${pageContext.request.contextPath}/user/favorites" class="btn btn-sm btn-outline">我的收藏</a>
                        <a href="${pageContext.request.contextPath}/user/likes" class="btn btn-sm btn-outline">我赞过的</a>
                        <c:if test="${u.role == 'MEDIA'}">
                            <a href="${pageContext.request.contextPath}/editor/draft/new" class="btn btn-sm btn-primary">写文章</a>
                        </c:if>
                        <c:if test="${u.role == 'ADMIN'}">
                            <a href="${pageContext.request.contextPath}/admin/audit" class="btn btn-sm btn-primary">去审核</a>
                        </c:if>
                    </div>
                </div>
            </c:if>
            <c:if test="${sessionScope.loginUser == null}">
                <div class="side-card login-card">
                    <p class="login-card-text">登录后可收藏、评论、参与互动</p>
                    <a href="${pageContext.request.contextPath}/user/login" class="btn btn-primary btn-block">立即登录</a>
                </div>
            </c:if>

            <!-- 热门榜 -->
            <div class="side-card">
                <h3>🔥 热门资讯</h3>
                <ol class="hot-list">
                    <c:forEach items="${hotList}" var="h" varStatus="i">
                        <li class="hot-item">
                            <span class="rank rank-${i.index + 1}">${i.index + 1}</span>
                            <a href="${pageContext.request.contextPath}/news/detail/${h.id}">${h.title}</a>
                        </li>
                    </c:forEach>
                    <c:if test="${empty hotList}">
                        <li class="hot-item hot-empty">暂无热门</li>
                    </c:if>
                </ol>
            </div>

            <!-- 关于 -->
            <div class="side-card about-card">
                <h3><img src="${pageContext.request.contextPath}/static/img/logo.svg?v=5" alt="校园头条" class="side-logo">关于校园头条</h3>
                <p class="about-text">校园头条是面向全校师生的资讯平台，支持自媒体创作、内容审核、互动评论，让好新闻触达每一个人。</p>
            </div>
        </aside>
    </div>

    <!-- ============ 底部 ============ -->
    <footer class="site-footer">
        <p>© 2026 校园头条 Campus Headlines</p>
    </footer>

    <script src="${pageContext.request.contextPath}/static/js/jquery.min.js"></script>
    <script src="${pageContext.request.contextPath}/static/js/home.js?v=2"></script>
</body>
</html>
