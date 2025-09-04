<!-- 自定义body结束标签内容 -->

<!-- 页面加载动画 -->
<div class="loading">
  <div class="loading-spinner"></div>
</div>

<!-- 返回顶部按钮 -->
<div id="back-to-top" class="back-to-top">
  <i class="fa fa-arrow-up"></i>
</div>

<!-- 鼠标点击特效 -->
<script>
  (function() {
    var hearts = [];
    window.requestAnimationFrame = (function() {
      return window.requestAnimationFrame ||
        window.webkitRequestAnimationFrame ||
        window.mozRequestAnimationFrame ||
        window.oRequestAnimationFrame ||
        window.msRequestAnimationFrame ||
        function(callback) {
          setTimeout(callback, 1000 / 60);
        }
    })();
    
    function init() {
      var mouseClick = function(event) {
        var d = document.createElement("div");
        d.className = "heart";
        hearts.push({
          el: d,
          x: event.clientX - 5,
          y: event.clientY - 5,
          scale: 1,
          alpha: 1,
          color: randomColor()
        });
        document.body.appendChild(d);
      }
      
      window.addEventListener("click", mouseClick);
      window.addEventListener("touchstart", mouseClick);
      
      css = ".heart{width: 10px;height: 10px;position: fixed;background: #f00;transform: rotate(45deg);-webkit-transform: rotate(45deg);-moz-transform: rotate(45deg);}.heart:after,.heart:before{content: '';width: inherit;height: inherit;background: inherit;border-radius: 50%;-webkit-border-radius: 50%;-moz-border-radius: 50%;position: absolute;}.heart:after{top: -5px;}.heart:before{left: -5px;}";
      var styleElement = document.createElement("style");
      styleElement.type = "text/css";
      styleElement.appendChild(document.createTextNode(css));
      document.getElementsByTagName("head")[0].appendChild(styleElement);
      
      gameloop();
    }
    
    function gameloop() {
      for (var i = 0; i < hearts.length; i++) {
        if (hearts[i].alpha <= 0) {
          document.body.removeChild(hearts[i].el);
          hearts.splice(i, 1);
          continue;
        }
        hearts[i].y--;
        hearts[i].scale += 0.004;
        hearts[i].alpha -= 0.013;
        hearts[i].el.style.cssText = "left:" + hearts[i].x + "px;top:" + hearts[i].y + "px;opacity:" + hearts[i].alpha + ";transform:scale(" + hearts[i].scale + "," + hearts[i].scale + ") rotate(45deg);background:" + hearts[i].color;
      }
      requestAnimationFrame(gameloop);
    }
    
    function randomColor() {
      return "rgb(" + (~~(Math.random() * 255)) + "," + (~~(Math.random() * 255)) + "," + (~~(Math.random() * 255)) + ")";
    }
    
    init();
  })();
</script>

<!-- 返回顶部按钮脚本 -->
<script>
  document.addEventListener('DOMContentLoaded', function() {
    var backToTop = document.getElementById('back-to-top');
    
    window.addEventListener('scroll', function() {
      if (window.pageYOffset > 300) {
        backToTop.style.display = 'block';
      } else {
        backToTop.style.display = 'none';
      }
    });
    
    backToTop.addEventListener('click', function(e) {
      e.preventDefault();
      window.scrollTo({
        top: 0,
        behavior: 'smooth'
      });
    });
  });
</script>

<style>
  .back-to-top {
    display: none;
    position: fixed;
    bottom: 30px;
    right: 30px;
    width: 40px;
    height: 40px;
    background-color: #49b1f5;
    color: #fff;
    text-align: center;
    line-height: 40px;
    border-radius: 50%;
    cursor: pointer;
    box-shadow: 0 2px 5px rgba(0, 0, 0, 0.3);
    z-index: 99;
    transition: all 0.3s;
  }
  
  .back-to-top:hover {
    background-color: #ff7242;
    transform: scale(1.1);
  }
</style> 