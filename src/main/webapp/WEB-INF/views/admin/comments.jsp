<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
    <title>评论管理 - 后台管理</title>
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
                    <li><a href="${pageContext.request.contextPath}/admin/articles">📰 资讯管理</a></li>
                    <li><a href="${pageContext.request.contextPath}/admin/categories">📂 栏目管理</a></li>
                    <li><a href="${pageContext.request.contextPath}/admin/users">👥 用户管理</a></li>
                    <li><a href="${pageContext.request.contextPath}/admin/comments" class="active">💬 评论管理</a></li>
                    <li><a href="${pageContext.request.contextPath}/admin/topics">🏷 话题管理</a></li>
                </ul>
            </aside>

            <div class="admin-main">
                <h2>💬 评论管理</h2>
                <p class="hint" style="margin-bottom:15px;color:#999;font-size:13px">
                    共 ${pageList.total} 条评论，可删除违规评论
                </p>

                <table class="data-table">
                    <thead>
                        <tr><th>ID</th><th>评论人</th><th>所属资讯</th><th>评论内容</th><th>时间</th><th>状态</th><th>操作</th></tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${pageList.records}" var="c">
                            <tr>
                                <td>${c.id}</td>
                                <td>${empty c.userName ? c.userId : c.userName}</td>
                                <td><a href="${pageContext.request.contextPath}/news/detail/${c.articleId}" target="_blank">${empty c.articleTitle ? '-' : c.articleTitle}</a></td>
                                <td>${c.content}</td>
                                <td><fmt:formatDate value="${c.createTime}" pattern="yyyy-MM-dd HH:mm"/></td>
                                <td>
                                    <c:choose>
                                        <c:when test="${c.status == 1}"><span class="badge badge-green">已发布</span></c:when>
                                        <c:when test="${c.status == 0}"><span class="badge badge-gray">待审核</span></c:when>
                                        <c:otherwise><span class="badge badge-red">已删除</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <button class="btn btn-sm btn-red" onclick="del(${c.id})">删除</button>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty pageList.records}">
                            <tr><td colspan="7" class="empty-tip">暂无评论</td></tr>
                        </c:if>
                    </tbody>
                </table>

                <!-- 分页 -->
                <div class="pagination">
                    <c:if test="${pageList.current > 1}">
                        <a href="${pageContext.request.contextPath}/admin/comments?page=${pageList.current - 1}&keyword=${keyword}" class="btn-page">上一页</a>
                    </c:if>
                    <span class="page-info">第 ${pageList.current} / ${empty pageList.pages ? 1 : pageList.pages} 页</span>
                    <c:if test="${pageList.current < pageList.pages}">
                        <a href="${pageContext.request.contextPath}/admin/comments?page=${pageList.current + 1}&keyword=${keyword}" class="btn-page">下一页</a>
                    </c:if>
                </div>
            </div>
        </div>
    </div>

    <script src="${pageContext.request.contextPath}/static/js/jquery.min.js"></script>
    <script>
        function del(id) {
            if (!confirm("确定删除该评论？")) return;
            $.post("${pageContext.request.contextPath}/admin/comment/delete/" + id, function(res) {
                if (res.code === 200) location.reload(); else alert(res.msg);
            });
        }
    </script>
</body>
</html>
