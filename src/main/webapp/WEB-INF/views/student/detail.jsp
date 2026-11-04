<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
    <title>${article.title} - 校园头条</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/style.css?v=28">
</head>
<body>
    <%@ include file="/WEB-INF/views/common/header.jsp" %>

    <div class="container">
        <div class="detail-page">
            <article class="article-detail">
                <header class="article-header">
                    <h1 class="article-title-full">
                        <c:if test="${article.isUrgent == 1}">
                            <span class="urgent-tag">紧急</span>
                        </c:if>
                        ${article.title}
                    </h1>
                    <div class="article-meta">
                        <span class="cat-tag">${article.channelName}</span>
                        <c:if test="${not empty article.topicName}">
                            <a class="topic-pill" href="${pageContext.request.contextPath}/topic/detail/${article.topicId}"># ${article.topicName}</a>
                        </c:if>
                        <span>来源：${article.source}</span>
                        <span>作者：${article.authorName}</span>
                        <span>时间：<fmt:formatDate value="${article.publishTime}" pattern="yyyy-MM-dd HH:mm"/></span>
                        <span class="read-count-detail">👁 ${article.viewCount}</span>
                        <span>👍 ${article.likeCount}</span>
                        <span>⭐ ${article.favoriteCount}</span>
                    </div>
                </header>

                <c:if test="${not empty article.videoUrl}">
                    <c:if test="${not empty article.cover}">
                        <c:set var="videoPoster" value="${fn:startsWith(article.cover, 'http') ? article.cover : pageContext.request.contextPath.concat(article.cover)}"/>
                    </c:if>
                    <div class="article-video">
                        <video src="${fn:startsWith(article.videoUrl, 'http') ? article.videoUrl : pageContext.request.contextPath.concat(article.videoUrl)}"
                               controls preload="metadata" <c:if test="${not empty videoPoster}">poster="${videoPoster}"</c:if>></video>
                    </div>
                </c:if>
                <c:if test="${empty article.videoUrl && not empty article.cover}">
                    <div class="article-cover">
                        <img src="${fn:startsWith(article.cover, 'http') ? article.cover : pageContext.request.contextPath.concat(article.cover)}" alt="${article.title}"
                             onerror="this.src='${pageContext.request.contextPath}/static/img/no-cover.svg'">
                    </div>
                </c:if>

                <div class="article-content">
                    ${article.content}
                </div>

                <div class="article-actions">
                    <button id="btnLike" class="btn-like ${liked ? 'liked' : ''}">
                        <span class="like-icon">${liked ? '❤️' : '🤍'}</span>
                        点赞 <span id="likeCount">${article.likeCount}</span>
                    </button>
                    <button id="btnFav" class="btn-fav ${favorited ? 'faved' : ''}">
                        <span class="fav-icon">${favorited ? '⭐' : '☆'}</span>
                        <span id="favLabel">${favorited ? '已收藏' : '收藏'}</span>
                        <span id="favCount">${article.favoriteCount}</span>
                    </button>
                </div>
            </article>

            <!-- 评论区 -->
            <section class="comment-section">
                <h3>💬 评论区 (${article.commentCount})</h3>

                <div class="comment-input">
                    <div class="reply-tip" id="replyTip" style="display:none">
                        回复 <b id="replyTargetName"></b>
                        <a href="javascript:void(0)" id="cancelReply">取消回复</a>
                    </div>
                    <textarea id="commentContent" placeholder="说点什么吧..."></textarea>
                    <button id="btnSubmitComment" class="btn btn-primary">发表评论</button>
                </div>

                <div class="comment-list">
                    <c:forEach items="${comments}" var="c">
                        <div class="comment-item">
                            <div class="comment-head">
                                <span class="comment-user">${c.userName}</span>
                                <span class="comment-time"><fmt:formatDate value="${c.createTime}" pattern="yyyy-MM-dd HH:mm"/></span>
                            </div>
                            <div class="comment-text">${c.content}</div>
                            <div class="comment-ops">
                                <a href="javascript:void(0)" class="op-like ${c.liked ? 'liked' : ''}" data-id="${c.id}">
                                    <span class="op-like-icon">${c.liked ? '❤️' : '🤍'}</span>
                                    <span class="op-like-count">${c.likeCount == null ? 0 : c.likeCount}</span>
                                </a>
                                <a href="javascript:void(0)" class="op-reply" data-id="${c.id}" data-name="${c.userName}">回复</a>
                                <c:if test="${sessionScope.loginUser != null && (sessionScope.loginUser.id == c.userId || sessionScope.loginUser.role == 'ADMIN')}">
                                    <a href="javascript:void(0)" class="op-delete" data-id="${c.id}">删除</a>
                                </c:if>
                            </div>

                            <!-- 楼中楼回复 -->
                            <c:if test="${not empty c.replies}">
                                <div class="reply-list">
                                    <c:forEach items="${c.replies}" var="r">
                                        <div class="reply-item">
                                            <div class="comment-head">
                                                <span class="comment-user">${r.userName}</span>
                                                <c:if test="${not empty r.replyUserName && r.replyUserName != c.userName}">
                                                    <span class="reply-to">回复 @${r.replyUserName}</span>
                                                </c:if>
                                                <span class="comment-time"><fmt:formatDate value="${r.createTime}" pattern="yyyy-MM-dd HH:mm"/></span>
                                            </div>
                                            <div class="comment-text">${r.content}</div>
                                            <div class="comment-ops">
                                                <a href="javascript:void(0)" class="op-like ${r.liked ? 'liked' : ''}" data-id="${r.id}">
                                                    <span class="op-like-icon">${r.liked ? '❤️' : '🤍'}</span>
                                                    <span class="op-like-count">${r.likeCount == null ? 0 : r.likeCount}</span>
                                                </a>
                                                <a href="javascript:void(0)" class="op-reply" data-id="${r.id}" data-name="${r.userName}">回复</a>
                                                <c:if test="${sessionScope.loginUser != null && (sessionScope.loginUser.id == r.userId || sessionScope.loginUser.role == 'ADMIN')}">
                                                    <a href="javascript:void(0)" class="op-delete" data-id="${r.id}">删除</a>
                                                </c:if>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </div>
                            </c:if>
                        </div>
                    </c:forEach>
                    <c:if test="${empty comments}">
                        <div class="empty-tip">还没有评论，快来抢沙发！</div>
                    </c:if>
                </div>
            </section>
        </div>
    </div>

    <script src="${pageContext.request.contextPath}/static/js/jquery.min.js"></script>
    <script>
        var ctx = "${pageContext.request.contextPath}";
        var articleId = ${article.id};

        // 未登录统一处理：提示后跳转登录页
        function needLogin(res) {
            if (res && res.code === 401) {
                alert("请先登录");
                location.href = ctx + "/user/login";
                return true;
            }
            return false;
        }

        // 点赞：数量与图标颜色同时切换（已赞为红色实心，取消恢复默认）
        $("#btnLike").click(function() {
            var btn = $(this);
            $.post(ctx + "/news/like/" + articleId, function(res) {
                if (needLogin(res)) return;
                if (res.code !== 200) { alert(res.msg); return; }
                var liked = res.data.liked;
                btn.toggleClass("liked", liked);
                btn.find(".like-icon").text(liked ? "❤️" : "🤍");
                $("#likeCount").text(res.data.likeCount);
            });
        });

        // 收藏/取消收藏：图标与数量同时切换
        $("#btnFav").click(function() {
            var btn = $(this);
            $.post(ctx + "/news/favorite/" + articleId, function(res) {
                if (needLogin(res)) return;
                if (res.code !== 200) { alert(res.msg); return; }
                var fav = res.data.favorited;
                btn.toggleClass("faved", fav);
                btn.find(".fav-icon").text(fav ? "⭐" : "☆");
                $("#favLabel").text(fav ? "已收藏" : "收藏");
                $("#favCount").text(res.data.favoriteCount);
            });
        });

        // ============ 评论：发表 / 回复 / 点赞 / 删除 ============
        var replyParentId = null;

        // 点击"回复"：进入回复模式（评论框提示 + 记录父评论ID）
        $(document).on("click", ".op-reply", function() {
            replyParentId = $(this).data("id");
            $("#replyTargetName").text("@" + $(this).data("name"));
            $("#replyTip").show();
            $("#commentContent").attr("placeholder", "回复 @" + $(this).data("name") + "：").focus();
            $("html,body").animate({ scrollTop: $("#commentContent").offset().top - 200 }, 300);
        });
        $("#cancelReply").click(function() {
            replyParentId = null;
            $("#replyTip").hide();
            $("#commentContent").attr("placeholder", "说点什么吧...");
        });

        // 评论点赞/取消点赞
        $(document).on("click", ".op-like", function() {
            var btn = $(this);
            $.post(ctx + "/news/comment/like/" + btn.data("id"), function(res) {
                if (needLogin(res)) return;
                if (res.code !== 200) { alert(res.msg); return; }
                btn.toggleClass("liked", res.data.liked);
                btn.find(".op-like-icon").text(res.data.liked ? "❤️" : "🤍");
                btn.find(".op-like-count").text(res.data.likeCount);
            });
        });

        // 删除评论（本人或管理员）
        $(document).on("click", ".op-delete", function() {
            if (!confirm("确定删除这条评论吗？")) return;
            $.post(ctx + "/news/comment/delete/" + $(this).data("id"), function(res) {
                if (needLogin(res)) return;
                if (res.code === 200) { location.reload(); }
                else { alert(res.msg); }
            });
        });

        // 发表评论/回复
        $("#btnSubmitComment").click(function() {
            var content = $("#commentContent").val().trim();
            if (!content) { alert("请输入评论内容"); return; }
            $.ajax({
                url: ctx + "/news/comment",
                type: "POST",
                contentType: "application/json",
                data: JSON.stringify({ articleId: articleId, content: content, parentId: replyParentId }),
                success: function(res) {
                    if (needLogin(res)) return;
                    if (res.code === 200) { location.reload(); }
                    else { alert(res.msg); }
                }
            });
        });

    </script>
</body>
</html>
