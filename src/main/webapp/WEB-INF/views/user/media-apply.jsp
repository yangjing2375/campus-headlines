<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
    <title>申请成为自媒体人 - 校园头条</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/style.css?v=28">
</head>
<body>
    <%@ include file="/WEB-INF/views/common/header.jsp" %>

    <div class="profile-wrap">
        <a href="${pageContext.request.contextPath}/user/profile" class="back-link">← 返回个人中心</a>

        <div class="profile-card">
            <h3 class="profile-card-title">✍️ 成为自媒体人</h3>

            <c:choose>
                <%-- 已经是自媒体人 --%>
                <c:when test="${isMedia}">
                    <div class="apply-status apply-passed">
                        <div class="apply-status-icon">✅</div>
                        <div>
                            <strong>你已经是自媒体人了</strong>
                            <p class="apply-desc">可以在自媒体工作台撰写资讯和话题。</p>
                        </div>
                    </div>
                    <a href="${pageContext.request.contextPath}/editor/index" class="btn btn-primary profile-save">进入自媒体工作台</a>
                </c:when>

                <%-- 待审核 --%>
                <c:when test="${not empty apply && apply.status == 0}">
                    <div class="apply-status apply-pending">
                        <div class="apply-status-icon">⏳</div>
                        <div>
                            <strong>申请审核中</strong>
                            <p class="apply-desc">提交时间：<fmt:formatDate value="${apply.createTime}" pattern="yyyy-MM-dd HH:mm"/>，管理员审核后可在此查看结果。</p>
                        </div>
                    </div>
                    <div class="apply-detail">
                        <div class="apply-detail-row"><label>申请理由</label><span>${apply.reason}</span></div>
                        <c:if test="${not empty apply.intro}">
                            <div class="apply-detail-row"><label>擅长领域</label><span>${apply.intro}</span></div>
                        </c:if>
                        <c:if test="${not empty apply.contact}">
                            <div class="apply-detail-row"><label>联系方式</label><span>${apply.contact}</span></div>
                        </c:if>
                    </div>
                </c:when>

                <%-- 其他情况：未申请过 或 被驳回后重新申请 --%>
                <c:otherwise>
                    <c:if test="${not empty apply && apply.status == 2}">
                        <div class="apply-status apply-rejected">
                            <div class="apply-status-icon">✖</div>
                            <div>
                                <strong>上次申请未通过</strong>
                                <p class="apply-desc">驳回理由：${apply.rejectReason}</p>
                                <p class="apply-desc">审核时间：<fmt:formatDate value="${apply.auditTime}" pattern="yyyy-MM-dd HH:mm"/></p>
                            </div>
                        </div>
                    </c:if>

                    <p class="apply-intro">
                        自媒体人可以发布资讯与话题。提交申请后由管理员审核，通过后你的账号将升级为自媒体人（需重新登录生效）。
                    </p>

                    <div class="profile-row">
                        <label>申请理由 <span class="req">*</span></label>
                        <textarea id="reason" rows="4" maxlength="500" placeholder="说明你为什么想成为自媒体人，例如：长期关注校园活动，希望发布原创报道"></textarea>
                    </div>
                    <div class="profile-row">
                        <label>擅长领域</label>
                        <input type="text" id="intro" maxlength="100" placeholder="如：校园活动摄影、考研经验分享">
                    </div>
                    <div class="profile-row">
                        <label>联系方式</label>
                        <input type="text" id="contact" maxlength="100" placeholder="微信号 / 手机号（便于管理员联系）">
                    </div>

                    <button class="btn btn-primary profile-save" onclick="submitApply()">提交申请</button>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <script src="${pageContext.request.contextPath}/static/js/jquery.min.js"></script>
    <script>
        var ctx = "${pageContext.request.contextPath}";

        function submitApply() {
            var reason = $.trim($("#reason").val());
            if (!reason) { alert("请填写申请理由"); return; }
            $.ajax({
                url: ctx + "/user/media/apply",
                type: "POST",
                contentType: "application/json",
                data: JSON.stringify({
                    reason: reason,
                    intro: $.trim($("#intro").val()),
                    contact: $.trim($("#contact").val())
                }),
                success: function(res) {
                    if (res.code === 401) { alert("请先登录"); location.href = ctx + "/user/login"; return; }
                    alert(res.msg);
                    if (res.code === 200) location.reload();
                }
            });
        }
    </script>
</body>
</html>
