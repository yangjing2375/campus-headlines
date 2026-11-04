<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
    <title>审核中心 - 后台管理</title>
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
                    <li><a href="${pageContext.request.contextPath}/admin/audit" class="active">✅ 审核中心</a></li>
                    <li><a href="${pageContext.request.contextPath}/admin/media-applies">📮 自媒体申请</a></li>
                    <li><a href="${pageContext.request.contextPath}/admin/articles">📰 资讯管理</a></li>
                    <li><a href="${pageContext.request.contextPath}/admin/categories">📂 栏目管理</a></li>
                    <li><a href="${pageContext.request.contextPath}/admin/users">👥 用户管理</a></li>
                    <li><a href="${pageContext.request.contextPath}/admin/comments">💬 评论管理</a></li>
                    <li><a href="${pageContext.request.contextPath}/admin/topics">🏷 话题管理</a></li>
                </ul>
            </aside>

            <div class="admin-main">
                <h2>✅ 审核中心</h2>

                <!-- 状态筛选 -->
                <div class="status-tabs">
                    <a href="javascript:;" onclick="goFilter(null)" class="${empty status ? 'active' : ''}">全部</a>
                    <a href="javascript:;" onclick="goFilter(1)" class="${status == 1 ? 'active' : ''}">待审核</a>
                    <a href="javascript:;" onclick="goFilter(2)" class="${status == 2 ? 'active' : ''}">已通过</a>
                    <a href="javascript:;" onclick="goFilter(3)" class="${status == 3 ? 'active' : ''}">已驳回</a>
                </div>

                <table class="data-table">
                    <thead>
                        <tr><th>标题</th><th>栏目</th><th>作者</th><th>来源</th><th>状态</th><th>提交时间</th><th>操作</th></tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${pageList.records}" var="d">
                            <tr>
                                <td class="cell-title">${d.title}</td>
                                <td>${d.channelName}</td>
                                <td>${d.authorName}</td>
                                <td>${empty d.source ? '-' : d.source}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${d.status == 1}"><span class="badge badge-orange">待审核</span></c:when>
                                        <c:when test="${d.status == 2}"><span class="badge badge-green">已通过</span></c:when>
                                        <c:when test="${d.status == 3}"><span class="badge badge-red">驳回</span></c:when>
                                    </c:choose>
                                </td>
                                <td><fmt:formatDate value="${d.createTime}" pattern="MM-dd HH:mm"/></td>
                                <td class="cell-actions">
                                    <button class="btn btn-sm btn-outline" onclick="viewDetail(${d.id})">👁 查看</button>
                                    <c:if test="${d.status == 1}">
                                        <button class="btn btn-sm btn-green" onclick="pass(${d.id})">✅ 通过</button>
                                        <button class="btn btn-sm btn-red" onclick="reject(${d.id})">❌ 驳回</button>
                                    </c:if>
                                    <c:if test="${d.status == 3}">
                                        <span class="cell-reject" title="驳回原因">${d.rejectReason}</span>
                                    </c:if>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty pageList.records}">
                            <tr><td colspan="7" class="empty-tip">暂无稿件</td></tr>
                        </c:if>
                    </tbody>
                </table>

                <div class="pagination">
                    <c:if test="${pageList.current > 1}">
                        <a href="javascript:;" onclick="goPage(${pageList.current - 1})" class="btn-page">上一页</a>
                    </c:if>
                    <span class="page-info">第 ${pageList.current} / ${empty pageList.pages ? 1 : pageList.pages} 页，共 ${pageList.total} 篇</span>
                    <c:if test="${pageList.current < pageList.pages}">
                        <a href="javascript:;" onclick="goPage(${pageList.current + 1})" class="btn-page">下一页</a>
                    </c:if>
                </div>
            </div>
        </div>
    </div>

    <!-- 文章详情弹层 -->
    <div class="picker-mask" id="detailMask" onclick="closeDetail(event)">
        <div class="detail-dialog" id="detailDialog"></div>
    </div>

    <script src="${pageContext.request.contextPath}/static/js/jquery.min.js"></script>
    <script>
        var ctx = "${pageContext.request.contextPath}";
        var curStatus = "${empty status ? '' : status}";

        function goFilter(s) {
            var q = "?page=1";
            if (s !== null && s !== undefined) q += "&status=" + s;
            if ("${keyword}") q += "&keyword=" + encodeURIComponent("${keyword}");
            location.href = ctx + "/admin/audit" + q;
        }
        function goPage(p) {
            var q = "?page=" + p;
            if (curStatus) q += "&status=" + curStatus;
            location.href = ctx + "/admin/audit" + q;
        }

        function viewDetail(id) {
            $.get(ctx + "/admin/article/detail/" + id, function(res) {
                if (res.code !== 200) { alert(res.msg); return; }
                var a = res.data;
                var statusTxt = a.status == 1 ? '<span class="badge badge-orange">待审核</span>'
                              : a.status == 2 ? '<span class="badge badge-green">已通过</span>'
                              : a.status == 3 ? '<span class="badge badge-red">已驳回</span>'
                              : '<span class="badge badge-gray">草稿</span>';
                var rejectTxt = a.status == 3 && a.rejectReason
                    ? '<div class="detail-reject">驳回原因：' + a.rejectReason + '</div>' : '';
                // 封面图：已是完整 URL 则直接用，是相对路径才拼 ctx
                var coverUrl = '';
                if (a.cover) {
                    coverUrl = /^https?:\/\//.test(a.cover) ? a.cover : (ctx + a.cover);
                }
                var coverHtml = coverUrl ? '<img src="' + coverUrl + '" class="detail-cover">' : '';
                // 视频预览
                var videoHtml = '';
                if (a.videoUrl) {
                    var vUrl = /^https?:\/\//.test(a.videoUrl) ? a.videoUrl : (ctx + a.videoUrl);
                    videoHtml = '<video src="' + vUrl + '" controls preload="metadata" class="detail-video"></video>';
                }
                // 封面与视频统一放进媒体容器，保持与标题/正文一致的左右留白和间距
                var mediaHtml = (coverHtml || videoHtml)
                    ? '<div class="detail-media">' + coverHtml + videoHtml + '</div>' : '';
                // 时间戳转日期
                var timeTxt = '-';
                if (a.createTime) {
                    var d = new Date(a.createTime);
                    timeTxt = d.getFullYear() + '-' + String(d.getMonth()+1).padStart(2,'0') + '-'
                            + String(d.getDate()).padStart(2,'0') + ' '
                            + String(d.getHours()).padStart(2,'0') + ':' + String(d.getMinutes()).padStart(2,'0');
                }
                var contentHtml = a.content || '<p class="empty-tip">（无正文内容）</p>';

                var html =
                    '<div class="detail-head">' +
                        '<h3>' + a.title + '</h3>' +
                        '<div class="detail-meta">' +
                            '<span>📂 ' + (a.channelName || '-') + '</span>' +
                            '<span>✍️ ' + (a.authorName || '-') + '</span>' +
                            '<span>📰 ' + (a.source || '-') + '</span>' +
                            '<span>📅 ' + timeTxt + '</span>' +
                            '<span>' + statusTxt + '</span>' +
                        '</div>' +
                    '</div>' +
                    rejectTxt +
                    mediaHtml +
                    '<div class="detail-body">' + contentHtml + '</div>' +
                    '<div class="detail-actions">' +
                        '<a href="' + ctx + '/news/detail/' + a.id + '" target="_blank" class="btn btn-outline">🔗 在新窗口查看</a>' +
                        '<button class="btn btn-primary" onclick="closeDetail()">关闭</button>' +
                    '</div>';
                $("#detailDialog").html(html);
                $("#detailMask").addClass("show");
            });
        }
        function closeDetail(e) {
            if (e && e.target !== e.currentTarget) return;
            $("#detailMask").removeClass("show");
        }

        function pass(id) {
            if (!confirm("确认审核通过？通过后文章将出现在用户端对应频道")) return;
            $.post(ctx + "/admin/audit/pass/" + id, function(res) {
                alert(res.msg);
                if (res.code === 200) location.reload();
            });
        }
        function reject(id) {
            var reason = prompt("请输入驳回理由：");
            if (!reason) return;
            $.post(ctx + "/admin/audit/reject/" + id, { reason: reason }, function(res) {
                alert(res.msg);
                if (res.code === 200) location.reload();
            });
        }
    </script>
</body>
</html>
