<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
    <title>后台管理 - 校园头条</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/style.css?v=28">
    <style>
        .admin-stats { display: grid; grid-template-columns: repeat(4, 1fr); gap: 14px; }
        .stat-card { padding: 18px 14px; }
        .stat-num { font-size: 26px; font-weight: 700; line-height: 1.2; }
        .stat-label { font-size: 12px; opacity: .92; margin-top: 6px; }
        .stat-sub { font-size: 11px; opacity: .85; margin-top: 2px; }

        .chart-range { display: flex; gap: 6px; }
        .range-btn {
            border: 1px solid var(--border); background: #fff; color: var(--text-secondary);
            font-size: 12px; padding: 4px 12px; border-radius: 14px; cursor: pointer; transition: all .2s;
        }
        .range-btn:hover { border-color: var(--primary); color: var(--primary-dark); }
        .range-btn.active { background: var(--primary); border-color: var(--primary); color: #fff; }

        .chart-toolbar {
            display: flex; align-items: center; gap: 10px; font-size: 12px; color: var(--text-muted);
        }
        .live-dot {
            width: 8px; height: 8px; border-radius: 50%; background: #2daf94; display: inline-block;
            margin-right: 5px; animation: livePulse 1.8s infinite;
        }
        @keyframes livePulse {
            0%   { box-shadow: 0 0 0 0 rgba(45,175,148,.55); }
            70%  { box-shadow: 0 0 0 7px rgba(45,175,148,0); }
            100% { box-shadow: 0 0 0 0 rgba(45,175,148,0); }
        }

        .donut-wrap { display: flex; align-items: center; gap: 18px; }
        .donut-wrap svg { width: 150px; height: 150px; flex: 0 0 150px; }
        .donut-seg { transition: stroke-width .2s, opacity .2s; cursor: pointer; }
        .donut-seg:hover { stroke-width: 26; }
        .donut-center-num { font-size: 22px; font-weight: 700; fill: var(--text); }
        .donut-center-label { font-size: 11px; fill: var(--text-muted); }
        .donut-legend { flex: 1; display: flex; flex-direction: column; gap: 9px; }
        .donut-legend-row { display: flex; align-items: center; font-size: 13px; color: var(--text-secondary); }
        .donut-legend-row i { width: 10px; height: 10px; border-radius: 3px; margin-right: 8px; }
        .donut-legend-row b { margin-left: auto; color: var(--text); font-weight: 600; }
        .donut-legend-row em { font-style: normal; color: var(--text-muted); font-size: 11px; margin-left: 6px; }

        .bar-row { position: relative; }
        .chart-loading { text-align: center; color: var(--text-muted); font-size: 13px; padding: 26px 0; }

        @media (max-width: 1100px) { .admin-stats { grid-template-columns: repeat(2, 1fr); } }

        .hot-table { width: 100%; border-collapse: collapse; margin-top: 12px; }
        .hot-table th, .hot-table td { padding: 10px 12px; font-size: 13px; border-bottom: 1px solid var(--border); text-align: left; }
        .hot-table th { background: var(--primary-light); font-weight: 600; color: var(--primary-dark); }
        .hot-table a.title-link { color: var(--text); font-weight: 500; max-width: 280px; display: inline-block; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
        .hot-table a.title-link:hover { color: var(--primary-dark); }
        .hot-table .num-cell { color: var(--primary-dark); font-weight: 600; text-align: center; width: 70px; }
        .hot-table .action-cell { width: 90px; text-align: center; }
        .btn-offshelf { padding: 4px 12px; border-radius: 14px; border: 1px solid #ef5350; background: #fff; color: #ef5350; font-size: 12px; cursor: pointer; transition: all .2s; }
        .btn-offshelf:hover { background: #ef5350; color: #fff; }
        .btn-offshelf:disabled { opacity: .5; cursor: not-allowed; }
        .rank-badge {
            display: inline-block; width: 22px; height: 22px; border-radius: 4px;
            background: var(--primary-light); color: var(--primary-dark);
            font-weight: bold; font-size: 12px; text-align: center; line-height: 22px; margin-right: 8px;
        }
        .rank-badge.top1 { background: var(--primary); color: #fff; }
        .rank-badge.top2 { background: var(--primary-mid); color: #fff; }
        .rank-badge.top3 { background: var(--primary-dark); color: #fff; }
        .hot-empty-row { text-align: center; color: var(--text-muted); padding: 30px; }
    </style>
</head>
<body>
    <%@ include file="/WEB-INF/views/common/header.jsp" %>

    <div class="container">
        <div class="admin-layout">
            <aside class="admin-sidebar">
                <h3>后台管理</h3>
                <ul>
                    <li><a href="${pageContext.request.contextPath}/admin/dashboard" class="active">📊 数据看板</a></li>
                    <li><a href="${pageContext.request.contextPath}/admin/audit">✅ 审核中心</a></li>
                    <li><a href="${pageContext.request.contextPath}/admin/media-applies">📮 自媒体申请</a></li>
                    <li><a href="${pageContext.request.contextPath}/admin/articles">📰 资讯管理</a></li>
                    <li><a href="${pageContext.request.contextPath}/admin/categories">📂 栏目管理</a></li>
                    <li><a href="${pageContext.request.contextPath}/admin/users">👥 用户管理</a></li>
                    <li><a href="${pageContext.request.contextPath}/admin/comments">💬 评论管理</a></li>
                    <li><a href="${pageContext.request.contextPath}/admin/topics">🏷 话题管理</a></li>
                </ul>
            </aside>

            <div class="admin-main">
                <h2>📊 数据统计看板</h2>

                <!-- 顶部统计卡 -->
                <div class="admin-stats">
                    <div class="stat-card stat-blue">
                        <div class="stat-num" id="s-articleCount">${articleCount}</div>
                        <div class="stat-label">资讯总数</div>
                        <div class="stat-sub">含各状态稿件</div>
                    </div>
                    <div class="stat-card stat-green">
                        <div class="stat-num" id="s-userCount">${userCount}</div>
                        <div class="stat-label">注册用户</div>
                        <div class="stat-sub">学生 / 自媒体 / 管理员</div>
                    </div>
                    <div class="stat-card stat-orange">
                        <div class="stat-num" id="s-pendingCount">${pendingCount}</div>
                        <div class="stat-label">待审核稿件</div>
                        <div class="stat-sub">需尽快处理</div>
                    </div>
                    <div class="stat-card stat-pink">
                        <div class="stat-num" id="s-totalReads">${totalReads}</div>
                        <div class="stat-label">总浏览量</div>
                        <div class="stat-sub">资讯累计</div>
                    </div>
                    <div class="stat-card stat-blue">
                        <div class="stat-num" id="s-totalLikes">${totalLikes}</div>
                        <div class="stat-label">总点赞数</div>
                        <div class="stat-sub">互动热度</div>
                    </div>
                    <div class="stat-card stat-green">
                        <div class="stat-num" id="s-totalComments">${totalComments}</div>
                        <div class="stat-label">总评论量</div>
                        <div class="stat-sub">含回复</div>
                    </div>
                    <div class="stat-card stat-orange">
                        <div class="stat-num" id="s-totalFavs">${totalFavs}</div>
                        <div class="stat-label">总收藏量</div>
                        <div class="stat-sub">资讯累计</div>
                    </div>
                    <div class="stat-card stat-blue">
                        <div class="stat-num" id="s-topicCount">${topicCount}</div>
                        <div class="stat-label">话题总数</div>
                        <div class="stat-sub">覆盖各类校园主题</div>
                    </div>
                    <div class="stat-card stat-orange">
                        <div class="stat-num" id="s-pendingTopicCount">${pendingTopicCount}</div>
                        <div class="stat-label">待审核话题</div>
                        <div class="stat-sub">需尽快处理</div>
                    </div>
                </div>

                <!-- 可视化图表区 -->
                <div class="chart-grid">
                    <div class="chart-box chart-wide">
                        <div class="chart-head">
                            <h3>📈 发布趋势</h3>
                            <div class="chart-range">
                                <button class="range-btn active" data-days="7">近 7 天</button>
                                <button class="range-btn" data-days="14">近 14 天</button>
                                <button class="range-btn" data-days="30">近 30 天</button>
                            </div>
                        </div>
                        <div class="chart-toolbar" style="margin:-4px 0 8px">
                            <span><i class="live-dot"></i>实时数据 · 每 60 秒自动刷新</span>
                            <span id="lastUpdated"></span>
                            <div class="chart-legend" style="margin-left:auto">
                                <span><i class="dot dot-green"></i>资讯</span>
                            </div>
                        </div>
                        <div id="trendChart" class="chart-body"><div class="chart-loading">加载中…</div></div>
                    </div>

                    <div class="chart-box">
                        <div class="chart-head"><h3>🍩 稿件状态分布</h3></div>
                        <div id="statusChart" class="chart-body"><div class="chart-loading">加载中…</div></div>
                    </div>

                    <div class="chart-box">
                        <div class="chart-head"><h3>📂 频道发文分布（已发布 TOP6）</h3></div>
                        <div id="channelChart" class="chart-body"><div class="chart-loading">加载中…</div></div>
                    </div>
                </div>

                <!-- 热门资讯 TOP8 -->
                <div class="side-card" style="margin-top:24px">
                    <h3>🔥 热门资讯 TOP8（综合热度排序）</h3>
                    <c:if test="${empty hotList}">
                        <div class="hot-empty-row">暂无热门资讯</div>
                    </c:if>
                    <c:if test="${not empty hotList}">
                    <table class="hot-table">
                        <thead>
                            <tr>
                                <th style="width:50px">排名</th>
                                <th>标题</th>
                                <th style="width:70px; text-align:center">👁 浏览</th>
                                <th style="width:70px; text-align:center">👍 点赞</th>
                                <th style="width:70px; text-align:center">💬 评论</th>
                                <th style="width:70px; text-align:center">⭐ 收藏</th>
                                <th style="width:90px; text-align:center">操作</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach items="${hotList}" var="h" varStatus="i">
                                <tr id="hot-row-${h.id}">
                                    <td>
                                        <span class="rank-badge ${i.index < 3 ? 'top' += (i.index + 1) : ''}">${i.index + 1}</span>
                                    </td>
                                    <td>
                                        <a class="title-link" href="${pageContext.request.contextPath}/news/detail/${h.id}" target="_blank" title="${h.title}">${h.title}</a>
                                        <c:if test="${not empty h.channelName}">
                                            <span class="tag tag-sm" style="margin-left:6px">${h.channelName}</span>
                                        </c:if>
                                    </td>
                                    <td class="num-cell">${h.viewCount == null ? 0 : h.viewCount}</td>
                                    <td class="num-cell">${h.likeCount == null ? 0 : h.likeCount}</td>
                                    <td class="num-cell">${h.commentCount == null ? 0 : h.commentCount}</td>
                                    <td class="num-cell">${h.favoriteCount == null ? 0 : h.favoriteCount}</td>
                                    <td class="action-cell">
                                        <button class="btn-offshelf" onclick="offShelf(${h.id}, this)">下架</button>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                    </c:if>
                </div>
            </div>
        </div>
    </div>

    <script src="${pageContext.request.contextPath}/static/js/jquery.min.js"></script>
    <script>
        var CTX = '${pageContext.request.contextPath}';
        function offShelf(id, btn) {
            if (!confirm('确定要下架该热门资讯吗？下架后将不再出现在首页和热门榜中。')) return;
            btn.disabled = true;
            btn.textContent = '下架中...';
            $.post(CTX + '/admin/article/offShelf/' + id, function(res) {
                if (res && res.code === 200) {
                    $('#hot-row-' + id).fadeOut(300, function(){ $(this).remove(); });
                } else {
                    alert(res && res.msg ? res.msg : '下架失败');
                    btn.disabled = false;
                    btn.textContent = '下架';
                }
            }).fail(function(){
                alert('网络异常，请重试');
                btn.disabled = false;
                btn.textContent = '下架';
            });
        }

        // ============ 图表渲染（纯 SVG / CSS，无外部依赖） ============
        var currentDays = 7;
        var GREEN = '#2daf94', ORANGE = '#f0a020';

        // 数字滚动动画
        function animateNumber(el, to) {
            var from = parseInt(el.text(), 10);
            if (isNaN(from)) from = 0;
            if (from === to) { el.text(to); return; }
            var start = null, dur = 650;
            function tick(ts) {
                if (!start) start = ts;
                var p = Math.min(1, (ts - start) / dur);
                var eased = 1 - Math.pow(1 - p, 3);
                el.text(Math.round(from + (to - from) * eased));
                if (p < 1) requestAnimationFrame(tick);
            }
            requestAnimationFrame(tick);
        }

        // 折线/面积图：多条序列
        function renderTrend(el, labels, series) {
            if (!labels.length) { el.innerHTML = '<div class="chart-empty">暂无数据</div>'; return; }
            var W = 680, H = 240, L = 42, R = 16, T = 16, B = 30;
            var iw = W - L - R, ih = H - T - B, n = labels.length;
            var max = 0;
            series.forEach(function(s) { s.data.forEach(function(v) { if (v > max) max = v; }); });
            var step = Math.max(1, Math.ceil(max / 4)), top = step * 4;
            function px(i) { return L + (n <= 1 ? iw / 2 : iw * i / (n - 1)); }
            function py(v) { return T + ih * (1 - v / top); }

            var svg = '<svg viewBox="0 0 ' + W + ' ' + H + '" class="svg-chart" preserveAspectRatio="xMidYMid meet">';
            svg += '<defs>';
            series.forEach(function(s, si) {
                svg += '<linearGradient id="areaGrad' + si + '" x1="0" y1="0" x2="0" y2="1">' +
                       '<stop offset="0%" stop-color="' + s.color + '" stop-opacity="0.28"/>' +
                       '<stop offset="100%" stop-color="' + s.color + '" stop-opacity="0"/></linearGradient>';
            });
            svg += '</defs>';
            for (var g = 0; g <= 4; g++) {
                var vy = py(step * g);
                svg += '<line x1="' + L + '" y1="' + vy + '" x2="' + (W - R) + '" y2="' + vy + '" class="chart-grid-line"/>';
                svg += '<text x="' + (L - 9) + '" y="' + (vy + 4) + '" class="chart-axis-text" text-anchor="end">' + (step * g) + '</text>';
            }
            var skip = Math.ceil(n / 10);
            labels.forEach(function(lb, i) {
                if (n > 10 && i % skip !== 0 && i !== n - 1) return;
                svg += '<text x="' + px(i) + '" y="' + (H - 8) + '" class="chart-axis-text" text-anchor="middle">' + lb + '</text>';
            });
            series.forEach(function(s, si) {
                var pts = s.data.map(function(v, i) { return px(i) + ',' + py(v); }).join(' ');
                svg += '<polygon points="' + L + ',' + py(0) + ' ' + pts + ' ' + px(n - 1) + ',' + py(0) + '" fill="url(#areaGrad' + si + ')"/>';
                svg += '<polyline points="' + pts + '" fill="none" stroke="' + s.color + '" stroke-width="2.5" stroke-linejoin="round" stroke-linecap="round"/>';
                s.data.forEach(function(v, i) {
                    svg += '<circle cx="' + px(i) + '" cy="' + py(v) + '" r="3.5" fill="#fff" stroke="' + s.color + '" stroke-width="2">' +
                           '<title>' + labels[i] + ' ' + s.name + '：' + v + '</title></circle>';
                });
            });
            svg += '</svg>';
            el.innerHTML = svg;
        }

        // 环形图 + 图例
        function renderDonut(el, labels, values, colors) {
            var total = values.reduce(function(a, b) { return a + b; }, 0);
            if (!total) { el.innerHTML = '<div class="chart-empty">暂无数据</div>'; return; }
            var R = 54, C = 2 * Math.PI * R, cx = 80, cy = 80, offset = 0;
            var svg = '<svg viewBox="0 0 160 160">';
            svg += '<circle cx="80" cy="80" r="' + R + '" fill="none" stroke="#f2f4f7" stroke-width="20"/>';
            labels.forEach(function(lb, i) {
                var v = values[i] || 0;
                if (!v) return;
                var len = C * v / total;
                svg += '<circle class="donut-seg" cx="80" cy="80" r="' + R + '" fill="none" stroke="' + colors[i % colors.length] + '"' +
                       ' stroke-width="20" stroke-dasharray="' + len.toFixed(2) + ' ' + (C - len).toFixed(2) + '"' +
                       ' stroke-dashoffset="' + (-offset).toFixed(2) + '" transform="rotate(-90 80 80)">' +
                       '<title>' + lb + '：' + v + '（' + (v / total * 100).toFixed(1) + '%）</title></circle>';
                offset += len;
            });
            svg += '<text x="80" y="76" text-anchor="middle" class="donut-center-num">' + total + '</text>';
            svg += '<text x="80" y="94" text-anchor="middle" class="donut-center-label">稿件总数</text>';
            svg += '</svg>';

            var legend = '<div class="donut-legend">';
            labels.forEach(function(lb, i) {
                var v = values[i] || 0;
                legend += '<div class="donut-legend-row">' +
                              '<i style="background:' + colors[i % colors.length] + '"></i>' + lb +
                              '<b>' + v + '</b><em>' + (total ? (v / total * 100).toFixed(1) : 0) + '%</em>' +
                          '</div>';
            });
            legend += '</div>';
            el.innerHTML = '<div class="donut-wrap">' + svg + legend + '</div>';
        }

        // 横向条形图
        function renderBars(el, labels, values, color) {
            var max = 0;
            values.forEach(function(v) { if (v > max) max = v; });
            if (!labels.length || max === 0) { el.innerHTML = '<div class="chart-empty">暂无数据</div>'; return; }
            var html = '<div class="bar-list">';
            labels.forEach(function(lb, i) {
                var v = values[i] || 0;
                var pct = Math.max(v > 0 ? 4 : 0, Math.round(v / max * 100));
                html += '<div class="bar-row" title="' + lb + '：' + v + ' 篇（占最高项 ' + Math.round(v / max * 100) + '%）">' +
                            '<span class="bar-label">' + lb + '</span>' +
                            '<span class="bar-track"><i class="bar-fill" style="width:0;background:' + color + '" data-w="' + pct + '"></i></span>' +
                            '<span class="bar-value" data-v="' + v + '">0</span>' +
                        '</div>';
            });
            html += '</div>';
            el.innerHTML = html;
            // 逐条增长动画
            el.querySelectorAll('.bar-fill').forEach(function(bar, i) {
                setTimeout(function() { bar.style.width = bar.dataset.w + '%'; }, 60 + i * 70);
            });
            el.querySelectorAll('.bar-value').forEach(function(vEl, i) {
                setTimeout(function() { animateNumber(vEl, parseInt(vEl.dataset.v, 10)); }, 60 + i * 70);
            });
        }

        // 拉取数据并重绘
        function loadDashboard(days) {
            $.getJSON(CTX + '/admin/dashboard/data?days=' + days, function(res) {
                if (!res || res.code !== 200) return;
                var d = res.data;

                var cards = ['articleCount', 'userCount', 'pendingCount',
                             'totalReads', 'totalLikes', 'totalComments', 'totalFavs',
                             'topicCount', 'pendingTopicCount'];
                cards.forEach(function(k) { animateNumber($('#s-' + k), d[k] || 0); });

                renderTrend(document.getElementById('trendChart'), d.trendLabels, [
                    { name: '资讯', data: d.trendArticles, color: GREEN }
                ]);
                renderDonut(document.getElementById('statusChart'), d.statusNames, d.statusValues,
                    ['#9aa5b1', '#f0a020', '#2daf94', '#ef5350', '#7c8894']);
                renderBars(document.getElementById('channelChart'), d.channelLabels, d.channelValues, GREEN);

                var t = new Date();
                $('#lastUpdated').text('更新于 ' + ('0' + t.getHours()).slice(-2) + ':' +
                    ('0' + t.getMinutes()).slice(-2) + ':' + ('0' + t.getSeconds()).slice(-2));
            });
        }

        $(function() {
            loadDashboard(currentDays);

            $('.range-btn').click(function() {
                $('.range-btn').removeClass('active');
                $(this).addClass('active');
                currentDays = parseInt($(this).data('days'), 10);
                loadDashboard(currentDays);
            });

            // 每 60 秒静默刷新
            setInterval(function() { loadDashboard(currentDays); }, 60000);
        });
    </script>
</body>
</html>
