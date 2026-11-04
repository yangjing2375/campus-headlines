<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
    <title>我的文章 - 校园头条自媒体</title>
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
                    <li><a href="${pageContext.request.contextPath}/editor/drafts" class="active">📝 我的文章</a></li>
                    <li><a href="${pageContext.request.contextPath}/editor/materials">🖼️ 素材库</a></li>
                    <li><a href="${pageContext.request.contextPath}/editor/topics">🏷 我的话题</a></li>
                </ul>
            </aside>

            <div class="admin-main">
                <h2>📝 我的文章</h2>

                <!-- 状态 Tab（带数量） -->
                <div class="status-tabs">
                    <a href="javascript:;" onclick="goPage(1, null)"
                       class="${empty status ? 'active' : ''}">全部 <em>${stats.all}</em></a>
                    <a href="javascript:;" onclick="goPage(1, 0)"
                       class="${status == 0 ? 'active' : ''}">草稿 <em>${stats.status0}</em></a>
                    <a href="javascript:;" onclick="goPage(1, 1)"
                       class="${status == 1 ? 'active' : ''}">待审核 <em>${stats.status1}</em></a>
                    <a href="javascript:;" onclick="goPage(1, 2)"
                       class="${status == 2 ? 'active' : ''}">已发布 <em>${stats.status2}</em></a>
                    <a href="javascript:;" onclick="goPage(1, 3)"
                       class="${status == 3 ? 'active' : ''}">已驳回 <em>${stats.status3}</em></a>
                </div>

                <!-- 多条件筛选 -->
                <form class="filter-form" id="filterForm" onsubmit="return doFilter()">
                    <select id="fChannel">
                        <option value="">全部频道</option>
                        <c:forEach items="${channels}" var="c">
                            <option value="${c.id}" ${channelId == c.id ? 'selected' : ''}>${c.name}</option>
                        </c:forEach>
                    </select>
                    <input type="date" id="fStart" value="${startDate}">
                    <span class="filter-sep">至</span>
                    <input type="date" id="fEnd" value="${endDate}">
                    <input type="text" id="fKeyword" value="${keyword}" placeholder="搜索标题关键词">
                    <button type="submit" class="btn btn-primary btn-sm">筛选</button>
                    <button type="button" class="btn btn-outline btn-sm" onclick="resetFilter()">重置</button>
                    <a href="${pageContext.request.contextPath}/editor/draft/new"
                       class="btn btn-primary btn-sm" style="margin-left:auto">+ 写文章</a>
                </form>

                <table class="data-table">
                    <thead>
                        <tr>
                            <th>标题</th><th>频道</th><th>状态</th><th>阅读</th>
                            <th>更新时间</th><th>操作</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${page.records}" var="d">
                            <tr>
                                <td>
                                    <div class="cell-title">${d.title}</div>
                                    <c:if test="${d.status == 3 and not empty d.rejectReason}">
                                        <div class="cell-reject">驳回原因：${d.rejectReason}</div>
                                    </c:if>
                                </td>
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
                                <td>${empty d.viewCount ? 0 : d.viewCount}</td>
                                <td><fmt:formatDate value="${d.updateTime}" pattern="MM-dd HH:mm"/></td>
                                <td class="cell-actions">
                                    <c:if test="${d.status == 0 || d.status == 3}">
                                        <a href="${pageContext.request.contextPath}/editor/draft/edit/${d.id}"
                                           class="btn btn-sm btn-primary">编辑</a>
                                        <button class="btn btn-sm btn-outline" onclick="submitAudit(${d.id})">提交审核</button>
                                        <button class="btn btn-sm btn-danger" onclick="delDraft(${d.id})">删除</button>
                                    </c:if>
                                    <c:if test="${d.status == 1}">
                                        <button class="btn btn-sm btn-outline" disabled>审核中</button>
                                    </c:if>
                                    <c:if test="${d.status == 2}">
                                        <a href="${pageContext.request.contextPath}/news/detail/${d.id}"
                                           target="_blank" class="btn btn-sm btn-outline">查看</a>
                                    </c:if>
                                    <c:if test="${d.status == 4}">
                                        <span class="hint">已被下架</span>
                                    </c:if>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty page.records}">
                            <tr><td colspan="6" class="empty-tip">暂无符合条件的文章</td></tr>
                        </c:if>
                    </tbody>
                </table>

                <!-- 分页 -->
                <div class="pagination">
                    <c:if test="${page.current > 1}">
                        <a href="javascript:;" onclick="goPage(${page.current - 1})" class="btn-page">上一页</a>
                    </c:if>
                    <span class="page-info">第 ${page.current} / ${empty page.pages ? 1 : page.pages} 页，共 ${page.total} 篇</span>
                    <c:if test="${page.current < page.pages}">
                        <a href="javascript:;" onclick="goPage(${page.current + 1})" class="btn-page">下一页</a>
                    </c:if>
                </div>
            </div>
        </div>
    </div>

    <script src="${pageContext.request.contextPath}/static/js/jquery.min.js"></script>
    <script>
        var ctx = "${pageContext.request.contextPath}";
        var curStatus = "${empty status ? '' : status}";

        function buildQuery(page, status) {
            var s = (status === undefined) ? curStatus : status;
            var q = "?page=" + page + "&size=10";
            if (s !== null && s !== "" && s !== undefined) q += "&status=" + s;
            var ch = $("#fChannel").val();
            if (ch) q += "&channelId=" + ch;
            var kw = $.trim($("#fKeyword").val());
            if (kw) q += "&keyword=" + encodeURIComponent(kw);
            var sd = $("#fStart").val();
            if (sd) q += "&startDate=" + sd;
            var ed = $("#fEnd").val();
            if (ed) q += "&endDate=" + ed;
            return q;
        }

        function goPage(page, status) {
            location.href = ctx + "/editor/drafts" + buildQuery(page, status);
        }

        function doFilter() {
            location.href = ctx + "/editor/drafts" + buildQuery(1);
            return false;
        }

        function resetFilter() {
            location.href = ctx + "/editor/drafts";
        }

        function submitAudit(id) {
            if (!confirm("提交审核后不可再编辑，确定提交吗？")) return;
            $.post(ctx + "/editor/draft/submit/" + id, function(res) {
                alert(res.msg);
                if (res.code === 200) location.reload();
            });
        }

        function delDraft(id) {
            if (!confirm("确定删除这篇稿件吗？删除后不可恢复")) return;
            $.post(ctx + "/editor/draft/delete/" + id, function(res) {
                alert(res.msg);
                if (res.code === 200) location.reload();
            });
        }
    </script>
</body>
</html>
