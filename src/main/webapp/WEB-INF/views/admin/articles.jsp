<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
    <title>资讯管理 - 后台管理</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/style.css?v=28">
</head>
<body>
    <%@ include file="/WEB-INF/views/common/header.jsp" %>

    <div class="container">
        <div class="admin-layout">
            <aside class="admin-sidebar">
                <h3>后台管理</h3>
                <ul>
                    <li><a href="${pageContext.request.contextPath}/admin/dashboard">📊 数据看板</a></li>
                    <li><a href="${pageContext.request.contextPath}/admin/audit">✅ 审核中心</a></li>
                    <li><a href="${pageContext.request.contextPath}/admin/media-applies">📮 自媒体申请</a></li>
                    <li><a href="${pageContext.request.contextPath}/admin/articles" class="active">📰 资讯管理</a></li>
                    <li><a href="${pageContext.request.contextPath}/admin/categories">📂 栏目管理</a></li>
                    <li><a href="${pageContext.request.contextPath}/admin/users">👥 用户管理</a></li>
                    <li><a href="${pageContext.request.contextPath}/admin/comments">💬 评论管理</a></li>
                    <li><a href="${pageContext.request.contextPath}/admin/topics">🏷 话题管理</a></li>
                </ul>
            </aside>

            <div class="admin-main">
                <h2>📰 资讯管理</h2>

                <div class="filter-bar">
                    <select onchange="location.href='${pageContext.request.contextPath}/admin/articles?channelId=' + this.value">
                        <option value="">全部分类</option>
                        <c:forEach items="${channels}" var="c">
                            <option value="${c.id}" ${channelId == c.id ? 'selected' : ''}>${c.name}</option>
                        </c:forEach>
                    </select>
                    <input type="text" placeholder="搜索标题" onkeyup="if(event.keyCode===13)location.href='?keyword='+this.value">
                </div>

                <table class="data-table">
                    <thead>
                        <tr><th>标题</th><th>栏目</th><th>作者</th><th>发布时间</th><th>阅读</th><th>状态</th><th>操作</th></tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${pageList.records}" var="a">
                            <tr>
                                <td>
                                    <c:if test="${a.isUrgent == 1}"><span class="urgent-tag">紧急</span></c:if>
                                    ${a.title}
                                </td>
                                <td>${a.channelName}</td>
                                <td>${a.authorName}</td>
                                <td><fmt:formatDate value="${a.publishTime}" pattern="yyyy-MM-dd HH:mm"/></td>
                                <td>${a.viewCount}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${a.status == 0}"><span class="badge badge-gray">草稿</span></c:when>
                                        <c:when test="${a.status == 1}"><span class="badge badge-orange">待审核</span></c:when>
                                        <c:when test="${a.status == 2}"><span class="badge badge-green">已发布</span></c:when>
                                        <c:when test="${a.status == 3}"><span class="badge badge-red">已驳回</span></c:when>
                                        <c:when test="${a.status == 4}"><span class="badge badge-gray">已下架</span></c:when>
                                    </c:choose>
                                </td>
                                <td>
                                    <button class="btn btn-sm ${a.isTop == 1 ? 'btn-gray' : 'btn-primary'}"
                                            onclick="toggleTop(${a.id}, ${a.isTop == 1 ? 0 : 1})">
                                        ${a.isTop == 1 ? '取消置顶' : '置顶'}
                                    </button>
                                    <button class="btn btn-sm ${a.isUrgent == 1 ? 'btn-gray' : 'btn-red'}"
                                            onclick="toggleUrgent(${a.id}, ${a.isUrgent == 1 ? 0 : 1})">
                                        ${a.isUrgent == 1 ? '取消紧急' : '标为紧急'}
                                    </button>
                                    <button class="btn btn-sm btn-outline" onclick="offShelf(${a.id})">下架</button>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty pageList.records}">
                            <tr><td colspan="7" class="empty-tip">暂无资讯</td></tr>
                        </c:if>
                    </tbody>
                </table>

                <div class="pagination">
                    <c:if test="${pageList.current > 1}">
                        <a href="?page=${pageList.current - 1}&channelId=${channelId}&keyword=${keyword}" class="btn-page">上一页</a>
                    </c:if>
                    <span>第 ${pageList.current} / ${pageList.pages} 页</span>
                    <c:if test="${pageList.current < pageList.pages}">
                        <a href="?page=${pageList.current + 1}&channelId=${channelId}&keyword=${keyword}" class="btn-page">下一页</a>
                    </c:if>
                </div>
            </div>
        </div>
    </div>

    <script src="${pageContext.request.contextPath}/static/js/jquery.min.js"></script>
    <script>
        function toggleTop(id, isTop) {
            $.post("${pageContext.request.contextPath}/admin/article/top/" + id, { isTop: isTop }, function(res) {
                if (res.code === 200) location.reload(); else alert(res.msg);
            });
        }
        function toggleUrgent(id, isUrgent) {
            $.post("${pageContext.request.contextPath}/admin/article/urgent/" + id, { isUrgent: isUrgent }, function(res) {
                if (res.code === 200) location.reload(); else alert(res.msg);
            });
        }
        function offShelf(id) {
            if (!confirm("确定下架？")) return;
            $.post("${pageContext.request.contextPath}/admin/article/offShelf/" + id, function(res) {
                if (res.code === 200) location.reload(); else alert(res.msg);
            });
        }
    </script>
</body>
</html>
