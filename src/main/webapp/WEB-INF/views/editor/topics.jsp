<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
    <title>我的话题 - 校园头条自媒体</title>
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
                <div class="page-head">
                    <h2>🏷 我的话题</h2>
                    <a href="${pageContext.request.contextPath}/editor/topic/new" class="btn btn-primary">＋ 新建话题</a>
                </div>

                <div class="status-tabs">
                    <a href="${pageContext.request.contextPath}/editor/topics" class="${empty status ? 'active' : ''}">全部 ${stats.all}</a>
                    <a href="${pageContext.request.contextPath}/editor/topics?status=0" class="${status == 0 ? 'active' : ''}">待审核 ${stats.status0}</a>
                    <a href="${pageContext.request.contextPath}/editor/topics?status=1" class="${status == 1 ? 'active' : ''}">已上线 ${stats.status1}</a>
                    <a href="${pageContext.request.contextPath}/editor/topics?status=2" class="${status == 2 ? 'active' : ''}">已驳回 ${stats.status2}</a>
                    <a href="${pageContext.request.contextPath}/editor/topics?status=3" class="${status == 3 ? 'active' : ''}">已禁用 ${stats.status3}</a>
                </div>

                <div class="filter-bar">
                    <input type="text" id="topicKeyword" placeholder="搜索话题名称 / 简介" value="${keyword}"
                           onkeyup="if(event.keyCode===13)doSearch()">
                    <button class="btn btn-sm btn-primary" onclick="doSearch()">搜索</button>
                    <c:if test="${not empty keyword}">
                        <a class="btn btn-sm btn-outline" href="${pageContext.request.contextPath}/editor/topics${empty status ? '' : '?status='.concat(status)}">清空</a>
                    </c:if>
                </div>

                <c:if test="${empty pageList.records}">
                    <div class="empty-tip">
                        还没有话题，点击右上角「新建话题」创建你的第一个话题吧。
                    </div>
                </c:if>

                <div class="topic-admin-list">
                    <c:forEach items="${pageList.records}" var="t">
                        <div class="topic-admin-item" id="topic-row-${t.id}">
                            <div class="topic-admin-cover">
                                <c:choose>
                                    <c:when test="${not empty t.cover}">
                                        <img src="${pageContext.request.contextPath}${t.cover}" alt="${t.title}"
                                             onerror="this.style.display='none'">
                                    </c:when>
                                    <c:otherwise><span>#</span></c:otherwise>
                                </c:choose>
                            </div>
                            <div class="topic-admin-body">
                                <div class="topic-admin-title">
                                    <a href="${pageContext.request.contextPath}/topic/detail/${t.id}" target="_blank">#${t.title}</a>
                                    <c:choose>
                                        <c:when test="${t.status == 0}"><span class="badge badge-gray">待审核</span></c:when>
                                        <c:when test="${t.status == 1}"><span class="badge badge-green">已上线</span></c:when>
                                        <c:when test="${t.status == 2}"><span class="badge badge-red">已驳回</span></c:when>
                                        <c:otherwise><span class="badge badge-gray">已禁用</span></c:otherwise>
                                    </c:choose>
                                    <c:if test="${t.isHot == 1}"><span class="badge badge-orange">热门</span></c:if>
                                </div>
                                <div class="topic-admin-desc">${empty t.description ? '暂无简介' : t.description}</div>
                                <c:if test="${t.status == 2 && not empty t.rejectReason}">
                                    <div class="cell-sub cell-reject">驳回理由：${t.rejectReason}</div>
                                </c:if>
                                <div class="topic-admin-meta">
                                    <span>📰 文章 ${t.articleCount == null ? 0 : t.articleCount}</span>
                                    <span>⭐ 关注 ${t.followerCount == null ? 0 : t.followerCount}</span>
                                    <span>🕒 <fmt:formatDate value="${t.createTime}" pattern="yyyy-MM-dd HH:mm"/></span>
                                </div>
                            </div>
                            <div class="topic-admin-actions">
                                <c:if test="${t.status == 0 || t.status == 2}">
                                    <a href="${pageContext.request.contextPath}/editor/topic/edit/${t.id}"
                                       class="btn btn-sm btn-primary">编辑</a>
                                    <button class="btn btn-sm btn-outline" onclick="submitTopic(${t.id}, this)">提交审核</button>
                                    <button class="btn btn-sm btn-gray" onclick="delTopic(${t.id}, this)">删除</button>
                                </c:if>
                                <c:if test="${t.status == 1}">
                                    <a href="${pageContext.request.contextPath}/editor/draft/new"
                                       class="btn btn-sm btn-outline">为话题写稿</a>
                                </c:if>
                                <c:if test="${t.status == 3}">
                                    <span class="hint">话题已被管理员禁用</span>
                                </c:if>
                            </div>
                        </div>
                    </c:forEach>
                </div>

                <div class="pagination">
                    <c:if test="${pageList.current > 1}">
                        <a href="${pageContext.request.contextPath}/editor/topics?page=${pageList.current - 1}${empty status ? '' : '&status='.concat(status)}${empty keyword ? '' : '&keyword='.concat(keyword)}" class="btn-page">上一页</a>
                    </c:if>
                    <span class="page-info">第 ${pageList.current} / ${empty pageList.pages ? 1 : pageList.pages} 页</span>
                    <c:if test="${pageList.current < pageList.pages}">
                        <a href="${pageContext.request.contextPath}/editor/topics?page=${pageList.current + 1}${empty status ? '' : '&status='.concat(status)}${empty keyword ? '' : '&keyword='.concat(keyword)}" class="btn-page">下一页</a>
                    </c:if>
                </div>
            </div>
        </div>
    </div>

    <script src="${pageContext.request.contextPath}/static/js/jquery.min.js"></script>
    <script>
        var ctx = "${pageContext.request.contextPath}";

        function doSearch() {
            var kw = $.trim($("#topicKeyword").val());
            location.href = ctx + "/editor/topics?keyword=" + encodeURIComponent(kw) + "${empty status ? '' : '&status='.concat(status)}";
        }

        function submitTopic(id, btn) {
            btn.disabled = true;
            $.post(ctx + "/editor/topic/submit/" + id, function(res) {
                alert(res.msg);
                if (res.code === 200) location.reload();
                else btn.disabled = false;
            }).fail(function() { alert("网络异常，请重试"); btn.disabled = false; });
        }

        function delTopic(id, btn) {
            if (!confirm("确认删除该话题？删除后不可恢复。")) return;
            btn.disabled = true;
            $.post(ctx + "/editor/topic/delete/" + id, function(res) {
                alert(res.msg);
                if (res.code === 200) location.reload();
                else btn.disabled = false;
            }).fail(function() { alert("网络异常，请重试"); btn.disabled = false; });
        }
    </script>
</body>
</html>
