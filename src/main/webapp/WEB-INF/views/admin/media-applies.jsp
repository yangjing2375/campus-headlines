<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
    <title>自媒体申请 - 后台管理</title>
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
                    <li><a href="${pageContext.request.contextPath}/admin/articles">📰 资讯管理</a></li>
                    <li><a href="${pageContext.request.contextPath}/admin/categories">📂 栏目管理</a></li>
                    <li><a href="${pageContext.request.contextPath}/admin/users">👥 用户管理</a></li>
                    <li><a href="${pageContext.request.contextPath}/admin/media-applies" class="active">📮 自媒体申请</a></li>
                    <li><a href="${pageContext.request.contextPath}/admin/comments">💬 评论管理</a></li>
                    <li><a href="${pageContext.request.contextPath}/admin/topics">🏷 话题管理</a></li>
                </ul>
            </aside>

            <div class="admin-main">
                <h2>📮 自媒体人申请</h2>

                <div class="status-tabs">
                    <a href="${pageContext.request.contextPath}/admin/media-applies" class="${empty status ? 'active' : ''}">全部</a>
                    <a href="${pageContext.request.contextPath}/admin/media-applies?status=0" class="${status == 0 ? 'active' : ''}">待审核 <b>${pendingApply}</b></a>
                    <a href="${pageContext.request.contextPath}/admin/media-applies?status=1" class="${status == 1 ? 'active' : ''}">已通过</a>
                    <a href="${pageContext.request.contextPath}/admin/media-applies?status=2" class="${status == 2 ? 'active' : ''}">已驳回</a>
                </div>

                <table class="data-table">
                    <thead>
                        <tr>
                            <th style="width:60px">ID</th>
                            <th style="width:140px">申请人</th>
                            <th style="width:120px">院系</th>
                            <th>申请理由</th>
                            <th style="width:130px">申请时间</th>
                            <th style="width:90px">状态</th>
                            <th style="width:150px">操作</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${pageList.records}" var="a">
                            <tr id="apply-row-${a.id}">
                                <td>${a.id}</td>
                                <td>
                                    ${empty a.userName ? a.userId : a.userName}
                                    <c:if test="${not empty a.userPhone}">
                                        <div class="cell-sub">${a.userPhone}</div>
                                    </c:if>
                                </td>
                                <td>${empty a.userCollege ? '-' : a.userCollege}</td>
                                <td>
                                    <div class="apply-reason-cell">${a.reason}</div>
                                    <c:if test="${not empty a.intro}">
                                        <div class="cell-sub">擅长：${a.intro}</div>
                                    </c:if>
                                    <c:if test="${not empty a.contact}">
                                        <div class="cell-sub">联系：${a.contact}</div>
                                    </c:if>
                                    <c:if test="${a.status == 2 && not empty a.rejectReason}">
                                        <div class="cell-sub cell-reject">驳回理由：${a.rejectReason}</div>
                                    </c:if>
                                </td>
                                <td><fmt:formatDate value="${a.createTime}" pattern="yyyy-MM-dd HH:mm"/></td>
                                <td>
                                    <c:choose>
                                        <c:when test="${a.status == 0}"><span class="badge badge-gray">待审核</span></c:when>
                                        <c:when test="${a.status == 1}"><span class="badge badge-green">已通过</span></c:when>
                                        <c:otherwise><span class="badge badge-red">已驳回</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${a.status == 0}">
                                            <button class="btn btn-sm btn-primary" onclick="approve(${a.id}, this)">通过</button>
                                            <button class="btn btn-sm btn-red" onclick="openReject(${a.id})">驳回</button>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="cell-sub">
                                                <fmt:formatDate value="${a.auditTime}" pattern="MM-dd HH:mm"/>
                                            </span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty pageList.records}">
                            <tr><td colspan="7" class="empty-tip">暂无申请记录</td></tr>
                        </c:if>
                    </tbody>
                </table>

                <div class="pagination">
                    <c:if test="${pageList.current > 1}">
                        <a href="${pageContext.request.contextPath}/admin/media-applies?page=${pageList.current - 1}${empty status ? '' : '&status='.concat(status)}" class="btn-page">上一页</a>
                    </c:if>
                    <span class="page-info">第 ${pageList.current} / ${empty pageList.pages ? 1 : pageList.pages} 页</span>
                    <c:if test="${pageList.current < pageList.pages}">
                        <a href="${pageContext.request.contextPath}/admin/media-applies?page=${pageList.current + 1}${empty status ? '' : '&status='.concat(status)}" class="btn-page">下一页</a>
                    </c:if>
                </div>
            </div>
        </div>
    </div>

    <!-- 驳回理由弹层 -->
    <div class="picker-mask" id="rejectMask">
        <div class="picker-dialog" style="max-width:460px">
            <div class="picker-head">
                <span>驳回申请</span>
                <button type="button" class="picker-close" onclick="closeReject()">×</button>
            </div>
            <div class="picker-body" style="padding:18px">
                <label class="reject-label">驳回理由 <span class="req">*</span>（申请人可以看到）</label>
                <textarea id="rejectReason" rows="4" maxlength="255" placeholder="例如：申请理由过于简单，请补充你的创作方向和过往作品"></textarea>
            </div>
            <div class="reject-actions">
                <button class="btn btn-outline" onclick="closeReject()">取消</button>
                <button class="btn btn-red" onclick="doReject()">确认驳回</button>
            </div>
        </div>
    </div>

    <script src="${pageContext.request.contextPath}/static/js/jquery.min.js"></script>
    <script>
        var ctx = "${pageContext.request.contextPath}";
        var rejectId = null;

        function approve(id, btn) {
            if (!confirm("确认通过？通过后该用户将升级为自媒体人。")) return;
            btn.disabled = true;
            $.post(ctx + "/admin/media/approve/" + id, function(res) {
                alert(res.msg);
                if (res.code === 200) location.reload();
                else btn.disabled = false;
            });
        }

        function openReject(id) {
            rejectId = id;
            $("#rejectReason").val("");
            $("#rejectMask").addClass("show");
        }

        function closeReject() {
            rejectId = null;
            $("#rejectMask").removeClass("show");
        }

        function doReject() {
            var reason = $.trim($("#rejectReason").val());
            if (!reason) { alert("请填写驳回理由"); return; }
            $.post(ctx + "/admin/media/reject/" + rejectId, { reason: reason }, function(res) {
                alert(res.msg);
                if (res.code === 200) location.reload();
            });
        }
    </script>
</body>
</html>
