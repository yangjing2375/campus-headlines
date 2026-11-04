<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
    <title>栏目管理 - 后台管理</title>
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
                    <li><a href="${pageContext.request.contextPath}/admin/categories" class="active">📂 栏目管理</a></li>
                    <li><a href="${pageContext.request.contextPath}/admin/users">👥 用户管理</a></li>
                    <li><a href="${pageContext.request.contextPath}/admin/comments">💬 评论管理</a></li>
                    <li><a href="${pageContext.request.contextPath}/admin/topics">🏷 话题管理</a></li>
                </ul>
            </aside>

            <div class="admin-main">
                <h2>📂 栏目分类管理</h2>

                <!-- 新增栏目表单 -->
                <div class="panel">
                    <h3>新增栏目</h3>
                    <div class="form-row">
                        <input type="text" id="catName" placeholder="栏目名称" style="flex:1">
                        <input type="text" id="catCode" placeholder="栏目编码" style="flex:1">
                        <input type="number" id="catSort" placeholder="排序号" style="width:100px">
                        <button class="btn btn-primary" onclick="addCat()">+ 新增</button>
                    </div>
                </div>

                <!-- 栏目列表 -->
                <table class="data-table">
                    <thead>
                        <tr><th>ID</th><th>名称</th><th>编码</th><th>排序</th><th>操作</th></tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${categories}" var="c">
                            <tr>
                                <td>${c.id}</td>
                                <td><input type="text" value="${c.name}" onchange="updateCat(${c.id}, 'name', this.value)"></td>
                                <td><input type="text" value="${c.code}" onchange="updateCat(${c.id}, 'code', this.value)"></td>
                                <td>${c.sort}</td>
                                <td>
                                    <button class="btn btn-sm btn-red" onclick="delCat(${c.id})">删除</button>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <script src="${pageContext.request.contextPath}/static/js/jquery.min.js"></script>
    <script>
        var ctx = "${pageContext.request.contextPath}";
        function addCat() {
            $.ajax({
                url: ctx + "/admin/category/add",
                type: "POST",
                contentType: "application/json",
                data: JSON.stringify({
                    name: $("#catName").val(),
                    code: $("#catCode").val(),
                    sort: parseInt($("#catSort").val()) || 0
                }),
                success: function(res) {
                    if (res.code === 200) location.reload(); else alert(res.msg);
                }
            });
        }
        function delCat(id) {
            if (!confirm("确定删除该栏目？")) return;
            $.post(ctx + "/admin/category/delete/" + id, function(res) {
                if (res.code === 200) location.reload(); else alert(res.msg);
            });
        }
        function updateCat(id, field, value) {
            var data = { id: id };
            data[field] = value;
            $.ajax({
                url: ctx + "/admin/category/update",
                type: "POST",
                contentType: "application/json",
                data: JSON.stringify(data)
            });
        }
    </script>
</body>
</html>
