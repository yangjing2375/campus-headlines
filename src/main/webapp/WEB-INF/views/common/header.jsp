<%-- 公共顶部导航栏 - 今日头条风格 --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<header class="site-header">
    <div class="header-inner">
        <!-- Logo -->
        <div class="logo">
            <a href="${ctx}/news/home">
                <img src="${ctx}/static/img/logo.svg?v=4" alt="校园头条" class="logo-icon">
                <span class="logo-text">校园头条</span>
            </a>
        </div>

        <!-- 话题广场入口 -->
        <nav class="header-mainnav">
            <a href="${ctx}/topic/list" class="mainnav-link">🔥 话题广场</a>
        </nav>

        <!-- Logo 右侧快捷导航：返回首页 + 返回上一页（已在首页时不显示） -->
        <c:set var="origPath" value="${requestScope['javax.servlet.forward.servlet_path']}"/>
        <c:if test="${empty origPath}">
            <c:set var="origPath" value="${pageContext.request.servletPath}"/>
        </c:if>
        <c:if test="${origPath ne '/news/home' and origPath ne '/news/search'}">
            <nav class="header-quicknav">
                <a href="${ctx}/news/home" class="quicknav-link">🏠 返回首页</a>
                <button type="button" class="quicknav-back" onclick="goBackPage()">‹ 返回</button>
            </nav>
        </c:if>

        <!-- 中间占位（留空让右侧靠边） -->
        <div class="header-spacer"></div>

        <!-- 搜索框 -->
        <form class="search-form" action="${ctx}/news/home" method="get">
            <input type="text" name="keyword" placeholder="搜索校园资讯..." value="${param.keyword}">
            <button type="submit">🔍</button>
        </form>

        <!-- 右侧用户区 -->
        <div class="header-right">
            <c:if test="${sessionScope.loginUser == null}">
                <a href="${ctx}/user/login" class="btn-login">登录 / 注册</a>
            </c:if>
            <c:if test="${sessionScope.loginUser != null}">
                <c:set var="user" value="${sessionScope.loginUser}"/>
                <c:if test="${user.role == 'MEDIA'}">
                    <a href="${ctx}/editor/draft/new" class="btn-publish">✍️ 发布文章</a>
                </c:if>
                <c:if test="${user.role == 'ADMIN'}">
                    <a href="${ctx}/admin/audit" class="btn-publish btn-admin">🛡 审核中心</a>
                </c:if>

                <div class="user-dropdown" id="userDropdown">
                    <div class="avatar-trigger" onclick="toggleUserMenu()">
                        <div class="avatar">
                            <c:choose>
                                <c:when test="${not empty user.avatar}">
                                    <img class="avatar-img" src="${ctx}${user.avatar}" alt="头像">
                                </c:when>
                                <c:otherwise>
                                    ${fn:escapeXml(user.nickname != null ? user.nickname.charAt(0) : user.username.charAt(0))}
                                </c:otherwise>
                            </c:choose>
                        </div>
                        <span class="user-name">${user.nickname != null ? user.nickname : user.username}</span>
                        <span class="dropdown-arrow">▼</span>
                    </div>
                    <div class="dropdown-menu" id="dropdownMenu">
                        <div class="dropdown-user-info">
                            <div class="avatar avatar-lg">
                                <c:choose>
                                    <c:when test="${not empty user.avatar}">
                                        <img class="avatar-img" src="${ctx}${user.avatar}" alt="头像">
                                    </c:when>
                                    <c:otherwise>
                                        ${fn:escapeXml(user.nickname != null ? user.nickname.charAt(0) : user.username.charAt(0))}
                                    </c:otherwise>
                                </c:choose>
                            </div>
                            <div class="dropdown-user-detail">
                                <div class="dropdown-nickname">${user.nickname != null ? user.nickname : user.username}</div>
                                <div class="dropdown-role">
                                    <c:choose>
                                        <c:when test="${user.role == 'ADMIN'}">🔧 系统管理员</c:when>
                                        <c:when test="${user.role == 'MEDIA'}">✍️ 自媒体人</c:when>
                                        <c:otherwise>👤 普通用户</c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </div>
                        <div class="dropdown-divider"></div>
                        <a href="${ctx}/user/profile" class="dropdown-item">
                            <span class="dropdown-icon">👤</span> 个人中心
                        </a>
                        <a href="${ctx}/user/favorites" class="dropdown-item">
                            <span class="dropdown-icon">⭐</span> 我的收藏
                        </a>
                        <a href="${ctx}/user/likes" class="dropdown-item">
                            <span class="dropdown-icon">❤️</span> 我赞过的
                        </a>
                        <a href="${ctx}/topic/list" class="dropdown-item">
                            <span class="dropdown-icon">🔥</span> 话题广场
                        </a>
                        <c:if test="${user.role == 'MEDIA'}">
                            <div class="dropdown-divider"></div>
                            <a href="${ctx}/editor/index" class="dropdown-item">
                                <span class="dropdown-icon">📰</span> 创作平台
                            </a>
                            <a href="${ctx}/editor/drafts" class="dropdown-item">
                                <span class="dropdown-icon">📝</span> 我的稿件
                            </a>
                            <a href="${ctx}/editor/materials" class="dropdown-item">
                                <span class="dropdown-icon">🎬</span> 素材管理
                            </a>
                            <a href="${ctx}/editor/topics" class="dropdown-item">
                                <span class="dropdown-icon">🏷</span> 我的话题
                            </a>
                        </c:if>
                        <c:if test="${user.role == 'ADMIN'}">
                            <div class="dropdown-divider"></div>
                            <a href="${ctx}/admin/dashboard" class="dropdown-item">
                                <span class="dropdown-icon">⚙️</span> 后台管理
                            </a>
                            <a href="${ctx}/admin/audit" class="dropdown-item">
                                <span class="dropdown-icon">🛡</span> 审核中心
                            </a>
                            <a href="${ctx}/admin/topics" class="dropdown-item">
                                <span class="dropdown-icon">🏷</span> 话题管理
                            </a>
                        </c:if>
                        <div class="dropdown-divider"></div>
                        <a href="${ctx}/user/logout" class="dropdown-item dropdown-logout">
                            <span class="dropdown-icon">🚪</span> 退出登录
                        </a>
                    </div>
                </div>
            </c:if>
        </div>
    </div>
</header>
<c:if test="${false}">
</c:if>
<script>
function toggleUserMenu() {
    var menu = document.getElementById('dropdownMenu');
    menu.style.display = menu.style.display === 'block' ? 'none' : 'block';
}
// 点击外部关闭下拉
document.addEventListener('click', function(e) {
    var dropdown = document.getElementById('userDropdown');
    if (dropdown && !dropdown.contains(e.target)) {
        document.getElementById('dropdownMenu').style.display = 'none';
    }
});

// 返回上一页；没有历史记录时回首页
function goBackPage() {
    if (window.history.length > 1) {
        window.history.back();
    } else {
        window.location.href = '${ctx}/news/home';
    }
}

// 从浏览器缓存返回时强制刷新，避免点赞/收藏数与数据库不一致
window.addEventListener('pageshow', function(e) {
    if (e.persisted) window.location.reload();
});
</script>
