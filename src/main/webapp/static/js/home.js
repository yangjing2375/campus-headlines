// ============================================
// 校园头条 - 首页 JS v2
// Hero 轮播自动播放
// ============================================
(function() {
    var banners = document.querySelectorAll('.hero-slide');
    var dots = document.querySelectorAll('.hero-dot');
    if (banners.length === 0) return;

    var current = 0;
    var timer = null;

    function show(index) {
        banners[current].classList.remove('active');
        if (dots[current]) dots[current].classList.remove('active');
        current = (index + banners.length) % banners.length;
        banners[current].classList.add('active');
        if (dots[current]) dots[current].classList.add('active');
    }

    function next() { show(current + 1); }
    function prev() { show(current - 1); }

    // 自动播放
    function startAuto() {
        stopAuto();
        timer = setInterval(next, 4500);
    }
    function stopAuto() {
        if (timer) { clearInterval(timer); timer = null; }
    }

    // 绑定按钮
    window.slideHero = function(dir) { (dir > 0 ? next : prev)(); startAuto(); };
    window.slideHeroTo = function(i) { show(i); startAuto(); };

    // 鼠标悬停暂停
    var banner = document.getElementById('heroBanner');
    if (banner) {
        banner.addEventListener('mouseenter', stopAuto);
        banner.addEventListener('mouseleave', startAuto);
    }

    // 启动
    startAuto();
})();
