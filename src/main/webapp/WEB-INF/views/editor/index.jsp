<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
    <title>工作台概览 - 校园头条自媒体</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/style.css?v=28">
</head>
<body>
    <%@ include file="/WEB-INF/views/common/header.jsp" %>

    <div class="container">
        <div class="admin-layout">
            <aside class="admin-sidebar">
                <h3>自媒体工作台</h3>
                <ul>
                    <li><a href="${pageContext.request.contextPath}/editor/index" class="active">📊 概览</a></li>
                    <li><a href="${pageContext.request.contextPath}/editor/draft/new">✍️ 写文章</a></li>
                    <li><a href="${pageContext.request.contextPath}/editor/drafts">📝 我的文章</a></li>
                    <li><a href="${pageContext.request.contextPath}/editor/materials">🖼️ 素材库</a></li>
                    <li><a href="${pageContext.request.contextPath}/editor/topics">🏷 我的话题</a></li>
                </ul>
            </aside>

            <div class="admin-main">
                <h2>📊 工作台概览</h2>

                <!-- 稿件状态统计 -->
                <div class="editor-stats">
                    <a class="stat-card" href="${pageContext.request.contextPath}/editor/drafts">
                        <div class="stat-num">${stats.all}</div>
                        <div class="stat-label">全部稿件</div>
                    </a>
                    <a class="stat-card" href="${pageContext.request.contextPath}/editor/drafts?status=0">
                        <div class="stat-num">${stats.status0}</div>
                        <div class="stat-label">草稿待完善</div>
                    </a>
                    <a class="stat-card" href="${pageContext.request.contextPath}/editor/drafts?status=1">
                        <div class="stat-num">${stats.status1}</div>
                        <div class="stat-label">审核中</div>
                    </a>
                    <a class="stat-card" href="${pageContext.request.contextPath}/editor/drafts?status=2">
                        <div class="stat-num">${stats.status2}</div>
                        <div class="stat-label">已发布</div>
                    </a>
                    <a class="stat-card" href="${pageContext.request.contextPath}/editor/drafts?status=3">
                        <div class="stat-num">${stats.status3}</div>
                        <div class="stat-label">被驳回</div>
                    </a>
                    <a class="stat-card" href="${pageContext.request.contextPath}/editor/materials">
                        <div class="stat-num">${materialCount}</div>
                        <div class="stat-label">素材数量</div>
                    </a>
                    <a class="stat-card" href="${pageContext.request.contextPath}/editor/topics">
                        <div class="stat-num">${topicCount}</div>
                        <div class="stat-label">我的话题</div>
                    </a>
                </div>

                <div class="quick-actions">
                    <a href="${pageContext.request.contextPath}/editor/draft/new" class="btn btn-primary">✍️ 写文章</a>
                    <a href="${pageContext.request.contextPath}/editor/materials" class="btn btn-outline">🖼️ 上传素材</a>
                    <a href="${pageContext.request.contextPath}/editor/topic/new" class="btn btn-outline">🏷 新建话题</a>
                    <a href="${pageContext.request.contextPath}/editor/drafts?status=3" class="btn btn-outline">⚠️ 查看被驳回</a>
                </div>

                <h3 class="section-title">最近稿件</h3>
                <table class="data-table">
                    <thead>
                        <tr><th>标题</th><th>频道</th><th>状态</th><th>更新时间</th><th>操作</th></tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${recentArticles.records}" var="d">
                            <tr>
                                <td class="cell-title">${d.title}</td>
                                <td>${empty d.channelName ? '-' : d.channelName}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${d.status == 0}"><span class="badge badge-gray">草稿</span></c:when>
                                        <c:when test="${d.status == 1}"><span class="badge badge-orange">待审核</span></c:when>
                                        <c:when test="${d.status == 2}"><span class="badge badge-green">已发布</span></c:when>
                                        <c:when test="${d.status == 3}"><span class="badge badge-red">已驳回</span></c:when>
                                        <c:otherwise><span class="badge badge-gray">已下架</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td><fmt:formatDate value="${d.updateTime}" pattern="MM-dd HH:mm"/></td>
                                <td>
                                    <c:if test="${d.status == 0 || d.status == 3}">
                                        <a href="${pageContext.request.contextPath}/editor/draft/edit/${d.id}"
                                           class="btn btn-sm btn-primary">编辑</a>
                                    </c:if>
                                    <c:if test="${d.status == 1}">
                                        <span class="hint">审核中</span>
                                    </c:if>
                                    <c:if test="${d.status == 2}">
                                        <a href="${pageContext.request.contextPath}/news/detail/${d.id}"
                                           target="_blank" class="btn btn-sm btn-outline">查看</a>
                                    </c:if>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty recentArticles.records}">
                            <tr><td colspan="5" class="empty-tip">还没有稿件，点击「写文章」开始创作吧</td></tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <script src="${pageContext.request.contextPath}/static/js/jquery.min.js"></script>
</body>
</html>
