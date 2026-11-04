<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
    <title>用户管理 - 后台管理</title>
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
                    <li><a href="${pageContext.request.contextPath}/admin/users" class="active">👥 用户管理</a></li>
                    <li><a href="${pageContext.request.contextPath}/admin/comments">💬 评论管理</a></li>
                    <li><a href="${pageContext.request.contextPath}/admin/topics">🏷 话题管理</a></li>
                </ul>
            </aside>

            <div class="admin-main">
                <h2>👥 用户管理</h2>

                <div class="filter-bar">
                    <input type="text" placeholder="搜索用户名/昵称" onkeyup="if(event.keyCode===13)location.href='?keyword='+this.value">
                </div>

                <table class="data-table">
                    <thead>
                        <tr><th>ID</th><th>用户名</th><th>昵称</th><th>院系</th><th>角色</th><th>状态</th><th>注册时间</th><th>操作</th></tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${pageList.records}" var="u">
                            <tr>
                                <td>${u.id}</td>
                                <td>${u.username}</td>
                                <td>${u.nickname}</td>
                                <td>${u.college}</td>
                                <td>
                                    <select onchange="updateRole(${u.id}, this.value)" style="padding:4px;border-radius:4px;border:1px solid #ddd;">
                                        <option value="USER" ${u.role == 'USER' ? 'selected' : ''}>普通用户</option>
                                        <option value="MEDIA" ${u.role == 'MEDIA' ? 'selected' : ''}>自媒体人</option>
                                        <option value="ADMIN" ${u.role == 'ADMIN' ? 'selected' : ''}>管理员</option>
                                    </select>
                                </td>
                                <td>
                                    ${u.status == 1 ? '✅ 正常' : '🚫 禁用'}
                                </td>
                                <td><fmt:formatDate value="${u.createTime}" pattern="yyyy-MM-dd"/></td>
                                <td>
                                    <c:choose>
                                        <c:when test="${u.status == 1}">
                                            <button class="btn btn-sm btn-red" onclick="toggleStatus(${u.id}, 0)">禁用</button>
                                        </c:when>
                                        <c:otherwise>
                                            <button class="btn btn-sm btn-green" onclick="toggleStatus(${u.id}, 1)">解禁</button>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>

                <div class="pagination">
                    <c:if test="${pageList.current > 1}">
                        <a href="?page=${pageList.current - 1}" class="btn-page">上一页</a>
                    </c:if>
                    <span>第 ${pageList.current} / ${pageList.pages} 页</span>
                    <c:if test="${pageList.current < pageList.pages}">
                        <a href="?page=${pageList.current + 1}" class="btn-page">下一页</a>
                    </c:if>
                </div>
            </div>
        </div>
    </div>

    <script src="${pageContext.request.contextPath}/static/js/jquery.min.js"></script>
    <script>
        function toggleStatus(id, status) {
            if (!confirm(status == 1 ? "确定解禁？" : "确定禁用该用户？")) return;
            $.post("${pageContext.request.contextPath}/admin/user/status/" + id, { status: status }, function(res) {
                if (res.code === 200) location.reload(); else alert(res.msg);
            });
        }
        function updateRole(id, role) {
            if (!confirm("确定将该用户角色改为 " + role + " ？")) {
                location.reload();
                return;
            }
            $.post("${pageContext.request.contextPath}/admin/user/role/" + id, { role: role }, function(res) {
                if (res.code !== 200) { alert(res.msg); location.reload(); }
            });
        }
    </script>
</body>
</html>
