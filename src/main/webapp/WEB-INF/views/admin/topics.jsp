<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
    <title>话题管理 - 后台管理</title>
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
                    <li><a href="${pageContext.request.contextPath}/admin/comments">💬 评论管理</a></li>
                    <li><a href="${pageContext.request.contextPath}/admin/topics" class="active">🏷 话题管理</a></li>
                </ul>
            </aside>

            <div class="admin-main">
                <div class="page-head">
                    <h2>🏷 话题管理 <span class="hint">共 ${topicCount} 个话题，待审核 ${pendingTopicCount} 个</span></h2>
                    <button class="btn btn-primary" onclick="openTopicForm()">＋ 新建话题</button>
                </div>

                <div class="status-tabs">
                    <a href="${pageContext.request.contextPath}/admin/topics" class="${empty status ? 'active' : ''}">全部</a>
                    <a href="${pageContext.request.contextPath}/admin/topics?status=0" class="${status == 0 ? 'active' : ''}">待审核 <b>${pendingTopicCount}</b></a>
                    <a href="${pageContext.request.contextPath}/admin/topics?status=1" class="${status == 1 ? 'active' : ''}">已上线</a>
                    <a href="${pageContext.request.contextPath}/admin/topics?status=2" class="${status == 2 ? 'active' : ''}">已驳回</a>
                    <a href="${pageContext.request.contextPath}/admin/topics?status=3" class="${status == 3 ? 'active' : ''}">已禁用</a>
                </div>

                <div class="filter-bar">
                    <input type="text" id="topicKeyword" placeholder="搜索话题名称 / 简介" value="${keyword}"
                           onkeyup="if(event.keyCode===13)doSearch()">
                    <button class="btn btn-sm btn-primary" onclick="doSearch()">搜索</button>
                    <c:if test="${not empty keyword}">
                        <a class="btn btn-sm btn-outline" href="${pageContext.request.contextPath}/admin/topics${empty status ? '' : '?status='.concat(status)}">清空</a>
                    </c:if>
                </div>

                <table class="data-table">
                    <thead>
                        <tr>
                            <th style="width:56px">ID</th>
                            <th>话题</th>
                            <th style="width:110px">创建人</th>
                            <th style="width:70px">文章数</th>
                            <th style="width:70px">关注数</th>
                            <th style="width:80px">热门</th>
                            <th style="width:86px">状态</th>
                            <th style="width:200px">操作</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${pageList.records}" var="t">
                            <tr id="topic-row-${t.id}">
                                <td>${t.id}</td>
                                <td>
                                    <a class="cell-title" href="${pageContext.request.contextPath}/topic/detail/${t.id}" target="_blank">#${t.title}</a>
                                    <c:if test="${not empty t.description}">
                                        <div class="cell-sub">${t.description}</div>
                                    </c:if>
                                    <c:if test="${t.status == 2 && not empty t.rejectReason}">
                                        <div class="cell-sub cell-reject">驳回理由：${t.rejectReason}</div>
                                    </c:if>
                                </td>
                                <td>${empty t.creatorName ? '-' : t.creatorName}</td>
                                <td>${t.articleCount == null ? 0 : t.articleCount}</td>
                                <td>${t.followerCount == null ? 0 : t.followerCount}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${t.isHot == 1}"><span class="badge badge-orange">热门</span></c:when>
                                        <c:otherwise><span class="cell-sub">-</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${t.status == 0}"><span class="badge badge-gray">待审核</span></c:when>
                                        <c:when test="${t.status == 1}"><span class="badge badge-green">已上线</span></c:when>
                                        <c:when test="${t.status == 2}"><span class="badge badge-red">已驳回</span></c:when>
                                        <c:otherwise><span class="badge badge-gray">已禁用</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <c:if test="${t.status == 0}">
                                        <button class="btn btn-sm btn-primary" onclick="passTopic(${t.id}, this)">通过</button>
                                        <button class="btn btn-sm btn-red" onclick="openReject(${t.id})">驳回</button>
                                    </c:if>
                                    <c:if test="${t.status == 1}">
                                        <button class="btn btn-sm ${t.isHot == 1 ? 'btn-gray' : 'btn-primary'}"
                                                onclick="setHot(${t.id}, ${t.isHot == 1 ? 0 : 1})">
                                            ${t.isHot == 1 ? '取消热门' : '设为热门'}
                                        </button>
                                        <button class="btn btn-sm btn-outline" onclick="changeStatus(${t.id}, 3)">禁用</button>
                                    </c:if>
                                    <c:if test="${t.status == 2 || t.status == 3}">
                                        <button class="btn btn-sm btn-primary" onclick="changeStatus(${t.id}, 1)">上线</button>
                                    </c:if>
                                    <button class="btn btn-sm btn-gray" onclick="delTopic(${t.id}, this)">删除</button>
                                    <button class="btn btn-sm btn-outline" onclick="openTopicForm(${t.id})">编辑</button>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty pageList.records}">
                            <tr><td colspan="8" class="empty-tip">暂无话题</td></tr>
                        </c:if>
                    </tbody>
                </table>

                <div class="pagination">
                    <c:if test="${pageList.current > 1}">
                        <a href="${pageContext.request.contextPath}/admin/topics?page=${pageList.current - 1}${empty status ? '' : '&status='.concat(status)}${empty keyword ? '' : '&keyword='.concat(keyword)}" class="btn-page">上一页</a>
                    </c:if>
                    <span class="page-info">第 ${pageList.current} / ${empty pageList.pages ? 1 : pageList.pages} 页</span>
                    <c:if test="${pageList.current < pageList.pages}">
                        <a href="${pageContext.request.contextPath}/admin/topics?page=${pageList.current + 1}${empty status ? '' : '&status='.concat(status)}${empty keyword ? '' : '&keyword='.concat(keyword)}" class="btn-page">下一页</a>
                    </c:if>
                </div>
            </div>
        </div>
    </div>

    <!-- 驳回理由弹层 -->
    <div class="picker-mask" id="rejectMask">
        <div class="picker-dialog" style="max-width:460px">
            <div class="picker-head">
                <span>驳回话题</span>
                <button type="button" class="picker-close" onclick="closeReject()">×</button>
            </div>
            <div class="picker-body" style="padding:18px">
                <label class="reject-label">驳回理由 <span class="req">*</span>（创建人可以看到）</label>
                <textarea id="rejectReason" rows="4" maxlength="500" placeholder="例如：话题名称与已有的「开学季」重复，请调整后重新提交"></textarea>
            </div>
            <div class="reject-actions">
                <button class="btn btn-outline" onclick="closeReject()">取消</button>
                <button class="btn btn-red" onclick="doReject()">确认驳回</button>
            </div>
        </div>
    </div>

    <!-- 新建 / 编辑话题弹层 -->
    <div class="picker-mask" id="topicFormMask">
        <div class="picker-dialog" style="max-width:520px">
            <div class="picker-head">
                <span id="topicFormTitle">新建话题</span>
                <button type="button" class="picker-close" onclick="closeTopicForm()">×</button>
            </div>
            <div class="picker-body" style="padding:18px">
                <div class="form-group">
                    <label class="reject-label">话题名称 <span class="req">*</span></label>
                    <input type="text" id="formTitle" maxlength="40" placeholder="如：开学季 / 人工智能与校园">
                </div>
                <div class="form-group">
                    <label class="reject-label">话题简介</label>
                    <textarea id="formDesc" rows="3" maxlength="200" placeholder="简单介绍话题内容范围"></textarea>
                </div>
                <div class="form-group">
                    <label class="reject-label">封面图地址（可选）</label>
                    <input type="text" id="formCover" placeholder="如 /static/uploads/material/xxx.jpg">
                </div>
            </div>
            <div class="reject-actions">
                <button class="btn btn-outline" onclick="closeTopicForm()">取消</button>
                <button class="btn btn-primary" onclick="saveTopic()">保存</button>
            </div>
        </div>
    </div>

    <script src="${pageContext.request.contextPath}/static/js/jquery.min.js"></script>
    <script>
        var ctx = "${pageContext.request.contextPath}";
        var rejectId = null;
        var editTopicId = null;

        function openTopicForm(id) {
            editTopicId = id || null;
            $("#topicFormTitle").text(id ? "编辑话题" : "新建话题");
            $("#formTitle").val("");
            $("#formDesc").val("");
            $("#formCover").val("");
            if (id) {
                $.get(ctx + "/admin/topic/detail/" + id, function(res) {
                    if (res.code !== 200) { alert(res.msg); return; }
                    $("#formTitle").val(res.data.title);
                    $("#formDesc").val(res.data.description || "");
                    $("#formCover").val(res.data.cover || "");
                    $("#topicFormMask").addClass("show");
                });
            } else {
                $("#topicFormMask").addClass("show");
            }
        }

        function closeTopicForm() {
            $("#topicFormMask").removeClass("show");
            editTopicId = null;
        }

        function saveTopic() {
            var title = $.trim($("#formTitle").val());
            if (!title) { alert("请填写话题名称"); return; }
            var payload = {
                id: editTopicId,
                title: title,
                description: $.trim($("#formDesc").val()),
                cover: $.trim($("#formCover").val())
            };
            $.ajax({
                url: ctx + "/admin/topic/save",
                type: "POST", contentType: "application/json",
                data: JSON.stringify(payload),
                success: function(res) {
                    alert(res.msg);
                    if (res.code === 200) location.reload();
                },
                error: function() { alert("保存失败，请重试"); }
            });
        }

        function doSearch() {
            var kw = $.trim($("#topicKeyword").val());
            var url = ctx + "/admin/topics?keyword=" + encodeURIComponent(kw) + "${empty status ? '' : '&status='.concat(status)}";
            location.href = url;
        }

        function passTopic(id, btn) {
            if (!confirm("确认通过该话题？通过后话题立即上线，用户可浏览与关注。")) return;
            btn.disabled = true;
            $.post(ctx + "/admin/topic/pass/" + id, function(res) {
                alert(res.msg);
                if (res.code === 200) location.reload();
                else btn.disabled = false;
            }).fail(function() { alert("网络异常，请重试"); btn.disabled = false; });
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
            $.post(ctx + "/admin/topic/reject/" + rejectId, { reason: reason }, function(res) {
                alert(res.msg);
                if (res.code === 200) location.reload();
            });
        }

        function setHot(id, isHot) {
            $.post(ctx + "/admin/topic/hot/" + id, { isHot: isHot }, function(res) {
                alert(res.msg);
                if (res.code === 200) location.reload();
            });
        }

        function changeStatus(id, status) {
            var tip = status === 1 ? "确认重新上线该话题？" : "确认禁用该话题？禁用后用户端将不再展示。";
            if (!confirm(tip)) return;
            $.post(ctx + "/admin/topic/status/" + id, { status: status }, function(res) {
                alert(res.msg);
                if (res.code === 200) location.reload();
            });
        }

        function delTopic(id, btn) {
            if (!confirm("确认删除该话题？已有文章引用的话题无法删除。")) return;
            btn.disabled = true;
            $.post(ctx + "/admin/topic/delete/" + id, function(res) {
                alert(res.msg);
                if (res.code === 200) location.reload();
                else btn.disabled = false;
            }).fail(function() { alert("网络异常，请重试"); btn.disabled = false; });
        }
    </script>
</body>
</html>
