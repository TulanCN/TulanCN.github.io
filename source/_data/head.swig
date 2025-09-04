<!-- 自定义头部内容 -->

<!-- SEO优化元标签 -->
<meta name="keywords" content="涂蓝,博客,技术,生活,分享">
<meta name="description" content="涂蓝的个人博客，分享技术、生活和工作的点滴。">
<meta name="author" content="Tulan">

<!-- Open Graph 协议，用于社交媒体分享 -->
<meta property="og:title" content="{% if page.title %}{{ page.title }} | {% endif %}{{ config.title }}">
<meta property="og:type" content="website">
<meta property="og:url" content="{{ url }}">
<meta property="og:site_name" content="{{ config.title }}">
<meta property="og:description" content="{% if page.description %}{{ page.description }}{% else %}{{ config.description }}{% endif %}">

<!-- 百度站长验证 -->
<meta name="baidu-site-verification" content="你的百度站长验证码">

<!-- 谷歌站长验证 -->
<meta name="google-site-verification" content="你的谷歌站长验证码">

<!-- 网站图标 -->
<link rel="apple-touch-icon" sizes="180x180" href="/images/apple-touch-icon.png">
<link rel="icon" type="image/png" sizes="32x32" href="/images/favicon-32x32.png">
<link rel="icon" type="image/png" sizes="16x16" href="/images/favicon-16x16.png">
<link rel="manifest" href="/images/site.webmanifest">

<!-- 预加载字体 -->
<link rel="preload" href="//fonts.googleapis.com/css?family=Lato:300,300italic,400,400italic,700,700italic&display=swap" as="style">

<!-- 添加自定义CSS -->
<style>
  /* 页面加载动画 */
  .loading {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background-color: #fff;
    z-index: 9999;
    display: flex;
    justify-content: center;
    align-items: center;
  }
  .loading-spinner {
    width: 40px;
    height: 40px;
    border: 4px solid #f3f3f3;
    border-top: 4px solid #3498db;
    border-radius: 50%;
    animation: spin 1s linear infinite;
  }
  @keyframes spin {
    0% { transform: rotate(0deg); }
    100% { transform: rotate(360deg); }
  }
</style>

<!-- 页面加载动画脚本 -->
<script>
  document.addEventListener('DOMContentLoaded', function() {
    const loading = document.querySelector('.loading');
    if (loading) {
      setTimeout(function() {
        loading.style.opacity = '0';
        setTimeout(function() {
          loading.style.display = 'none';
        }, 500);
      }, 500);
    }
  });
</script> 