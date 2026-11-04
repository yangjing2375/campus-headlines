<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
    <title>${empty draft.id ? '写文章' : '编辑文章'} - 校园头条自媒体</title>
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
                    <li><a href="${pageContext.request.contextPath}/editor/draft/new" class="active">✍️ 写文章</a></li>
                    <li><a href="${pageContext.request.contextPath}/editor/drafts">📝 我的文章</a></li>
                    <li><a href="${pageContext.request.contextPath}/editor/materials">🖼️ 素材库</a></li>
                    <li><a href="${pageContext.request.contextPath}/editor/topics">🏷 我的话题</a></li>
                </ul>
            </aside>

            <div class="admin-main">
                <h2>${empty draft.id ? '✍️ 写文章' : '📝 编辑文章'}</h2>

                <c:if test="${draft.status == 3}">
                    <div class="reject-alert">
                        <strong>审核未通过：</strong>${draft.rejectReason}
                        <span class="hint">修改后可重新提交审核</span>
                    </div>
                </c:if>

                <form id="draftForm" class="editor-form">
                    <input type="hidden" id="draftId" value="${draft.id}">
                    <input type="hidden" id="coverInput" value="${draft.cover}">

                    <div class="form-group">
                        <label>标题 *</label>
                        <input type="text" id="title" value="${draft.title}" placeholder="请输入标题" maxlength="60">
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label>频道分类</label>
                            <select id="channelId">
                                <option value="">请选择频道</option>
                                <c:forEach items="${channels}" var="c">
                                    <option value="${c.id}" ${draft.channelId == c.id ? 'selected' : ''}>${c.name}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="form-group">
                            <label>来源 / 署名</label>
                            <input type="text" id="source" value="${draft.source}" placeholder="如：计算机学院 / 记者团">
                        </div>
                    </div>

                    <div class="form-group">
                        <label>所属话题 <span class="avatar-hint">（可选，仅可选择已上线话题；<a href="${pageContext.request.contextPath}/editor/topic/new" target="_blank">新建话题</a>）</span></label>
                        <select id="topicId">
                            <option value="">不关联话题</option>
                            <c:forEach items="${topics}" var="t">
                                <option value="${t.id}" ${draft.topicId == t.id ? 'selected' : ''}>#${t.title}</option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="form-group">
                        <label>摘要</label>
                        <textarea id="summary" rows="2" placeholder="一句话概括文章内容">${draft.summary}</textarea>
                    </div>

                    <!-- 封面图 -->
                    <div class="form-group">
                        <label>封面图</label>
                        <div class="cover-picker">
                            <div class="cover-preview" id="coverPreview">
                                <c:choose>
                                    <c:when test="${not empty draft.cover}">
                                        <img src="${pageContext.request.contextPath}${draft.cover}" alt="封面">
                                    </c:when>
                                    <c:otherwise>
                                        <span class="cover-empty">暂无封面</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                            <div class="cover-actions">
                                <button type="button" class="btn-outline" onclick="openPicker('cover')">🖼 从素材库选择</button>
                                <button type="button" class="btn-outline" id="btnUploadCover">⬆️ 上传本地图片</button>
                                <button type="button" class="btn-outline" onclick="clearCover()">清除</button>
                                <span class="avatar-hint">建议 16:9，jpg / png / gif，不超过 50MB</span>
                            </div>
                            <input type="file" id="coverFile" accept="image/*" style="display:none">
                        </div>
                    </div>

                    <!-- 视频（视频新闻） -->
                    <div class="form-group">
                        <label>视频 <span class="avatar-hint">（可选，上传后详情页将以视频形式展示）</span></label>
                        <input type="hidden" id="videoInput" value="${draft.videoUrl}">
                        <div class="cover-picker">
                            <div class="cover-preview video-preview" id="videoPreview">
                                <c:choose>
                                    <c:when test="${not empty draft.videoUrl}">
                                        <video src="${pageContext.request.contextPath}${draft.videoUrl}" controls preload="metadata"></video>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="cover-empty">暂无视频</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                            <div class="cover-actions">
                                <button type="button" class="btn-outline" id="btnUploadVideo">🎬 上传视频</button>
                                <button type="button" class="btn-outline" onclick="clearVideo()">清除</button>
                                <span class="avatar-hint" id="videoHint">支持 mp4，不超过 50MB</span>
                            </div>
                            <input type="file" id="videoFile" accept="video/mp4" style="display:none">
                        </div>
                    </div>

                    <!-- 富文本正文 -->
                    <div class="form-group">
                        <label>正文 *</label>
                        <div class="rich-toolbar">
                            <button type="button" data-cmd="bold" title="加粗"><b>B</b></button>
                            <button type="button" data-cmd="italic" title="斜体"><i>I</i></button>
                            <button type="button" data-cmd="underline" title="下划线"><u>U</u></button>
                            <button type="button" data-cmd="formatBlock" data-value="h2" title="标题">H2</button>
                            <button type="button" data-cmd="insertUnorderedList" title="无序列表">• 列表</button>
                            <button type="button" data-cmd="insertOrderedList" title="有序列表">1. 列表</button>
                            <button type="button" data-cmd="formatBlock" data-value="blockquote" title="引用">引用</button>
                            <button type="button" onclick="openPicker('insert')" title="插入图片">🖼 插入图片</button>
                        </div>
                        <div id="contentEditor" class="rich-editor" contenteditable="true"
                             data-placeholder="请输入正文内容，可插入素材库图片">${draft.content}</div>
                        <textarea id="contentValue" style="display:none">${draft.content}</textarea>
                    </div>

                    <div class="form-actions">
                        <button type="button" id="btnSave" class="btn btn-outline">💾 存草稿</button>
                        <button type="button" id="btnSubmit" class="btn btn-primary">📤 提交审核</button>
                        <a href="${pageContext.request.contextPath}/editor/drafts" class="btn btn-link">返回我的文章</a>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- 素材选择弹层 -->
    <div class="picker-mask" id="pickerMask">
        <div class="picker-dialog">
            <div class="picker-head">
                <span id="pickerTitle">选择素材</span>
                <button type="button" class="picker-close" onclick="closePicker()">×</button>
            </div>
            <div class="picker-body">
                <c:choose>
                    <c:when test="${empty materials}">
                        <div class="empty-tip">
                            素材库还没有图片，请先到
                            <a href="${pageContext.request.contextPath}/editor/materials">素材库</a> 上传
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="picker-grid">
                            <c:forEach items="${materials}" var="m">
                                <div class="picker-item" data-url="${m.url}"
                                     onclick="pickMaterial('${m.url}')">
                                    <img src="${pageContext.request.contextPath}${m.url}" alt="${m.name}">
                                </div>
                            </c:forEach>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>

    <script src="${pageContext.request.contextPath}/static/js/jquery.min.js"></script>
    <script>
        var ctx = "${pageContext.request.contextPath}";
        var pickerMode = "cover";
        var savedRange = null;

        // ============ 富文本工具栏 ============
        $(".rich-toolbar button[data-cmd]").click(function() {
            var cmd = $(this).data("cmd");
            var val = $(this).data("value") || null;
            $("#contentEditor").focus();
            document.execCommand(cmd, false, val);
        });

        // 记录光标位置，便于插入图片
        $("#contentEditor").on("mouseup keyup blur", function() {
            var sel = window.getSelection();
            if (sel.rangeCount > 0 && $("#contentEditor")[0].contains(sel.anchorNode)) {
                savedRange = sel.getRangeAt(0);
            }
        });

        // 空编辑器占位提示
        function togglePlaceholder() {
            var $e = $("#contentEditor");
            var text = $e.text().trim();
            $e.toggleClass("is-empty", text === "" && $e.find("img").length === 0);
        }
        $("#contentEditor").on("input keyup", togglePlaceholder);
        togglePlaceholder();

        // ============ 封面 ============
        $("#btnUploadCover").click(function() { $("#coverFile").click(); });

        $("#coverFile").change(function() {
            var file = this.files[0];
            if (!file) return;
            uploadFile(file, function(m) {
                $("#coverInput").val(m.url);
                $("#coverPreview").html('<img src="' + ctx + m.url + '" alt="封面">');
            });
            this.value = "";
        });

        function clearCover() {
            $("#coverInput").val("");
            $("#coverPreview").html('<span class="cover-empty">暂无封面</span>');
        }

        // ============ 视频 ============
        $("#btnUploadVideo").click(function() { $("#videoFile").click(); });

        $("#videoFile").change(function() {
            var file = this.files[0];
            if (!file) return;
            if (!/\.mp4$/i.test(file.name)) { alert("仅支持 mp4 格式视频"); this.value = ""; return; }
            $("#videoHint").text("上传中，请稍候...");
            uploadFile(file, function(m) {
                $("#videoInput").val(m.url);
                $("#videoPreview").html('<video src="' + ctx + m.url + '" controls preload="metadata"></video>');
                $("#videoHint").text("支持 mp4，不超过 50MB");
            });
            this.value = "";
        });

        function clearVideo() {
            $("#videoInput").val("");
            $("#videoPreview").html('<span class="cover-empty">暂无视频</span>');
        }

        function uploadFile(file, onSuccess) {
            if (file.size > 50 * 1024 * 1024) { alert("文件不能超过 50MB"); return; }
            var fd = new FormData();
            fd.append("file", file);
            $.ajax({
                url: ctx + "/editor/upload",
                type: "POST", data: fd, processData: false, contentType: false,
                success: function(res) {
                    if (res.code === 200) { onSuccess(res.data); }
                    else { alert(res.msg); }
                },
                error: function() { alert("上传失败，请重试"); }
            });
        }

        // ============ 素材选择弹层 ============
        function openPicker(mode) {
            pickerMode = mode;
            if (mode === "insert") {
                $("#pickerTitle").text("插入图片到正文");
                var sel = window.getSelection();
                if (sel.rangeCount > 0 && $("#contentEditor")[0].contains(sel.anchorNode)) {
                    savedRange = sel.getRangeAt(0);
                }
            } else {
                $("#pickerTitle").text("选择封面图");
            }
            $("#pickerMask").addClass("show");
        }
        function closePicker() { $("#pickerMask").removeClass("show"); }

        function pickMaterial(url) {
            if (pickerMode === "cover") {
                $("#coverInput").val(url);
                $("#coverPreview").html('<img src="' + ctx + url + '" alt="封面">');
            } else {
                insertImage(url);
            }
            closePicker();
        }

        function insertImage(url) {
            var $editor = $("#contentEditor");
            $editor.focus();
            var html = '<img src="' + ctx + url + '" style="max-width:100%;border-radius:8px;margin:8px 0;">';
            if (savedRange) {
                var sel = window.getSelection();
                sel.removeAllRanges();
                sel.addRange(savedRange);
            }
            document.execCommand("insertHTML", false, html);
            $editor.removeClass("is-empty");
        }

        // ============ 保存 / 提交 ============
        function collectFormData() {
            var idVal = $("#draftId").val();
            $("#contentValue").val($("#contentEditor").html());
            return {
                id:        idVal ? parseInt(idVal) : null,
                title:     $.trim($("#title").val()),
                summary:   $.trim($("#summary").val()),
                content:   $("#contentValue").val(),
                channelId: parseInt($("#channelId").val()) || null,
                topicId:   parseInt($("#topicId").val()) || null,
                source:    $.trim($("#source").val()),
                cover:     $("#coverInput").val(),
                videoUrl:  $("#videoInput").val()
            };
        }

        function validate(data, needChannel) {
            if (!data.title) { alert("请填写标题"); return false; }
            var text = $("#contentEditor").text().trim();
            if (!text && $("#contentEditor").find("img").length === 0) {
                alert("请填写正文内容"); return false;
            }
            if (needChannel && !data.channelId) { alert("提交审核前请选择频道分类"); return false; }
            return true;
        }

        function saveDraft() {
            var data = collectFormData();
            if (!validate(data, false)) return;
            $.ajax({
                url: ctx + "/editor/draft/save",
                type: "POST", contentType: "application/json",
                data: JSON.stringify(data),
                success: function(res) {
                    if (res.code === 200) {
                        alert(res.msg);
                        location.href = ctx + "/editor/drafts?status=0";
                    } else { alert(res.msg); }
                },
                error: function() { alert("保存失败，请重试"); }
            });
        }

        function submitAudit() {
            var data = collectFormData();
            if (!validate(data, true)) return;
            $.ajax({
                url: ctx + "/editor/draft/save",
                type: "POST", contentType: "application/json",
                data: JSON.stringify(data),
                success: function(res) {
                    if (res.code !== 200) { alert(res.msg); return; }
                    var draftId = data.id || res.data;
                    $.post(ctx + "/editor/draft/submit/" + draftId, function(res2) {
                        if (res2.code === 200) {
                            alert("已提交审核，请等待审核员处理");
                            location.href = ctx + "/editor/drafts?status=1";
                        } else { alert(res2.msg); }
                    });
                },
                error: function() { alert("提交失败，请重试"); }
            });
        }

        $("#btnSave").click(saveDraft);
        $("#btnSubmit").click(submitAudit);
    </script>
</body>
</html>
